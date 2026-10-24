# Retries without a retry storm

▶ **[Watch the video](https://www.youtube.com/watch?v=sLKHz8MVRz0)**

Companion code for the Cloud Signal Short **"Why Instant Retries Can Take Your Service Down"**.

A service slows down, every client retries at once, and the extra load stops it from recovering. The fix:

| Rule | Why | In [`retry.py`](retry.py) |
|---|---|---|
| Exponential backoff | wait longer after each failure (1 s, 2 s, 4 s ...) | `backoff_delays()` |
| Jitter | random waits, so clients don't retry at the same moment | full jitter: `random() * min(cap, base * 2**n)` |
| Finite | a maximum number of attempts and a time budget | `attempts`, `budget` |
| Stop early | after repeated failures, stop calling for a while | `CircuitBreaker` |
| Respect `Retry-After` | the service knows best when to come back | `TransientError(retry_after=...)` |
| Only transient errors | timeouts, 429, 503 can succeed later; 400 and 401 never will | raise `TransientError` only for those |

```python
from retry import call_with_retry, CircuitBreaker, TransientError

breaker = CircuitBreaker(failure_threshold=5, cooldown=30)

def get_orders():
    r = session.get(url, timeout=5)
    if r.status_code == 429 or r.status_code >= 500:
        raise TransientError(str(r.status_code), retry_after=float(r.headers.get("Retry-After", 0)) or None)
    r.raise_for_status()
    return r.json()

orders = call_with_retry(get_orders, attempts=5, base=1, cap=30, budget=60, breaker=breaker)
```

## See the difference

```bash
python3 simulate.py
# fixed 1 s     worst 100 ms:  1000 retries
# exponential   worst 100 ms:  1000 retries   (backoff alone: still all in sync)
# exp + jitter  worst 100 ms:  ~150 retries
python3 -m unittest test_retry.py
```

Backoff without jitter only moves the spike; jitter is what spreads it out.

## Before you write your own

Most clients already do this. The Azure SDKs retry with exponential backoff by default (configure the retry
policy rather than wrapping it in a second retry loop, which multiplies attempts). In .NET, Polly and
`Microsoft.Extensions.Http.Resilience` provide backoff, jitter and circuit breakers.

## Sources

- AWS Architecture Blog: Exponential Backoff and Jitter: https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
- Microsoft: Retry pattern: https://learn.microsoft.com/en-us/azure/architecture/patterns/retry
- Microsoft: Circuit Breaker pattern: https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker

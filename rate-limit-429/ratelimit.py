"""Token bucket (server side) and a client that respects 429 + Retry-After. Standard library only.
    python3 ratelimit.py
"""
import random
import time


class TokenBucket:
    """Refills `rate` tokens per second up to `capacity`. Each request takes one token."""

    def __init__(self, rate: float, capacity: int, clock=time.monotonic):
        self.rate, self.capacity, self.clock = rate, capacity, clock
        self.tokens, self.last = float(capacity), clock()

    def allow(self) -> tuple[bool, float]:
        now = self.clock()
        self.tokens = min(self.capacity, self.tokens + (now - self.last) * self.rate)
        self.last = now
        if self.tokens >= 1:
            self.tokens -= 1
            return True, 0.0
        return False, (1 - self.tokens) / self.rate     # seconds until the next token: the Retry-After value


def handle(bucket: TokenBucket) -> tuple[int, dict]:
    ok, wait = bucket.allow()
    return (200, {}) if ok else (429, {"Retry-After": str(max(1, round(wait)))})


def call_with_respect(send, attempts: int = 5, sleep=time.sleep):
    """Retry a 429 only after Retry-After (or exponential backoff), with jitter, a finite number of times."""
    for n in range(attempts):
        status, headers = send()
        if status != 429:
            return status
        wait = float(headers.get("Retry-After", 2 ** n))
        sleep(wait + random.uniform(0, 0.5))
    return status


if __name__ == "__main__":
    bucket = TokenBucket(rate=10, capacity=10)
    burst = [handle(bucket)[0] for _ in range(15)]
    print("burst of 15 requests:", burst.count(200), "x 200,", burst.count(429), "x 429")
    status, headers = handle(bucket)
    print("next request:", status, headers)
    print("after waiting Retry-After:", call_with_respect(lambda: handle(bucket)))

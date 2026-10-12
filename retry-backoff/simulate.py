"""Why jitter matters: 1000 clients fail at t=0 and retry. Count retries per 100 ms window: the peak is what the
recovering service has to absorb at once.
python3 simulate.py"""
import random
from collections import Counter

CLIENTS, ATTEMPTS = 1000, 5


def run(strategy):
    hits = Counter()
    for _ in range(CLIENTS):
        t = 0.0
        for n in range(ATTEMPTS - 1):
            t += strategy(n)
            hits[int(t * 10)] += 1
    return hits


fixed = run(lambda n: 1.0)  # retry every second
expo = run(lambda n: 2**n)  # 1, 2, 4, 8 s, all in sync
jitter = run(lambda n: random.random() * 2**n)  # full jitter

for name, h in (("fixed 1 s", fixed), ("exponential", expo), ("exp + jitter", jitter)):
    peak = max(h.values())
    print(f"{name:13} worst 100 ms: {peak:5} retries   total time: {max(h) / 10:5.1f} s")

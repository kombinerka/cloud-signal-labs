import unittest

from ratelimit import TokenBucket, call_with_respect, handle


class Clock:
    def __init__(self): self.t = 0.0
    def __call__(self): return self.t


class Bucket(unittest.TestCase):
    def test_burst_then_429(self):
        b = TokenBucket(rate=10, capacity=10, clock=Clock())
        codes = [handle(b)[0] for _ in range(12)]
        self.assertEqual(codes.count(200), 10)
        self.assertEqual(codes[-1], 429)

    def test_refills_over_time(self):
        c = Clock(); b = TokenBucket(rate=10, capacity=10, clock=c)
        for _ in range(10): handle(b)
        self.assertEqual(handle(b)[0], 429)
        c.t += 0.5                      # 5 tokens back
        self.assertEqual([handle(b)[0] for _ in range(6)].count(200), 5)

    def test_client_waits_retry_after(self):
        replies = iter([(429, {"Retry-After": "3"}), (200, {})])
        slept = []
        self.assertEqual(call_with_respect(lambda: next(replies), sleep=slept.append), 200)
        self.assertGreaterEqual(slept[0], 3)


if __name__ == "__main__":
    unittest.main()

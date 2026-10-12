"""python3 -m unittest test_retry.py  (no dependencies)"""
import unittest

from retry import CircuitBreaker, CircuitOpen, TransientError, backoff_delays, call_with_retry


class Fake:
    def __init__(self, fail_times, retry_after=None):
        self.fail_times, self.calls, self.retry_after = fail_times, 0, retry_after

    def __call__(self):
        self.calls += 1
        if self.calls <= self.fail_times:
            raise TransientError("503", retry_after=self.retry_after)
        return "ok"


class RetryTests(unittest.TestCase):
    def test_delays_grow_and_are_capped(self):
        self.assertEqual(list(backoff_delays(1, 5, 6, rng=lambda: 1.0)), [1, 2, 4, 5, 5])

    def test_jitter_stays_below_the_exponential_bound(self):
        for d, bound in zip(backoff_delays(1, 30, 5), [1, 2, 4, 8]):
            self.assertTrue(0 <= d <= bound)

    def test_recovers_after_transient_failures(self):
        slept = []
        fn = Fake(2)
        self.assertEqual(call_with_retry(fn, sleep=slept.append), "ok")
        self.assertEqual(fn.calls, 3)
        self.assertEqual(len(slept), 2)

    def test_gives_up_after_max_attempts(self):
        fn = Fake(10)
        with self.assertRaises(TransientError):
            call_with_retry(fn, attempts=3, sleep=lambda s: None)
        self.assertEqual(fn.calls, 3)

    def test_respects_retry_after(self):
        slept = []
        call_with_retry(Fake(1, retry_after=7), sleep=slept.append)
        self.assertGreaterEqual(slept[0], 7)

    def test_time_budget(self):
        with self.assertRaises(TransientError):
            call_with_retry(Fake(5, retry_after=40), budget=30, sleep=lambda s: None)

    def test_breaker_opens_and_stops_calls(self):
        now = [0.0]
        br = CircuitBreaker(failure_threshold=2, cooldown=10, clock=lambda: now[0])
        fn = Fake(100)
        with self.assertRaises(TransientError):
            call_with_retry(fn, attempts=2, breaker=br, sleep=lambda s: None)
        with self.assertRaises(CircuitOpen):
            call_with_retry(fn, breaker=br, sleep=lambda s: None)
        self.assertEqual(fn.calls, 2)
        now[0] = 11  # cooldown over: one call goes through again
        with self.assertRaises(TransientError):
            call_with_retry(fn, attempts=1, breaker=br, sleep=lambda s: None)


if __name__ == "__main__":
    unittest.main()

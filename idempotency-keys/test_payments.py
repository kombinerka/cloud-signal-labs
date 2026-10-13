import unittest
from concurrent.futures import ThreadPoolExecutor

from payments import PaymentService


class Idempotency(unittest.TestCase):
    def test_retry_does_not_charge_twice(self):
        api = PaymentService()
        a, b = api.pay("k1", "4242", 100), api.pay("k1", "4242", 100)
        self.assertEqual(a["charge"], b["charge"])
        self.assertTrue(b["replayed"])
        self.assertEqual(len(api.charges), 1)

    def test_parallel_retries_charge_once(self):
        api = PaymentService()
        with ThreadPoolExecutor(8) as ex:
            list(ex.map(lambda _: api.pay("k2", "4242", 100), range(20)))
        self.assertEqual(len(api.charges), 1)

    def test_different_keys_are_different_payments(self):
        api = PaymentService()
        api.pay("a", "4242", 100); api.pay("b", "4242", 100)
        self.assertEqual(len(api.charges), 2)


if __name__ == "__main__":
    unittest.main()

"""A tiny payment API that is safe to retry: the client sends an Idempotency-Key, the server remembers the result.
    python3 payments.py        # demo: a timeout, a retry, one charge
"""
import threading
import uuid


class PaymentService:
    def __init__(self):
        self.charges = []                 # what actually hit the card
        self._results = {}                # idempotency key -> stored result
        self._lock = threading.Lock()     # one request per key at a time

    def pay(self, key: str, card: str, amount: int) -> dict:
        with self._lock:
            if key in self._results:      # a retry: same answer, no new charge
                return {**self._results[key], "replayed": True}
            charge = {"id": f"ch_{len(self.charges) + 1}", "card": card, "amount": amount}
            self.charges.append(charge)   # the side effect happens exactly once per key
            self._results[key] = {"status": "paid", "charge": charge["id"]}
            return {**self._results[key], "replayed": False}


def demo():
    api = PaymentService()
    key = str(uuid.uuid4())               # created BEFORE the first attempt, reused for every retry
    first = api.pay(key, "4242", 4999)
    print("first try (response lost in a timeout):", first)
    retry = api.pay(key, "4242", 4999)
    print("retry with the same key:              ", retry)
    print("charges on the card:", len(api.charges))
    print("without a key, the retry is a new payment:", api.pay(str(uuid.uuid4()), "4242", 4999)["charge"])


if __name__ == "__main__":
    demo()

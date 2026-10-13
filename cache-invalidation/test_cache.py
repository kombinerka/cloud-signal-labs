import unittest

from cache import Database, TTLCache, update_price


class Stale(unittest.TestCase):
    def setUp(self):
        self.t = 0.0
        self.db = Database()

    def cache(self, ttl):
        c = TTLCache(self.db, ttl, clock=lambda: self.t)
        c.get("sku-1")
        return c

    def test_stale_until_ttl(self):
        c = self.cache(600)
        update_price(self.db, c, "sku-1", 80, invalidate=False)
        self.t = 10; self.assertEqual(c.get("sku-1"), 100)
        self.t = 601; self.assertEqual(c.get("sku-1"), 80)

    def test_invalidate_on_write_is_fresh(self):
        c = self.cache(600)
        update_price(self.db, c, "sku-1", 80, invalidate=True)
        self.assertEqual(c.get("sku-1"), 80)


if __name__ == "__main__":
    unittest.main()

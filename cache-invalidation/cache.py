"""Stale cache, and the three ways to deal with it. Standard library only.
    python3 cache.py
"""
import time


class Database:
    def __init__(self): self.prices = {"sku-1": 100}
    def get(self, sku): return self.prices[sku]
    def save(self, sku, price): self.prices[sku] = price


class TTLCache:
    """Cache-aside: read from the cache, on a miss read the database and keep a copy for `ttl` seconds."""

    def __init__(self, db: Database, ttl: float, clock=time.monotonic):
        self.db, self.ttl, self.clock, self.store = db, ttl, clock, {}

    def get(self, sku):
        hit = self.store.get(sku)
        if hit and self.clock() < hit[1]:
            return hit[0]                                  # possibly stale until it expires
        value = self.db.get(sku)
        self.store[sku] = (value, self.clock() + self.ttl)
        return value

    def invalidate(self, sku):
        self.store.pop(sku, None)


def update_price(db: Database, cache: TTLCache, sku, price, invalidate: bool):
    db.save(sku, price)
    if invalidate:
        cache.invalidate(sku)                              # next read fetches the new value


if __name__ == "__main__":
    t = [0.0]
    clock = lambda: t[0]
    for label, ttl, inv in (("long TTL, no invalidation", 600, False), ("short TTL", 30, False), ("invalidate on write", 600, True)):
        db = Database(); cache = TTLCache(db, ttl, clock); t[0] = 0
        cache.get("sku-1")                                 # warm the cache: 100
        update_price(db, cache, "sku-1", 80, inv)
        seen = [cache.get("sku-1") for t[0] in (1, 60, 700)]
        print(f"{label:28} price seen at 1 s / 60 s / 700 s after the change: {seen}")

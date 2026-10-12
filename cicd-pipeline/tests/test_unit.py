"""Fast unit tests: run first, catch most mistakes in seconds."""
import unittest

from app.shop import price_with_vat


class Unit(unittest.TestCase):
    def test_vat(self):
        self.assertEqual(price_with_vat(100, 0.19), 119.0)

    def test_rounding(self):
        self.assertEqual(price_with_vat(9.99, 0.07), 10.69)

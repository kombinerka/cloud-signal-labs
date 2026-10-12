#!/usr/bin/env python3
"""Reconcile a FOCUS 1.4 Cost and Usage export with the Invoice Detail dataset. Standard library only.

Joins on InvoiceIssuerName + InvoiceId (the keys FOCUS defines for this), sums BilledCost on both sides
(tax excluded, as invoices list it separately), and checks the difference against the FOCUS rounding tolerance:

    tolerance = max(100 x subunit, sqrt(rows) x 0.5 x subunit)      rows = Cost and Usage rows in the group

Usage:
  python3 reconcile.py cost_and_usage.csv invoice_detail.csv
  python3 reconcile.py sample/cost_and_usage.csv sample/invoice_detail.csv
Exit code 1 if any invoice fails or exists on only one side.
"""
import csv
import math
import sys
from collections import defaultdict
from decimal import Decimal

# Smallest currency unit. Add the currencies you bill in.
SUBUNIT = {"USD": Decimal("0.01"), "EUR": Decimal("0.01"), "GBP": Decimal("0.01"), "JPY": Decimal("1")}


def load(path, label):
    groups = defaultdict(lambda: {"cost": Decimal(0), "rows": 0, "currency": set(), "period": set()})
    with open(path, newline="", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            if r.get("ChargeCategory") == "Tax":
                continue
            inv = (r.get("InvoiceIssuerName") or "").strip(), (r.get("InvoiceId") or "").strip()
            if not inv[1]:
                inv = (inv[0], f"(no InvoiceId yet in {label})")  # open billing period: not invoiced yet
            g = groups[inv]
            g["cost"] += Decimal(r["BilledCost"] or "0")
            g["rows"] += 1
            g["currency"].add(r.get("BillingCurrency", ""))
            g["period"].add((r.get("BillingPeriodStart", "")[:10], r.get("BillingPeriodEnd", "")[:10]))
    return groups


def tolerance(rows, currency):
    sub = SUBUNIT.get(currency, Decimal("0.01"))
    return max(100 * sub, Decimal(str(math.sqrt(rows) * 0.5)) * sub)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    cu, inv = load(sys.argv[1], "cost and usage"), load(sys.argv[2], "invoice detail")
    failed = 0
    print(f"{'issuer':12} {'invoice':14} {'period':23} {'usage':>12} {'invoice':>12} {'diff':>9} {'tolerance':>9}  result")
    for key in sorted(set(cu) | set(inv)):
        a, b = cu.get(key), inv.get(key)
        if key[1].startswith("(no InvoiceId"):
            print(f"{key[0][:12]:12} {'(open period)':14} {'':23} {a['cost']:>12.2f} {'':>12} {'':>9} {'':>9}  OPEN, not invoiced yet")
            continue
        if not a or not b:
            failed += 1
            side = "invoice only" if not a else "usage only"
            amount = (b or a)["cost"]
            print(f"{key[0][:12]:12} {key[1][:14]:14} {'':23} {'' if not a else a['cost']:>12} {'' if not b else b['cost']:>12} {'':>9} {'':>9}  MISSING ({side}, {amount})")
            continue
        currency = next(iter(a["currency"] | b["currency"]))
        diff = abs(a["cost"] - b["cost"])
        tol = tolerance(a["rows"], currency)
        ok = diff <= tol
        failed += not ok
        period = " / ".join(f"{s}..{e}" for s, e in sorted(a["period"]))[:23]
        print(f"{key[0][:12]:12} {key[1][:14]:14} {period:23} {a['cost']:>12.2f} {b['cost']:>12.2f} {diff:>9.2f} {tol:>9.2f}  {'OK' if ok else 'FAIL'}")
    print(f"\n{failed} invoice(s) need attention." if failed else "\nAll invoices reconcile within tolerance.")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())

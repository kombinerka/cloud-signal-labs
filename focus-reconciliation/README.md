# Your usage table is not your invoice (FOCUS 1.4)

Companion code for the Cloud Signal Short **"Your Cloud Usage Table Is Not Your Invoice"**.

Usage data and the payable invoice are different ledgers. FOCUS 1.4 adds the **Invoice Detail** and **Billing
Period** datasets, so normalized Cost and Usage rows can be joined to invoice charges through **InvoiceIssuerName**
and **InvoiceId** (optionally InvoiceDetailId). Reconciliation becomes a controlled join with a rounding tolerance,
instead of a spreadsheet afternoon.

| | File |
|---|---|
| Python, standard library only | [`reconcile.py`](reconcile.py) |
| SQL (DuckDB syntax) | [`reconcile.sql`](reconcile.sql) |
| Sample exports | [`sample/`](sample/): one invoice that matches, one where a credit is on the invoice but missing from usage, and an open billing period |

```bash
python3 reconcile.py sample/cost_and_usage.csv sample/invoice_detail.csv
# Microsoft    (open period)   402.10                               OPEN, not invoiced yet
# Microsoft    INV-2026-08     1504.75   1496.75   8.00   1.00      FAIL
# Microsoft    INV-2026-09     2050.13   2050.13   0.00   1.00      OK
```

## How the check works

1. Exclude tax on both sides (invoices list it separately).
2. Group both datasets by InvoiceIssuerName + InvoiceId and sum BilledCost.
3. Compare with the FOCUS rounding tolerance: `max(100 × subunit, sqrt(rows) × 0.5 × subunit)`, where rows is the
   number of Cost and Usage rows in the group. Usage data carries more decimals than an invoice, so tiny differences
   are expected; a missing credit or charge is not.
4. Rows without an InvoiceId belong to a billing period that isn't invoiced yet. Some providers fill InvoiceId only
   after the period closes.

## Your own data

Export Cost and Usage in FOCUS format from your provider (Azure Cost Management, AWS Data Exports and Google Cloud
offer FOCUS exports). Which FOCUS version and whether an Invoice Detail dataset is available depends on the provider
and its release; check the columns `InvoiceIssuerName`, `InvoiceId` and `BilledCost` exist in both files.

## Sources

- FinOps Foundation: Introducing FOCUS 1.4: https://www.finops.org/insights/introducing-focus-1-4/
- FOCUS 1.4 specification (Invoice Detail, Billing Period, rounding tolerance): https://github.com/FinOps-Open-Cost-and-Usage-Spec/FOCUS_Spec/tree/v1.4/specification

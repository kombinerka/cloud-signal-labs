-- The same check in SQL (DuckDB syntax; adapt the file reads for your warehouse).
--   duckdb -c ".read reconcile.sql"
WITH cu AS (
  SELECT InvoiceIssuerName, InvoiceId, BillingCurrency,
         SUM(BilledCost) AS usage_cost, COUNT(*) AS rows
  FROM read_csv_auto('sample/cost_and_usage.csv')
  WHERE ChargeCategory <> 'Tax' AND InvoiceId IS NOT NULL
  GROUP BY ALL
),
inv AS (
  SELECT InvoiceIssuerName, InvoiceId, SUM(BilledCost) AS invoice_cost
  FROM read_csv_auto('sample/invoice_detail.csv')
  WHERE ChargeCategory <> 'Tax'
  GROUP BY ALL
)
SELECT
  COALESCE(cu.InvoiceIssuerName, inv.InvoiceIssuerName) AS issuer,
  COALESCE(cu.InvoiceId, inv.InvoiceId)                 AS invoice,
  ROUND(cu.usage_cost, 2)                               AS usage_cost,
  inv.invoice_cost,
  ROUND(ABS(COALESCE(cu.usage_cost, 0) - COALESCE(inv.invoice_cost, 0)), 2) AS diff,
  GREATEST(100 * 0.01, SQRT(COALESCE(cu.rows, 0)) * 0.5 * 0.01)            AS tolerance, -- subunit 0.01 (EUR/USD)
  CASE
    WHEN cu.InvoiceId IS NULL OR inv.InvoiceId IS NULL THEN 'MISSING'
    WHEN ABS(cu.usage_cost - inv.invoice_cost) <= GREATEST(1.0, SQRT(cu.rows) * 0.005) THEN 'OK'
    ELSE 'FAIL'
  END AS result
FROM cu
FULL OUTER JOIN inv
  ON cu.InvoiceIssuerName = inv.InvoiceIssuerName AND cu.InvoiceId = inv.InvoiceId
ORDER BY invoice;

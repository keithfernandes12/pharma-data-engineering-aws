-- row_counts_raw.sql
-- Purpose: verify the Glue crawler cataloged every raw table and Athena reads
--          all rows (counts must match the source CSVs).
-- Reads:   pharma_de_raw.*
-- Writes:  query only
-- Expected: financials=489, drug_approvals=722, clinical_trials=599,
--           disease_burden=3310, biotech_funding=1208

SELECT 'pharma_companies_financials' AS tbl, count(*) AS n FROM pharma_companies_financials
UNION ALL SELECT 'drug_approvals',  count(*) FROM drug_approvals
UNION ALL SELECT 'clinical_trials', count(*) FROM clinical_trials
UNION ALL SELECT 'disease_burden',  count(*) FROM disease_burden
UNION ALL SELECT 'biotech_funding', count(*) FROM biotech_funding
ORDER BY tbl;

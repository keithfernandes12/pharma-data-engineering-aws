-- fact_grain_checks.sql
-- Purpose: verify each fact table has the expected grain after the crosswalk
--          joins — in particular that ONLY drug_approvals fanned out (partnered
--          sponsors) and the other joins stayed 1:1 (no accidental row blow-up).
-- Reads:   pharma_de_processed.fact_*
-- Writes:  query only
-- Expected: financials 489; approvals 732 rows / 722 distinct approval_id;
--           trials 599/599; burden 3310; funding 1208/1208.

SELECT 'financials' AS fact, count(*) AS rows, NULL AS distinct_key
FROM pharma_de_processed.fact_financials
UNION ALL
SELECT 'drug_approvals', count(*), count(DISTINCT approval_id)
FROM pharma_de_processed.fact_drug_approvals
UNION ALL
SELECT 'clinical_trials', count(*), count(DISTINCT trial_id)
FROM pharma_de_processed.fact_clinical_trials
UNION ALL
SELECT 'disease_burden', count(*), NULL
FROM pharma_de_processed.fact_disease_burden
UNION ALL
SELECT 'biotech_funding', count(*), count(DISTINCT deal_id)
FROM pharma_de_processed.fact_biotech_funding
ORDER BY fact;

-- company_crosswalk_coverage.sql
-- Purpose: data-quality guard — every distinct company string across all four
--          sources must resolve in the company crosswalk. A non-empty result
--          means an unmapped name (fix the crosswalk before building facts).
-- Reads:   pharma_de_raw.*, pharma_de_processed.company_crosswalk
-- Writes:  query only
-- Expected: 0 rows

SELECT DISTINCT s AS unmapped_name
FROM (
  SELECT sponsor_company      AS s FROM pharma_de_raw.drug_approvals
  UNION SELECT sponsor              FROM pharma_de_raw.clinical_trials
  UNION SELECT acquirer_or_investors FROM pharma_de_raw.biotech_funding
  UNION SELECT company_name         FROM pharma_de_raw.pharma_companies_financials
) x
WHERE s NOT IN (SELECT raw_name FROM pharma_de_processed.company_crosswalk);

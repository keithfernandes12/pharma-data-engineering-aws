-- 32_fact_clinical_trials.sql
-- Purpose: clinical-trials fact (grain = one trial). Trial sponsors are all
--          single companies (no combos), so the crosswalk join stays 1:1.
-- Reads:   pharma_de_raw.clinical_trials, company_crosswalk
-- Writes:  pharma_de_processed.fact_clinical_trials

CREATE TABLE pharma_de_processed.fact_clinical_trials
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/fact_clinical_trials/'
) AS
SELECT
    t.trial_id,
    x.company_name,
    t.year,
    t.completion_date,
    t.therapy_area,
    t.phase,
    t.outcome,
    t.enrollment_n,
    t.duration_months,
    t.estimated_stock_impact_pct,
    t.is_success,
    t.is_failure
FROM pharma_de_raw.clinical_trials t
JOIN pharma_de_processed.company_crosswalk x
    ON x.raw_name = t.sponsor;

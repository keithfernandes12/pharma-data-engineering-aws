-- 30_fact_financials.sql
-- Purpose: company financials fact (grain = one company x year). Financials
--          already use canonical names, so the crosswalk join is 1:1 here;
--          it just attaches the canonical company_name used by dim_company.
-- Reads:   pharma_de_raw.pharma_companies_financials, company_crosswalk
-- Writes:  pharma_de_processed.fact_financials

CREATE TABLE pharma_de_processed.fact_financials
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/fact_financials/'
) AS
SELECT
    x.company_name,
    f.year,
    f.revenue_usd_bn,
    f.operating_margin_pct,
    f.operating_income_usd_bn,
    f.rd_spend_usd_bn,
    f.pipeline_size_est
FROM pharma_de_raw.pharma_companies_financials f
JOIN pharma_de_processed.company_crosswalk x
    ON x.raw_name = f.company_name;

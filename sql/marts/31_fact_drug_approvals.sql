-- 31_fact_drug_approvals.sql
-- Purpose: drug-approvals fact (grain = one approval x co-developer). Joining
--          the crosswalk on sponsor_company FANS OUT partnered sponsors
--          (Pfizer/BioNTech -> two rows) so each partner is credited when
--          slicing by company. approval_id is retained so approval COUNTS can
--          be de-duplicated with COUNT(DISTINCT approval_id).
-- Reads:   pharma_de_raw.drug_approvals, company_crosswalk
-- Writes:  pharma_de_processed.fact_drug_approvals

CREATE TABLE pharma_de_processed.fact_drug_approvals
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/fact_drug_approvals/'
) AS
SELECT
    a.approval_id,
    x.company_name,
    a.year,
    a.approval_date,
    a.drug_name,
    a.drug_type,
    a.therapy_area,
    a.peak_sales_usd_bn_est,
    a.is_blockbuster,
    a.is_mega_blockbuster,
    a.is_real_headline
FROM pharma_de_raw.drug_approvals a
JOIN pharma_de_processed.company_crosswalk x
    ON x.raw_name = a.sponsor_company;

-- 34_fact_biotech_funding.sql
-- Purpose: biotech-funding fact (grain = one deal). The acquirer/investor is
--          resolved to a canonical company via the crosswalk; the target stays
--          free text (1000+ distinct one-off private companies). A LEFT JOIN
--          keeps every deal even if an acquirer somehow didn't resolve.
-- Reads:   pharma_de_raw.biotech_funding, company_crosswalk
-- Writes:  pharma_de_processed.fact_biotech_funding

CREATE TABLE pharma_de_processed.fact_biotech_funding
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/fact_biotech_funding/'
) AS
SELECT
    f.deal_id,
    f.year,
    f.date            AS deal_date,
    x.company_name    AS acquirer_company,
    f.acquirer_or_investors AS acquirer_raw,
    f.target_or_company     AS target_name,
    f.deal_type,
    f.value_usd_bn,
    f.is_megadeal,
    f.is_real_headline
FROM pharma_de_raw.biotech_funding f
LEFT JOIN pharma_de_processed.company_crosswalk x
    ON x.raw_name = f.acquirer_or_investors;

-- 20_dim_company.sql
-- Purpose: conformed company dimension — one row per canonical company, with
--          descriptive attributes and analysis flags. Facts from any source
--          join here via the company crosswalk, so revenue, approvals, trials
--          and deals all slice by the same company.
-- Reads:   pharma_de_raw.pharma_companies_financials (attributes),
--          pharma_de_processed.company_crosswalk (canonical universe)
-- Writes:  pharma_de_processed.dim_company

CREATE TABLE pharma_de_processed.dim_company
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/dim_company/'
) AS
WITH companies AS (
    SELECT DISTINCT company_name
    FROM pharma_de_processed.company_crosswalk
),
attrs AS (
    SELECT
        company_name,
        arbitrary(ticker)        AS ticker,
        arbitrary(country_iso3)  AS country_iso3,
        arbitrary(segment)       AS segment
    FROM pharma_de_raw.pharma_companies_financials
    GROUP BY company_name
)
SELECT
    c.company_name,
    a.ticker,
    a.country_iso3,
    a.segment,
    (c.company_name IN ('Eli Lilly', 'Novo Nordisk'))            AS is_glp1_player,
    (c.company_name IN ('Pfizer', 'Moderna', 'BioNTech'))        AS is_covid_vaccine_player,
    (a.company_name IS NOT NULL)                                 AS has_financials
FROM companies c
LEFT JOIN attrs a ON a.company_name = c.company_name;

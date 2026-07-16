-- 23_dim_region.sql
-- Purpose: region dimension (the 10 IHME regions) with an income tier and a
--          developed/emerging flag for burden-vs-development analysis.
-- Reads:   query-defined seed (VALUES)
-- Writes:  pharma_de_processed.dim_region

CREATE TABLE pharma_de_processed.dim_region
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/dim_region/'
) AS
SELECT region, income_tier, is_developed
FROM (
  VALUES
    ('North America',  'High income',         true),
    ('Western Europe', 'High income',         true),
    ('Oceania',        'High income',         true),
    ('Eastern Europe', 'Upper-middle income', false),
    ('China',          'Upper-middle income', false),
    ('Latin America',  'Upper-middle income', false),
    ('Middle East',    'Upper-middle income', false),
    ('Southeast Asia', 'Lower-middle income', false),
    ('India',          'Lower-middle income', false),
    ('Africa',         'Low income',          false)
) AS t (region, income_tier, is_developed);

-- 22_dim_disease.sql
-- Purpose: disease dimension (the 20 IHME diseases) enriched with the mapped
--          therapy area (from the crosswalk) so burden joins to pipeline/R&D.
-- Reads:   pharma_de_raw.disease_burden (distinct diseases),
--          pharma_de_processed.therapy_area_disease_map
-- Writes:  pharma_de_processed.dim_disease

CREATE TABLE pharma_de_processed.dim_disease
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/dim_disease/'
) AS
SELECT
    d.disease,
    m.therapy_area          AS mapped_therapy_area,
    (m.therapy_area IS NOT NULL) AS has_therapy_area
FROM (SELECT DISTINCT disease FROM pharma_de_raw.disease_burden) d
LEFT JOIN pharma_de_processed.therapy_area_disease_map m
    ON m.disease = d.disease;

-- 33_fact_disease_burden.sql
-- Purpose: disease-burden fact (grain = one year x region x disease). Carries
--          the mapped therapy area (via dim_disease) so burden can be compared
--          against pipeline/R&D by therapy area.
-- Reads:   pharma_de_raw.disease_burden, dim_disease
-- Writes:  pharma_de_processed.fact_disease_burden

CREATE TABLE pharma_de_processed.fact_disease_burden
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/fact_disease_burden/'
) AS
SELECT
    b.year,
    b.region,
    b.disease,
    d.mapped_therapy_area,
    b.dalys_millions,
    b.global_dalys_millions
FROM pharma_de_raw.disease_burden b
LEFT JOIN pharma_de_processed.dim_disease d
    ON d.disease = b.disease;

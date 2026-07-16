-- 11_therapy_area_disease_map.sql
-- Purpose: bridge the two vocabularies. Disease burden keys on `disease` (20
--          IHME diseases); approvals/trials key on `therapy_area` (12 areas).
--          This map lets burden (DALYs) be compared against pipeline/R&D by
--          area — the core of the "burden vs R&D mismatch" analysis.
-- Reads:   query-defined seed (VALUES), grounded in the 20 distinct diseases
-- Writes:  pharma_de_processed.therapy_area_disease_map
--          (disease -> therapy_area). NULL therapy_area = no matching pharma
--          area in this dataset (e.g. injuries) — kept explicit, not force-fit.

CREATE TABLE pharma_de_processed.therapy_area_disease_map
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/therapy_area_disease_map/'
) AS
SELECT disease, therapy_area
FROM (
  VALUES
    ('Cancer',                       'oncology'),
    ('Cardiovascular disease',       'cardiovascular'),
    ('Stroke',                       'cardiovascular'),
    ('Diabetes',                     'metabolic'),
    ('Neurological disorders',       'neurology'),
    ('Alzheimer''s & dementias',     'neurology'),
    ('Mental disorders',             'psychiatry'),
    ('Self-harm',                    'psychiatry'),
    ('Chronic respiratory',          'respiratory'),
    ('Lower respiratory infections', 'respiratory'),
    ('COVID-19',                     'infectious'),
    ('HIV/AIDS',                     'infectious'),
    ('Malaria',                      'infectious'),
    ('Tuberculosis',                 'infectious'),
    ('Diarrheal diseases',           'infectious'),
    ('Liver disease',                'gastrointestinal'),
    ('Kidney disease',               'rare_disease'),
    ('Road injuries',                NULL),
    ('Maternal disorders',           NULL),
    ('Neonatal disorders',           NULL)
) AS t (disease, therapy_area);

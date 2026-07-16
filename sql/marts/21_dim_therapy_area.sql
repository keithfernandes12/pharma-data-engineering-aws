-- 21_dim_therapy_area.sql
-- Purpose: therapy-area dimension (the 12 areas seen in approvals) with a
--          higher-level grouping for roll-ups.
-- Reads:   query-defined seed (VALUES)
-- Writes:  pharma_de_processed.dim_therapy_area

CREATE TABLE pharma_de_processed.dim_therapy_area
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/dim_therapy_area/'
) AS
SELECT therapy_area, therapy_area_label, therapy_area_group
FROM (
  VALUES
    ('oncology',         'Oncology',          'Non-Communicable'),
    ('cardiovascular',   'Cardiovascular',    'Non-Communicable'),
    ('neurology',        'Neurology',         'Non-Communicable'),
    ('metabolic',        'Metabolic',         'Non-Communicable'),
    ('respiratory',      'Respiratory',       'Non-Communicable'),
    ('immunology',       'Immunology',        'Immune & Inflammatory'),
    ('dermatology',      'Dermatology',       'Immune & Inflammatory'),
    ('infectious',       'Infectious Disease','Communicable'),
    ('psychiatry',       'Psychiatry',        'Mental & Behavioral'),
    ('gastrointestinal', 'Gastrointestinal',  'Non-Communicable'),
    ('ophthalmology',    'Ophthalmology',     'Sensory'),
    ('rare_disease',     'Rare Disease',      'Rare & Orphan')
) AS t (therapy_area, therapy_area_label, therapy_area_group);

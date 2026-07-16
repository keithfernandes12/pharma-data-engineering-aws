-- 10_company_crosswalk.sql
-- Purpose: resolve every company string seen across sources to a canonical
--          company name + ticker. Handles (a) short forms (BMS ->
--          Bristol-Myers Squibb, Lilly -> Eli Lilly) and (b) partnered
--          sponsors (Pfizer/BioNTech), which map to TWO rows so each partner
--          is credited when a fact joins through this crosswalk.
-- Reads:   query-defined seed (VALUES) — grounded in the distinct raw strings
-- Writes:  pharma_de_processed.company_crosswalk
--          (raw_name  ->  company_name canonical, ticker)

CREATE TABLE pharma_de_processed.company_crosswalk
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/company_crosswalk/'
) AS
SELECT raw_name, company_name, ticker
FROM (
  VALUES
    -- canonical names map to themselves
    ('Johnson & Johnson',        'Johnson & Johnson',        'JNJ'),
    ('Merck',                    'Merck',                    'MRK'),
    ('Pfizer',                   'Pfizer',                   'PFE'),
    ('Roche',                    'Roche',                    'ROG'),
    ('AbbVie',                   'AbbVie',                   'ABBV'),
    ('AstraZeneca',              'AstraZeneca',              'AZN'),
    ('Novartis',                 'Novartis',                 'NVS'),
    ('Bristol-Myers Squibb',     'Bristol-Myers Squibb',     'BMY'),
    ('Eli Lilly',                'Eli Lilly',                'LLY'),
    ('Bayer',                    'Bayer',                    'BAYN'),
    ('Sanofi',                   'Sanofi',                   'SNY'),
    ('GSK',                      'GSK',                      'GSK'),
    ('Boehringer Ingelheim',     'Boehringer Ingelheim',     NULL),
    ('Takeda',                   'Takeda',                   'TAK'),
    ('Novo Nordisk',            'Novo Nordisk',             'NVO'),
    ('Amgen',                    'Amgen',                    'AMGN'),
    ('Gilead Sciences',          'Gilead Sciences',          'GILD'),
    ('Vertex Pharmaceuticals',   'Vertex Pharmaceuticals',   'VRTX'),
    ('Regeneron',                'Regeneron',                'REGN'),
    ('Moderna',                  'Moderna',                  'MRNA'),
    ('BioNTech',                 'BioNTech',                 'BNTX'),
    ('Biogen',                   'Biogen',                   'BIIB'),
    ('Teva',                     'Teva',                     'TEVA'),
    ('Sun Pharma',               'Sun Pharma',               'SUNPHARMA'),
    ('Hengrui Medicine',         'Hengrui Medicine',         '600276'),
    ('Daiichi Sankyo',           'Daiichi Sankyo',           '4568'),
    ('Abbott Laboratories',      'Abbott Laboratories',      'ABT'),
    ('Medtronic',                'Medtronic',                'MDT'),
    ('Stryker',                  'Stryker',                  'SYK'),
    ('Danaher',                  'Danaher',                  'DHR'),
    -- short forms -> canonical
    ('BMS',                      'Bristol-Myers Squibb',     'BMY'),
    ('Lilly',                    'Eli Lilly',                'LLY'),
    ('Gilead',                   'Gilead Sciences',          'GILD'),
    ('J&J',                      'Johnson & Johnson',        'JNJ'),
    ('Vertex',                   'Vertex Pharmaceuticals',   'VRTX'),
    -- non-financials sponsors seen only in approvals/trials (no ticker mapped)
    ('Acadia',                   'Acadia',                   NULL),
    ('Alkermes',                 'Alkermes',                 NULL),
    ('Allergan',                 'Allergan',                 NULL),
    ('Alnylam',                  'Alnylam',                  NULL),
    ('BioMarin',                 'BioMarin',                 NULL),
    ('Cytokinetics',             'Cytokinetics',             NULL),
    ('Dendreon',                 'Dendreon',                 NULL),
    ('Eisai',                    'Eisai',                    NULL),
    ('Horizon',                  'Horizon',                  NULL),
    ('Incyte',                   'Incyte',                   NULL),
    ('Ionis',                    'Ionis',                    NULL),
    ('Jazz Pharma',              'Jazz Pharma',              NULL),
    ('Karuna',                   'Karuna',                   NULL),
    ('Kite',                     'Kite',                     NULL),
    ('Madrigal',                 'Madrigal',                 NULL),
    ('Mirum',                    'Mirum',                    NULL),
    ('Reata',                    'Reata',                    NULL),
    ('Sarepta',                  'Sarepta',                  NULL),
    ('Servier',                  'Servier',                  NULL),
    ('Travere',                  'Travere',                  NULL),
    ('CRISPR',                   'CRISPR Therapeutics',      'CRSP'),
    -- funding-only acquirers / investors
    ('Actavis',                  'Actavis',                  NULL),
    ('Celgene',                  'Celgene',                  NULL),
    ('Shire',                    'Shire',                    NULL),
    ('ARCH Venture Partners',    'ARCH Venture Partners',    NULL),
    ('Atlas Venture',            'Atlas Venture',            NULL),
    ('Bain Capital Life Sciences','Bain Capital Life Sciences', NULL),
    ('F-Prime Capital',          'F-Prime Capital',          NULL),
    ('Flagship Pioneering',      'Flagship Pioneering',      NULL),
    ('GV (Google Ventures)',     'GV (Google Ventures)',     NULL),
    ('OrbiMed',                  'OrbiMed',                  NULL),
    ('Polaris Partners',         'Polaris Partners',         NULL),
    ('Public markets',           'Public markets',           NULL),
    ('RA Capital',               'RA Capital',               NULL),
    ('Sofinnova Investments',    'Sofinnova Investments',    NULL),
    ('Third Rock Ventures',      'Third Rock Ventures',      NULL),
    ('VC syndicate',             'VC syndicate',             NULL),
    ('Versant Ventures',         'Versant Ventures',         NULL),
    ('a16z Bio',                 'a16z Bio',                 NULL),
    -- partnered sponsors: each combined raw string maps to BOTH partners
    -- (two rows, same raw_name) so a join fans out to credit each company
    ('AbbVie/J&J',               'AbbVie',                   'ABBV'),
    ('AbbVie/J&J',               'Johnson & Johnson',        'JNJ'),
    ('BMS/Pfizer',               'Bristol-Myers Squibb',     'BMY'),
    ('BMS/Pfizer',               'Pfizer',                   'PFE'),
    ('Bayer/J&J',                'Bayer',                    'BAYN'),
    ('Bayer/J&J',                'Johnson & Johnson',        'JNJ'),
    ('Biogen/Eisai',             'Biogen',                   'BIIB'),
    ('Biogen/Eisai',             'Eisai',                    NULL),
    ('Daiichi/AstraZeneca',      'Daiichi Sankyo',           '4568'),
    ('Daiichi/AstraZeneca',      'AstraZeneca',              'AZN'),
    ('Kite/Gilead',              'Kite',                     NULL),
    ('Kite/Gilead',              'Gilead Sciences',          'GILD'),
    ('Pfizer/BioNTech',          'Pfizer',                   'PFE'),
    ('Pfizer/BioNTech',          'BioNTech',                 'BNTX'),
    ('Sanofi/Regeneron',         'Sanofi',                   'SNY'),
    ('Sanofi/Regeneron',         'Regeneron',                'REGN'),
    ('Vertex/CRISPR',            'Vertex Pharmaceuticals',   'VRTX'),
    ('Vertex/CRISPR',            'CRISPR Therapeutics',      'CRSP')
) AS t (raw_name, company_name, ticker);

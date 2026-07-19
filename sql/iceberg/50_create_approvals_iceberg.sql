-- 50_create_approvals_iceberg.sql
-- Purpose: create the incremental-ingestion target as an Apache Iceberg table.
--          Iceberg supports row-level INSERT (append) and transactional writes,
--          so new drug-approval files can be merged into the existing data
--          instead of a full rebuild.
-- Reads:   (schema only)
-- Writes:  pharma_de_processed.approvals_iceberg  (Iceberg table in iceberg/approvals/)

CREATE TABLE IF NOT EXISTS pharma_de_processed.approvals_iceberg (
    approval_id            string,
    approval_date          string,
    year                   int,
    drug_name              string,
    sponsor_company        string,
    drug_type              string,
    therapy_area           string,
    peak_sales_usd_bn_est  double,
    is_blockbuster         int,
    is_mega_blockbuster    int,
    description            string,
    is_real_headline       int
)
LOCATION 's3://pharma-de-datalake-493168377117/iceberg/approvals/'
TBLPROPERTIES (
    'table_type' = 'ICEBERG',
    'format'     = 'parquet'
);

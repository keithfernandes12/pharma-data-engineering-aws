-- 51_seed_approvals_iceberg.sql
-- Purpose: load the existing raw approvals (722 rows) into the Iceberg table as
--          the starting baseline. Incremental loads then append on top of this.
-- Reads:   pharma_de_raw.drug_approvals
-- Writes:  pharma_de_processed.approvals_iceberg  (INSERT)
-- Note:    idempotent guard — only inserts approval_ids not already present, so
--          re-running this seed won't duplicate rows.

INSERT INTO pharma_de_processed.approvals_iceberg
SELECT
    approval_id,
    CAST(approval_date AS varchar) AS approval_date,
    year,
    drug_name,
    sponsor_company,
    drug_type,
    therapy_area,
    peak_sales_usd_bn_est,
    is_blockbuster,
    is_mega_blockbuster,
    description,
    is_real_headline
FROM pharma_de_raw.drug_approvals
WHERE approval_id NOT IN (
    SELECT approval_id FROM pharma_de_processed.approvals_iceberg
);

-- 43_burden_vs_rnd_mismatch.sql
-- Theme D (flagship). Question: which therapy areas are under-served by the
--          pipeline relative to the disease burden they address? Aligns global
--          disease burden (DALYs, via the disease->therapy_area map) against
--          the number of approvals in that therapy area.
-- Reads:   fact_disease_burden, fact_drug_approvals
-- Writes:  pharma_de_processed.rpt_burden_vs_rnd_mismatch
-- Note:    burden is taken at the latest year and summed globally per mapped
--          therapy area (uses the per-disease global total once per year).

CREATE TABLE pharma_de_processed.rpt_burden_vs_rnd_mismatch
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/rpt_burden_vs_rnd_mismatch/'
) AS
WITH latest AS (
    SELECT max(year) AS y FROM pharma_de_processed.fact_disease_burden
),
burden AS (
    -- one global DALY figure per disease for the latest year, rolled to area
    SELECT mapped_therapy_area AS therapy_area,
           sum(global_dalys)   AS global_dalys_millions
    FROM (
        SELECT disease, mapped_therapy_area, max(global_dalys_millions) AS global_dalys
        FROM pharma_de_processed.fact_disease_burden
        WHERE year = (SELECT y FROM latest) AND mapped_therapy_area IS NOT NULL
        GROUP BY disease, mapped_therapy_area
    ) g
    GROUP BY mapped_therapy_area
),
pipeline AS (
    SELECT therapy_area,
           count(distinct approval_id) AS approvals_count,
           sum(peak_sales_usd_bn_est)  AS total_peak_sales_usd_bn
    FROM pharma_de_processed.fact_drug_approvals
    GROUP BY therapy_area
)
SELECT
    coalesce(bu.therapy_area, p.therapy_area) AS therapy_area,
    bu.global_dalys_millions,
    coalesce(p.approvals_count, 0)            AS approvals_count,
    coalesce(p.total_peak_sales_usd_bn, 0)    AS total_peak_sales_usd_bn,
    bu.global_dalys_millions / nullif(p.approvals_count, 0) AS dalys_per_approval
FROM burden bu
FULL OUTER JOIN pipeline p ON p.therapy_area = bu.therapy_area
ORDER BY dalys_per_approval DESC;

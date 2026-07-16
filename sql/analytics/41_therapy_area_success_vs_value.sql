-- 41_therapy_area_success_vs_value.sql
-- Theme B. Question: which therapy areas combine high clinical success with
--          high commercial value? Pairs Phase 2/3 trial success rate against
--          the average peak sales of approvals in the same area.
-- Reads:   fact_clinical_trials, fact_drug_approvals, dim_therapy_area
-- Writes:  pharma_de_processed.rpt_therapy_area_success_vs_value

CREATE TABLE pharma_de_processed.rpt_therapy_area_success_vs_value
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/rpt_therapy_area_success_vs_value/'
) AS
WITH trials AS (
    SELECT therapy_area,
           count(*)                                            AS trials_count,
           sum(CASE WHEN is_success = 1 THEN 1 ELSE 0 END)     AS successes,
           avg(CASE WHEN is_success = 1 THEN 1.0 ELSE 0.0 END) AS success_rate
    FROM pharma_de_processed.fact_clinical_trials
    GROUP BY therapy_area
),
approvals AS (
    SELECT therapy_area,
           count(distinct approval_id)  AS approvals_count,
           avg(peak_sales_usd_bn_est)   AS avg_peak_sales_usd_bn
    FROM pharma_de_processed.fact_drug_approvals
    GROUP BY therapy_area
)
SELECT
    coalesce(ta.therapy_area_label, t.therapy_area, a.therapy_area) AS therapy_area,
    t.trials_count,
    t.success_rate,
    a.approvals_count,
    a.avg_peak_sales_usd_bn
FROM trials t
FULL OUTER JOIN approvals a ON a.therapy_area = t.therapy_area
LEFT JOIN dim_therapy_area ta
    ON ta.therapy_area = coalesce(t.therapy_area, a.therapy_area)
ORDER BY t.success_rate DESC;

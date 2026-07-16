-- 40_rnd_efficiency_by_company.sql
-- Theme A. Question: which companies convert R&D dollars into approved-drug
--          value most efficiently? Compares each company's total R&D spend
--          against the total peak-sales potential of the drugs it got approved.
-- Reads:   fact_financials, fact_drug_approvals, dim_company
-- Writes:  pharma_de_processed.rpt_rnd_efficiency_by_company
-- Note:    approvals are de-duplicated to approval level first (a co-developed
--          drug is split across partners in the fact, so summing peak sales
--          naively would double-count; here each partner keeps a full credit,
--          which is the intended per-company view).

CREATE TABLE pharma_de_processed.rpt_rnd_efficiency_by_company
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/rpt_rnd_efficiency_by_company/'
) AS
WITH rnd AS (
    SELECT company_name, sum(rd_spend_usd_bn) AS total_rnd_usd_bn
    FROM pharma_de_processed.fact_financials
    GROUP BY company_name
),
approvals AS (
    SELECT company_name,
           count(distinct approval_id)       AS approvals_count,
           sum(peak_sales_usd_bn_est)         AS total_peak_sales_usd_bn
    FROM pharma_de_processed.fact_drug_approvals
    GROUP BY company_name
)
SELECT
    c.company_name,
    c.segment,
    r.total_rnd_usd_bn,
    a.approvals_count,
    a.total_peak_sales_usd_bn,
    a.total_peak_sales_usd_bn / nullif(r.total_rnd_usd_bn, 0) AS peak_sales_per_rnd_usd
FROM dim_company c
JOIN rnd r      ON r.company_name = c.company_name
LEFT JOIN approvals a ON a.company_name = c.company_name
WHERE c.has_financials
ORDER BY peak_sales_per_rnd_usd DESC;

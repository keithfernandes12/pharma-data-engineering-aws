-- 42_buy_vs_build.sql
-- Theme C. Question: which big pharma companies "buy" growth (M&A) vs "build"
--          it (internal R&D)? Compares total M&A deal value against total
--          internal R&D spend per company over the window.
-- Reads:   fact_biotech_funding, fact_financials, dim_company
-- Writes:  pharma_de_processed.rpt_buy_vs_build

CREATE TABLE pharma_de_processed.rpt_buy_vs_build
WITH (
  format = 'PARQUET',
  external_location = 's3://pharma-de-datalake-493168377117/processed/tables/rpt_buy_vs_build/'
) AS
WITH ma AS (
    SELECT acquirer_company AS company_name,
           sum(value_usd_bn) AS total_ma_usd_bn,
           count(*)          AS ma_deal_count
    FROM pharma_de_processed.fact_biotech_funding
    WHERE deal_type = 'M&A' AND acquirer_company IS NOT NULL
    GROUP BY acquirer_company
),
rnd AS (
    SELECT company_name, sum(rd_spend_usd_bn) AS total_rnd_usd_bn
    FROM pharma_de_processed.fact_financials
    GROUP BY company_name
)
SELECT
    c.company_name,
    c.segment,
    coalesce(m.total_ma_usd_bn, 0) AS total_ma_usd_bn,
    coalesce(m.ma_deal_count, 0)   AS ma_deal_count,
    r.total_rnd_usd_bn,
    coalesce(m.total_ma_usd_bn, 0) / nullif(r.total_rnd_usd_bn, 0) AS ma_to_rnd_ratio
FROM dim_company c
JOIN rnd r ON r.company_name = c.company_name
LEFT JOIN ma m ON m.company_name = c.company_name
WHERE c.has_financials
ORDER BY ma_to_rnd_ratio DESC;

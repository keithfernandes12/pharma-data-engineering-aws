# DAX Measures

The heavy modelling was done upstream in Athena SQL, so the `rpt_*` tables are
already aggregated (per company or per therapy area). These measures mostly (a)
wrap the pre-computed columns so they aggregate correctly in visuals, and (b)
add a few weighted/total measures the SQL didn't pre-compute.

## How to add a measure

Report view → **Modeling → New measure** (or right-click a table → New measure).
Put each measure on the table named below. Paste the DAX, press ✓.

> ⚠️ Ratio columns (e.g. `peak_sales_per_rnd_usd`, `success_rate`, `ma_to_rnd_ratio`,
> `dalys_per_approval`) are **already per-row ratios** — never `SUM` them. Use
> `AVERAGE` for a per-row view, or recompute a weighted version (given below)
> for correct totals.

---

## Theme A — R&D Efficiency  (table: `rpt_rnd_efficiency_by_company`)

```DAX
Total R&D ($B) = SUM ( rpt_rnd_efficiency_by_company[total_rnd_usd_bn] )

Total Peak Sales ($B) = SUM ( rpt_rnd_efficiency_by_company[total_peak_sales_usd_bn] )

Total Approvals = SUM ( rpt_rnd_efficiency_by_company[approvals_count] )

-- Weighted efficiency (correct at any grain: totals, not an average-of-ratios)
Peak Sales per R&D $ =
DIVIDE ( [Total Peak Sales ($B)], [Total R&D ($B)] )
```

## Theme B — Pipeline & Trials  (table: `rpt_therapy_area_success_vs_value`)

```DAX
Total Trials = SUM ( rpt_therapy_area_success_vs_value[trials_count] )

Total Approvals (TA) = SUM ( rpt_therapy_area_success_vs_value[approvals_count] )

Avg Peak Sales ($B) = AVERAGE ( rpt_therapy_area_success_vs_value[avg_peak_sales_usd_bn] )

-- success_rate is a per-therapy-area ratio; show it directly, don't sum it
Avg Success Rate % = AVERAGE ( rpt_therapy_area_success_vs_value[success_rate] )
```

Format `Avg Success Rate %` as Percentage (it's stored 0–1).

## Theme C — Buy vs Build  (table: `rpt_buy_vs_build`)

```DAX
Total M&A ($B) = SUM ( rpt_buy_vs_build[total_ma_usd_bn] )

Total R&D — MA table ($B) = SUM ( rpt_buy_vs_build[total_rnd_usd_bn] )

Total M&A Deals = SUM ( rpt_buy_vs_build[ma_deal_count] )

-- Weighted buy-vs-build ratio (M&A spend per R&D $), correct at any grain
M&A to R&D Ratio =
DIVIDE ( [Total M&A ($B)], [Total R&D — MA table ($B)] )
```

## Theme D — Burden vs R&D  (table: `rpt_burden_vs_rnd_mismatch`)

```DAX
Total DALYs (M) = SUM ( rpt_burden_vs_rnd_mismatch[global_dalys_millions] )

Total Approvals (Burden) = SUM ( rpt_burden_vs_rnd_mismatch[approvals_count] )

-- Weighted "underfunding" signal: disease burden per approval, across selection
DALYs per Approval =
DIVIDE ( [Total DALYs (M)], [Total Approvals (Burden)] )
```

## Disease-burden detail  (table: `fact_disease_burden`)

For the regional/disease burden page (uses `dim_region`, `dim_disease`):

```DAX
Regional DALYs (M) = SUM ( fact_disease_burden[dalys_millions] )

-- global total is repeated per region-row; take the max to avoid over-counting
Global DALYs (M) = SUM ( fact_disease_burden[global_dalys_millions] )
```

> Note: `global_dalys_millions` repeats the same global figure across regions for
> a given disease/year. If you show it *by disease* use `MAX`/`AVERAGE`, not `SUM`,
> to avoid multiplying by the region count. For "regional" analysis use
> `Regional DALYs (M)` (the per-region `dalys_millions`).

---

## Optional cross-theme measures

```DAX
-- Count of companies in the current filter context (for KPI cards)
Company Count = DISTINCTCOUNT ( dim_company[company_name] )

-- GLP-1 players only (uses the pre-computed flag on dim_company)
GLP-1 Peak Sales ($B) =
CALCULATE ( [Total Peak Sales ($B)], dim_company[is_glp1_player] = TRUE () )

-- COVID-vaccine players only
COVID Peak Sales ($B) =
CALCULATE ( [Total Peak Sales ($B)], dim_company[is_covid_vaccine_player] = TRUE () )
```

## Formatting quick-reference

| Measure | Format |
|---|---|
| `*($B)` money | Decimal, 1–2 dp, prefix `$`, suffix `B` |
| `Avg Success Rate %` | Percentage, 0 dp |
| ratios (`Peak Sales per R&D $`, `M&A to R&D Ratio`, `DALYs per Approval`) | Decimal, 1–2 dp |
| counts | Whole number |

# Page C — Buy vs Build

**Question:** do pharma companies grow by *buying* (M&A) or *building* (internal
R&D)? Who leans which way, and how big is the buy-vs-build gap?

Data: `rpt_buy_vs_build` (30 companies; 16 have M&A activity, 14 are R&D-only)
+ `dim_company` (slicer / segment).

Measures (add — Theme C):
`Total M&A ($B)`, `Total M&A Deals`, `M&A to R&D Ratio`.
Reuse the existing **`Total R&D ($B)`** measure from Page A for the R&D bar —
verified identical per-company to this table's R&D (30 cos, $2,300B, 0 diffs),
so no separate "R&D — MA table" measure is needed.

```DAX
Total M&A ($B)    = SUM ( rpt_buy_vs_build[total_ma_usd_bn] )
Total M&A Deals   = SUM ( rpt_buy_vs_build[ma_deal_count] )
M&A to R&D Ratio  = DIVIDE ( [Total M&A ($B)], [Total R&D ($B)] )
```

Data facts (grounded): total M&A ≈ $1.56T across 190 deals; top "buyers" by
M&A/R&D ratio = Teva 2.3, BMS 1.9 (Celgene), AbbVie 1.8 (Allergan), Sanofi 1.6;
"builders" (low ratio) = Roche 0.8; and 14 companies have **no** M&A at all.

---

## Layout (1280 × 720)

```text
┌───────────────────────────────────────────────────────────────┐
│  Buy vs Build — M&A dealmaking vs internal R&D                  │ title
├──────────┬──────────┬──────────┬──────────┬───────────────────┤
│ Total M&A│ Total R&D│M&A Deals │ M&A:R&D  │ slicer: segment    │ KPI row
│  $1.56T  │  (table) │   190    │  ratio   │ slicer: company    │
├──────────┴──────────┴──────────┴──────────┴───────────────────┤
│   DIVERGING/PAIRED BAR              │   RANKED BAR              │
│   M&A vs R&D spend per company      │   M&A-to-R&D ratio        │
│   (two measures, same company axis) │   (who leans "buy")       │
└──────────────────────────────────────┴──────────────────────────┘
```

## Visuals — form first

### KPI cards (4)
`Total M&A ($B)`, `Total R&D — MA table ($B)`, `Total M&A Deals`, `M&A to R&D Ratio`.

### Main visual — M&A vs R&D per company (the buy-vs-build comparison)
Goal: show two spend types side by side per company. Two clean options — pick one:

- **(a) Clustered horizontal bar (recommended).** Axis =
  `dim_company[company_name]`; two value series = `Total M&A ($B)` and
  `Total R&D — MA table ($B)`. Two bars per company → you literally see buy vs
  build. Filter to **companies with M&A > 0** (Top N or a filter) so the 14
  R&D-only firms don't clutter it — or keep them to make the point that many
  build-only. Colors = slot 1 blue (R&D) + slot 2 orange (M&A). **2 series is
  within the color cap.**
- **(b) Scatter.** X = `Total R&D`, Y = `Total M&A`, dot per company, size =
  `Total M&A Deals`. A 45° line = "buy == build"; above it = net buyers, below =
  net builders. More analytical but needs a reference line (Analytics pane →
  Y = X isn't built-in; approximate or annotate). Use single color.

> ⚠️ One-axis rule: do NOT put M&A and R&D on a dual-axis single chart with two
> y-scales. The clustered bar (same $B scale for both) or the scatter both respect
> this — two measures on ONE shared scale.

### Ranked bar — who leans "buy"
**Horizontal bar.** Axis = `dim_company[company_name]`, value = `M&A to R&D Ratio`,
sorted descending, Top 15, single blue. Reading: ratio > 1 = spent more on deals
than internal R&D (net "buyer"); < 1 = net "builder". Optionally add a constant
line at **1.0** (Analytics pane → Constant line) to mark the buy/build divide.

### Slicers
`dim_company[segment]` (buttons) and `dim_company[company_name]` (dropdown+search).

---

## Notes / gotchas
- `ma_to_rnd_ratio` is a per-company ratio → the KPI card uses the **weighted**
  `M&A to R&D Ratio` measure (`DIVIDE` of the two totals), NOT an average of the
  column, and never `SUM`.
- 14 companies have M&A = 0. Decide: include them (shows "many build-only") or
  filter them out (cleaner comparison). Either is defensible — just be deliberate.
- Two-series bar (M&A + R&D) = exactly slots 1 & 2 (blue + orange) → safe.
- Deferred to polish pass: apply `pharma_theme.json`; set the two bar series to
  blue/orange; add the ratio=1.0 constant line.

## Checks
- No dual-axis chart (two measures share one $B scale, or are two visuals).
- Ratio KPI uses the weighted DIVIDE measure, not a column sum/avg.
- Ranked-ratio bar sorted desc, single hue, horizontal.
- Both visuals react to the slicers.
- If you filter to M&A>0, say so (title or a note) so "16 of 30" isn't hidden.

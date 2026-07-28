# Page D — Burden vs R&D (the flagship "underfunded diseases" page)

**Question:** where does disease burden (DALYs) NOT match the drug pipeline —
i.e. which therapy areas are under-served relative to how much suffering they
cause? And how is burden distributed across regions?

Data:
- `rpt_burden_vs_rnd_mismatch` (12 therapy areas: burden vs approvals) — main story
- `fact_disease_burden` (+ `dim_region`, `dim_disease`) — regional/disease detail

Measures (add — Theme D):
`Total DALYs (M)`, `Total Approvals (Burden)`, `DALYs per Approval`,
`Regional DALYs (M)`.

Grounded facts: most under-served by DALYs/approval — cardiovascular 11.8,
psychiatry 11.5, respiratory 9.1; most-served — oncology 1.0 (280M DALYs but 276
approvals). Regional burden concentrates in Africa (472M), India (438M),
China (403M).

---

## Layout (1280 × 720)

```text
┌───────────────────────────────────────────────────────────────┐
│  Disease Burden vs R&D — where the pipeline doesn't follow need │ title
├──────────┬──────────┬──────────┬───────────────────────────────┤
│Total DALYs│ Approvals│ DALYs /  │  slicer: region                │ KPI row
│   (M)     │ (burden) │ Approval │  slicer: disease group / area  │
├──────────┴──────────┴──────────┴───────────────────────────────┤
│  SCATTER / BAR (the mismatch)      │  REGIONAL BURDEN            │
│  burden vs approvals per area      │  DALYs by region           │
│  → under-served = high burden,     │  (bar or map)              │
│    low approvals                   │                             │
└──────────────────────────────────────┴──────────────────────────┘
```

## Visuals — form first

### KPI cards (3)
`Total DALYs (M)`, `Total Approvals (Burden)`, `DALYs per Approval`.

### Main visual — the mismatch (pick one)
- **(a) Ranked bar — DALYs per Approval by therapy area (recommended, clearest).**
  Horizontal bar; axis = therapy_area; value = `DALYs per Approval`; sorted desc.
  Top = most under-served (cardiovascular, psychiatry). One-glance headline.
  Single blue; 4px rounded ends; value labels.
- **(b) Scatter — burden vs pipeline.** X = `Total Approvals (Burden)`,
  Y = `Total DALYs (M)`, dot per therapy area, (size optional = peak sales).
  Reading: **top-left = under-served** (high burden, few approvals);
  bottom-right = well-served (oncology). Single color + direct-label the 12 dots.
  More analytical; (a) is punchier for a headline.

### Regional burden (right) — uses fact_disease_burden + dim_region
- **Bar:** axis = `dim_region[region]`, value = `Regional DALYs (M)`, sorted desc.
  Shows Africa/India/China leading. Single blue (magnitude), or a **sequential
  blue ramp** by value.
- **Optional upgrade — Filled map:** map visual, Location = `dim_region[region]`,
  color saturation = `Regional DALYs (M)` on the blue sequential ramp. Looks
  great, but region names must geocode (they're broad regions, so a bar is the
  safe choice; try the map and fall back to bar if geocoding is messy).

### Slicers
- `dim_region[region]` (dropdown) — filters the regional view
- `dim_disease[disease_group]` or `dim_therapy_area[therapy_area]` — for drill

---

## Notes / gotchas
- `dalys_per_approval` is a per-area ratio → KPI uses the **weighted**
  `DALYs per Approval` (`DIVIDE` of totals), never a column sum/avg.
- `global_dalys_millions` in the rpt table is already the global figure per area
  (deduped in SQL) → summing across the 12 areas is fine here.
- In `fact_disease_burden`, `dalys_millions` is per region (use `Regional DALYs`);
  `global_dalys_millions` repeats per region — don't SUM that one by region.
- Regional slicer only affects the **regional** visual (it's on the fact); the
  mismatch visual is from the rpt table (therapy-area grain) and won't react to
  a region filter — that's expected. Keep the two stories visually distinct.
- Deferred to polish pass: theme; single-color + direct labels on any scatter;
  horizontal bars; sequential ramp on the regional bar/map.

## Checks
- DALYs/Approval KPI uses the weighted DIVIDE measure.
- Mismatch visual sorted so under-served areas are obvious.
- Regional visual single-hue or sequential ramp (not rainbow).
- Slicers behave (region → regional visual); note the grain split above.

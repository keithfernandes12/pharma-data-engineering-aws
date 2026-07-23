# Page B — Pipeline & Trials

**Question:** which therapy areas combine high clinical success with high
commercial value — and where is the high-risk / high-reward frontier?

Data: `rpt_therapy_area_success_vs_value` (12 rows, one per therapy area)
+ `dim_therapy_area` (slicer / labels).

Measures (add these — Theme B):
`Total Trials`, `Total Approvals (TA)`, `Avg Peak Sales ($B)`, `Avg Success Rate %`.

---

## Layout (1280 × 720)

```text
┌───────────────────────────────────────────────────────────────┐
│  Pipeline & Trials — clinical success vs commercial value       │  title
├───────────┬───────────┬───────────┬───────────────────────────┤
│ KPI Trials│ KPI Appr. │ KPI Avg   │  slicer: therapy_area group │  KPI row
│           │ (TA)      │ Success % │  slicer: therapy_area       │
├───────────┴───────────┴───────────┴───────────────────────────┤
│   SCATTER                          │   RANKED BAR                │
│   success rate  vs  avg peak sales │   Trials by therapy area    │
│   (size = trials_count)            │   (or approvals)            │
└────────────────────────────────────┴────────────────────────────┘
```

## Visuals — form first

### KPI cards (3)
Card visuals: `Total Trials`, `Total Approvals (TA)`, `Avg Success Rate %`.

### Scatter — the headline (risk vs reward)
**Scatter chart.**
- **X:** `Avg Success Rate %`  (clinical success — likelihood a trial works)
- **Y:** `Avg Peak Sales ($B)`  (commercial value if it does)
- **Details (one dot per):** `dim_therapy_area[therapy_area_label]`
- **Size:** `Total Trials` (how much activity)
- Reading: **top-right = the sweet spot** (high success + high value); bottom-right =
  safe but low value; top-left = high value but risky bets (this is where oncology
  lands — lots of trials, lower success, big prizes).
- **Color:** 12 therapy areas > the 3-color scatter cap. Options:
  - **Single color** (blue `#2a78d6`) — recommended; labels carry identity.
  - Direct-label each dot with the therapy-area name instead of a color legend
    (12 dots is few enough to label). Turn on **Category labels**.

### Ranked bar — activity by area
**Horizontal bar chart** (so all 12 area names read cleanly).
- **Y:** `dim_therapy_area[therapy_area_label]`
- **X:** `Total Trials` (or `Total Approvals (TA)` — pick the one not implied by the
  scatter; trials is a good complement)
- Sorted descending, single blue, 4px rounded ends, value labels on.

### Slicers
- `dim_therapy_area[therapy_area_group]` (buttons — few values)
- `dim_therapy_area[therapy_area_label]` (dropdown)

---

## Notes / gotchas
- `success_rate` is a per-area ratio stored 0–1 → use `AVERAGE`, format as %.
  **Never SUM it.**
- Horizontal bar preferred here (12 area labels tilt badly on a vertical bar —
  the same lesson from Page A).
- Deferred to polish pass: apply `pharma_theme.json`; single-color the scatter;
  direct-label the scatter dots.

## Checks
- Scatter ≤ 3 colors (or single + direct labels).
- Bar single-hue, sorted, horizontal.
- Success rate shows as % (0–100), not 0–1 or a summed nonsense value.
- Both visuals react to the therapy-area slicers.

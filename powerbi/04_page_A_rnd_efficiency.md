# Page A — R&D Efficiency

**Question the page answers:** which pharma companies turn R&D spend into the most
approved-drug value — and how does that vary by segment?

Data: `rpt_rnd_efficiency_by_company` (+ `dim_company` for slicers).
Measures: `Total R&D ($B)`, `Total Peak Sales ($B)`, `Total Approvals`,
`Peak Sales per R&D $` (from `03_measures.md`).

---

## Layout (16:9 canvas)

```
┌───────────────────────────────────────────────────────────────┐
│  R&D Efficiency — turning research spend into drug value        │  title
├───────────┬───────────┬───────────┬───────────────────────────┤
│ KPI: Total│ KPI: Total│ KPI: Peak │  slicer: segment          │  KPI row
│ R&D ($B)  │ Peak Sales│ Sales/R&D │  slicer: company (search) │
├───────────┴───────────┴───────────┴───────────────────────────┤
│                              │                                  │
│   SCATTER                    │   RANKED BAR                     │
│   R&D spend  vs  peak sales  │   Top companies by               │
│   (bubble = approvals)       │   Peak Sales per R&D $           │
│                              │                                  │
└──────────────────────────────┴──────────────────────────────────┘
```

## Visuals — form first

### 1. KPI cards (3) — form: hero number
Use the **Card** visual. One each: `Total R&D ($B)`, `Total Peak Sales ($B)`,
`Peak Sales per R&D $`. No color-as-data — big number in primary ink, label in
secondary ink. (A KPI card's job is a single value; don't color it by anything.)

### 2. Scatter — form: two related quantities (the headline)
**Scatter chart.**
- **X axis:** `Total R&D ($B)`
- **Y axis:** `Total Peak Sales ($B)`
- **Details (one dot per):** `dim_company[company_name]`
- **Size (bubble):** `Total Approvals`
- Reading: dots high-and-left = efficient (high sales, low R&D); low-and-right =
  inefficient. This is where Lilly/Novo (GLP-1) and the COVID players pop out.

**Color:** ⚠️ scatter is an "all-pairs" context, so **max 3 categorical colors.**
`dim_company[segment]` has 6 values — do **not** color by all 6 (fails CVD gates).
Choose ONE:
- **(a) Single color** — all dots blue `#2a78d6`; let position + bubble size carry
  the story. Cleanest, always safe. **Recommended.**
- **(b) 3-way grouping** — add a grouping (big_pharma / biotech / other) and color
  those 3 with slots 1-3: blue `#2a78d6`, orange `#eb6834`, aqua `#1baf7a`.
  Needs a grouping column; skip unless you want the segment story on this page.

### 3. Ranked bar — form: magnitude, ordered
**Clustered bar chart** (horizontal).
- **Y axis:** `dim_company[company_name]`
- **X axis:** `Peak Sales per R&D $`
- **Sort:** descending; show **Top N = 15** (Filter pane → Top N on the axis).
- **Color:** magnitude → **single blue** (`#2a78d6`), NOT one color per bar. If you
  want emphasis, use a **sequential blue ramp** by value (light→dark):
  `#cde2fb → #2a78d6 → #0d366b`.
- 4px rounded bar ends; data labels on (values), gridlines recessive.

### 4. Slicers (top-right)
- `dim_company[segment]` — as buttons or dropdown
- `dim_company[company_name]` — dropdown with search
One row, above the charts.

---

## Theme colors to set (Power BI theme / per-visual)

From the validated palette (light surface):

| Role | Hex |
|---|---|
| Categorical slot 1 (primary) | `#2a78d6` (blue) |
| Slot 2 | `#eb6834` (orange) |
| Slot 3 | `#1baf7a` (aqua) |
| Sequential blue (min→max) | `#cde2fb` → `#2a78d6` → `#0d366b` |
| Page background | `#f9f9f7` |
| Card/visual background | `#fcfcfb` |
| Primary text | `#0b0b0b` |
| Secondary/label text | `#52514e` |
| Gridline | `#e1e0d9` |

Tip: set these once via **View → Themes → Customize current theme** (Data colors +
Text/Background), so every visual inherits them.

---

## ⏳ Deferred to the color/polish pass
- Apply `pharma_theme.json` (View → Themes → Browse).
- **Scatter:** make all bubbles a single blue (`#2a78d6`) — currently one color
  per company (rainbow), which is the all-pairs anti-pattern.
- **Bar:** reconcile title vs measure. Decision = plot `Peak Sales per R&D $`
  (the efficiency ratio) so it complements (not duplicates) the scatter's Y-axis.
  If the ratio ranking is dominated by tiny-R&D companies, filter to
  `has_financials = true` or an R&D floor for a fair comparison.
- Consider removing the title text-box background/border (cleaner, matches ref).

## Checks before calling it done
- Scatter uses ≤3 categorical colors (or single color). ✅ the all-pairs cap.
- Ranked bar is single-hue or a sequential ramp — never rainbow.
- Cards carry no data-color.
- Text is in ink tokens, not series colors.
- Sort the bar descending and cap Top N so it's readable.
- Every visual reacts to the two slicers (test by clicking a segment).

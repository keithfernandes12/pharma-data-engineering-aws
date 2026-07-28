# Home / Cover page (landing + navigation)

A cover-style landing page (inspired by a clean SaaS dashboard): big title +
tagline, four icon nav-cards to the theme pages, and a bottom "value props"
strip. **No charts/KPIs** — pure navigation. Make it the **first page**.

Data: none (it's a navigation cover).

---

## Layout (1280 × 720)

```text
┌───────────────────────────────────────────────────────────────┐
│  Pharma & Healthcare Analytics                                  │ title 40pt
│  Smart insights. Better decisions. Stronger pipelines.          │ tagline (accent)
│  An end-to-end AWS pipeline over 17 years of global pharma.     │ desc (muted)
│                                                                 │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐                 │
│  │ [icon] │  │ [icon] │  │ [icon] │  │ [icon] │   4 nav cards    │
│  │ R&D    │  │Pipeline│  │Buy vs  │  │Burden  │                 │
│  │ Effic. │  │& Trials│  │Build   │  │vs R&D  │                 │
│  │ desc…  │  │ desc…  │  │ desc…  │  │ desc…  │                 │
│  │[View →]│  │[View →]│  │[View →]│  │[View →]│                 │
│  └────────┘  └────────┘  └────────┘  └────────┘                 │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ◉ Data Driven  ⛭ Cloud Native  ⚡ SQL Modeled  ⟳ Incremental│  │ value strip
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

## Copy (exact text)

**Title (≈40 pt, bold, `#0b0b0b` or deep navy `#1a1a4b`):**
`Pharma & Healthcare Analytics`

**Tagline (≈16 pt, semibold, accent blue `#2a78d6`):**
`Smart insights. Better decisions. Stronger pipelines.`

**Description (≈11 pt, muted `#898781`):**
`An end-to-end AWS data pipeline over 17 years of global pharma — financials,
drug approvals, clinical trials, M&A, and disease burden.`

### Nav cards
| Card | Title | Description | Button |
|---|---|---|---|
| 1 | R&D Efficiency | Turning research spend into approved-drug value. | View Efficiency → |
| 2 | Pipeline & Trials | Trial success vs commercial value by therapy area. | View Pipeline → |
| 3 | Buy vs Build | M&A dealmaking versus internal R&D investment. | View Deals → |
| 4 | Burden vs R&D | Where the pipeline doesn't match disease burden. | View Burden → |

### Bottom value-props strip
| Icon | Label | Line |
|---|---|---|
| target | Data Driven | Real findings from ~6,300 rows across 5 sources. |
| cloud | Cloud Native | S3 → Glue → Athena, all provisioned with Terraform. |
| database | SQL Modeled | Star schema + entity resolution in Amazon Athena. |
| refresh | Incremental | Apache Iceberg pipeline keeps the data current. |

## Icons (download as PNG, insert as images)
Free sources — grab 64px PNGs, ideally in violet/blue `#4a3aa7`/`#2a78d6`:
- Lucide (lucide.dev), Flaticon, or Tabler Icons.
Suggested glyphs: **bar-chart** (R&D), **flask/vial** (trials), **handshake**
(M&A), **globe/heart-pulse** (burden); strip: **target, cloud, database, refresh**.
Save into a local folder (e.g. `powerbi/assets/`), then Insert → Image per card.

## Build steps (shapes + buttons)

1. **Page background:** Format page → Canvas background → `#f9f9f7` (or a very
   light violet `#f4f3fb` to echo the reference). 0% transparency.
2. **(Optional) decorative blobs:** Insert → Shapes → Circle, fill a pale violet
   `#e7dff2`, no border, send to back, park two partly off-canvas (top-left &
   right) like the reference. Skip if fiddly.
3. **Title / tagline / description:** three text boxes, top-left, per copy above.
   Add a short accent underline under the tagline (a thin rectangle, `#2a78d6`).
4. **Nav card ×4** — each card = group of 4 elements:
   - **Card background:** rounded rectangle, fill `#ffffff`, subtle shadow,
     radius 12, ~270 × 210.
   - **Icon badge:** small rounded square/circle fill `#efeafc`, place the PNG
     icon on it, top-left of the card.
   - **Title** (14 pt semibold) + **description** (10 pt muted) text.
   - **Button:** Insert → Buttons → Blank, fill deep navy `#1a1a4b`, white text
     e.g. "View Efficiency", radius 8. Format → **Action → On → Page navigation
     → Destination = the matching theme page**.
   - Select all 4 elements → **Group** so the card moves as one.
5. **Duplicate** the card group ×3, retarget each button + swap text/icon.
6. **Value-props strip:** one wide rounded rectangle at the bottom; inside, 4
   icon + label + line clusters evenly spaced (dividers optional).
7. **Make it first:** drag this page's tab to the front.
8. **Back-home buttons (optional):** small button on pages A–D → Page navigation
   → this page.

### Card X positions (1280 wide, 4 cards)
~40 gap; card W≈270: Card1 X=40, Card2 X=325, Card3 X=610, Card4 X=895; Y≈235.
Value strip: X=40, Y=600, W=1200, H=90.

## Notes
- Buttons need **Ctrl+click** in Desktop; single click in published/reading view.
- Test every button lands on the right page.
- Apply `pharma_theme.json` first so any data pages match; this page is mostly
  manual shapes so the theme affects it less.
- This is layout assembly (~30–40 elements), not a data visual — take it card by
  card, build ONE perfectly, then duplicate.

## Checks
- Title hierarchy reads: title ≫ tagline > description.
- 4 cards identical in size/style; all buttons navigate correctly.
- Cover is the first page; no data/charts on it (by design).

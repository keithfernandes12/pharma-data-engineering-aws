# Raw Data

The five source CSVs, loaded verbatim into `s3://<bucket>/raw/<dataset>/`.
Source: [Global Healthcare & Pharma 2010-2026](https://www.kaggle.com/datasets/sergionefedov/global-healthcare-and-pharma-2010-2026)
(Kaggle, CC0). ~6,300 rows across 2010-2026. Curated public data.

| File | Rows | Grain | What it holds |
|------|------|-------|---------------|
| `pharma_companies_financials.csv` | 489 | company x year | Revenue, operating margin/income, R&D spend, pipeline size by company |
| `drug_approvals.csv` | 722 | approval | FDA drug approvals: sponsor, therapy area, est. peak sales, blockbuster flags |
| `clinical_trials.csv` | 599 | trial | Trials: sponsor, therapy area, phase, enrollment, outcome, est. stock impact |
| `disease_burden.csv` | 3,310 | year x region x disease | Disability-Adjusted Life Years (DALYs) by disease and world region |
| `biotech_funding.csv` | 1,208 | deal | M&A and funding deals: acquirer/investor, target, value, deal type |

See the [project README](../README.md) for how these are modelled into a star
schema, and [`sql/`](../sql/) for the transformation layer.

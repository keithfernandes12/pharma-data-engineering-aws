# Project Roadmap — Global Healthcare & Pharma Data Engineering on AWS

## Goal

An end-to-end **AWS Data Engineering** project that showcases **SQL** and lands in
a **Power BI** dashboard of real findings. Resume target: Data Engineer (also
BI/Analyst). Cost-sensitive: stay in/near AWS Free Tier, tear down when idle.

## Chosen stack (decided)

| Layer | Choice |
|---|---|
| Storage | **Amazon S3** (raw zone + processed/curated zone) |
| Catalog | **AWS Glue Data Catalog** (crawler over S3) |
| Transform | **AWS Glue PySpark ETL** (clean, crosswalks, star schema) |
| SQL / query | **Amazon Athena** (analytics tables + views via SQL) |
| Orchestration | **Lambda + EventBridge** (simple trigger; Step Functions optional later) |
| Infra as Code | **Terraform** (all resources defined in repo) |
| BI | **Power BI Desktop**, importing from Athena via ODBC connector |
| Region | pick one (e.g. `us-east-1`) and stay in it |

## Architecture

```
 data/*.csv (local, in repo)
      │  aws s3 cp / terraform-managed upload
      ▼
 S3  s3://<bucket>/raw/            (raw CSVs)
      │
      ▼  Glue Crawler → Glue Data Catalog (raw tables)
      │
      ▼  Glue PySpark ETL job
 S3  s3://<bucket>/processed/       (cleaned Parquet: dims, facts, analytics)
      │
      ▼  Glue Crawler / Athena DDL → Catalog (curated tables)
      │
      ▼  Athena SQL  (CTAS + views: crosswalks, joins, analytics tables)
      │
      ▼  Power BI (ODBC import)  →  dashboard (4 themes)

 Lambda + EventBridge: kick off crawler→ETL→crawler on demand / schedule.
 Terraform: S3, Glue (db, crawlers, job), Athena workgroup, IAM, Lambda, EventBridge.
```

## The SQL centerpiece (why this shows real skill)

The 5 files **do not join cleanly** — that's the engineering problem:

1. **Company-name crosswalk** — financials use legal names (`Bristol-Myers Squibb`,
   `Eli Lilly`); approvals/trials use short forms (`BMS`, `Lilly`) and
   **partnered sponsors** (`Pfizer/BioNTech`, `Kite/Gilead`). Build a crosswalk
   dim + split partnered sponsors so both partners get credit.
2. **therapy_area ↔ disease crosswalk** — burden data keys on `disease`; approvals/
   trials key on `therapy_area`. Build a mapping (oncology→Cancer, metabolic→
   Diabetes, infectious→HIV/Malaria/TB/COVID-19, …) to connect burden to pipeline.

With those two dimensions, the cross-file joins and aggregations become the
analytics tables that feed the dashboard.

## Dashboard themes & example questions

- **A — Financials / GLP-1 / COVID:** R&D-spend vs approved-drug peak-sales
  efficiency by company; Lilly/Novo GLP-1 revenue supercycle; Pfizer/Moderna
  COVID revenue vs COVID-19 disease burden.
- **B — Pipeline & Trials:** trial success-rate → peak-sales ratio by therapy
  area; Phase-3 failure risk vs commercial bet; trial outcome → stock impact.
- **C — M&A / Funding:** buy-vs-build (M&A deal value vs internal R&D per
  company); megadeal timing vs revenue inflection.
- **D — Burden vs R&D mismatch:** global DALYs per disease vs pipeline/approvals
  in that therapy area → underfunded diseases (malaria/TB high burden, low pipeline).

## Milestones (each independently verifiable)

**M0 — Local toolchain & guardrails**
- Install & configure AWS CLI (credentials, region).
- Install Terraform.
- **Set an AWS Budget + billing alert FIRST** (cost safety).
- Verify: `aws sts get-caller-identity`, `terraform version`.

**M1 — Storage (Terraform)**
- Terraform: S3 bucket with `raw/` and `processed/` prefixes; block public access.
- Upload the 5 CSVs to `raw/`.
- Verify: files visible in S3.

**M2 — Catalog the raw data**
- Terraform: Glue database + crawler over `raw/`.
- Run crawler; confirm 5 raw tables in the Glue Data Catalog.
- Verify: `SELECT count(*)` on each raw table in **Athena** matches the CSVs.

**M3 — SQL layer (the star of the show)**
- In Athena: build the **two crosswalk tables** and the **dim/fact/analytics
  tables** (CTAS to Parquet in `processed/`, or views). All plain SQL, in repo.
- Verify: spot-check joins (e.g. `Pfizer/BioNTech` credits both; burden maps to
  therapy areas); row counts sensible.

**M4 — Glue PySpark ETL**
- Move the heavier cleaning/normalization into a **Glue PySpark job** (reads
  `raw/`, writes `processed/` Parquet). Athena then queries the curated tables.
- Verify: job succeeds; processed Parquet present; Athena reads it.

**M5 — Orchestration**
- Terraform: **Lambda + EventBridge** to run crawler → ETL → crawler in sequence
  (on demand or scheduled). Keep it simple.
- Verify: one trigger rebuilds the processed layer end-to-end.

**M6 — Power BI dashboard**
- Install Athena ODBC driver; create DSN; connect Power BI (import mode).
- Build the 4-theme report; screenshot into `docs/screenshots/`.
- Verify: measures reconcile against Athena query results.

**M7 — Polish & document**
- README (architecture diagram, how-to-run, cost note, teardown steps, skills).
- `terraform destroy` teardown documented and tested (cost control).

## Cost control (non-negotiable)

- Budget alert set in **M0** before any resource is created.
- Athena at ~6,000 rows scans kilobytes → effectively $0 ($5/TB scanned).
- Don't leave Glue crawlers/jobs running; they bill per run/DPU-hour.
- `terraform destroy` when not actively working on it.

## Notes / open items

- Provisioning = **Terraform** (IaC). Console used only to eyeball results.
- SQL flavor = **Glue PySpark for heavy ETL** + **Athena SQL** for analytics.
- Power BI = **ODBC import** (desktop; no gateway needed for one-time import —
  gateway is only for scheduled cloud refresh, which this project doesn't need).
- Build style = **you run each step, I guide + write the code.**
```

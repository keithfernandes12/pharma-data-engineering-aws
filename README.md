# Pharma Data Engineering on AWS

An end-to-end AWS data engineering project over 17 years of global healthcare and
pharma data (2010–2026). Raw CSVs land in **Amazon S3**, are cataloged with
**AWS Glue** and transformed with **SQL in Amazon Athena** (Glue PySpark for
heavier ETL), all provisioned as code with **Terraform**, and surfaced in a
**Power BI** dashboard of findings.

> 🚧 **Work in progress.** Storage + catalog + SQL query layer are live; ETL,
> orchestration, and the dashboard are next. See progress below.

## Architecture

```text
 data/*.csv ──▶ S3  raw/  ──▶ Glue Crawler ──▶ Glue Data Catalog
                                                     │
                                                     ▼
                                            Amazon Athena (SQL)
                                          crosswalks · dims · facts
                                                     │
                                     Glue PySpark ETL ──▶ S3 processed/ (Parquet)
                                                     │
                                                     ▼
                                            Power BI dashboard
   (all infrastructure defined in Terraform · Lambda+EventBridge orchestration)
```

## Progress

| # | Milestone | Status |
|---|---|---|
| M0 | Toolchain (AWS CLI + Terraform) & a Terraform-managed cost budget | ✅ Done |
| M1 | S3 data lake (raw/processed zones, public-access blocked, versioning) | ✅ Done |
| M2 | Glue database + crawler & Athena workgroup; raw data queryable via SQL | ✅ Done |
| M3 | SQL layer — company & therapy-area crosswalks, dim/fact/analytics tables | ⏳ Next |
| M4 | Glue PySpark ETL → curated Parquet in `processed/` | ⬜ Planned |
| M5 | Orchestration (Lambda + EventBridge) | ⬜ Planned |
| M6 | Power BI dashboard (4 analytics themes) | ⬜ Planned |

**Verified so far:** the crawler registers all 5 source tables and Athena row
counts match the source files exactly (489 / 722 / 599 / 3310 / 1208).

## Data

Five source files (~6,300 rows) covering pharma company financials, FDA drug
approvals, clinical trials, disease burden (DALYs), and biotech funding/M&A.
Source: [Global Healthcare & Pharma 2010–2026](https://www.kaggle.com/datasets/sergionefedov/global-healthcare-and-pharma-2010-2026) (CC0).

The files don't join cleanly — company names differ across files
(`Bristol-Myers Squibb` vs `BMS`, partnered sponsors like `Pfizer/BioNTech`) and
disease burden keys on disease while trials/approvals key on therapy area. The
**SQL centerpiece (M3)** is building crosswalk tables to resolve these, then
joining across all five files into analytics tables.

## Stack

`Amazon S3` · `AWS Glue` · `Amazon Athena` · `Terraform` · `Power BI`

## Repository layout

```text
data/          raw source CSVs
infra/         Terraform (S3, Glue, Athena, IAM, budget) — the whole stack as code
README.md
```

## Running the infrastructure

Requires the AWS CLI (configured credentials) and Terraform.

```bash
cd infra
cp example.tfvars terraform.tfvars   # set your alert email
terraform init
terraform plan                        # preview changes
terraform apply                       # provision S3 + Glue + Athena + budget
```

Load data and catalog it:

```bash
# upload each dataset under its own raw/ prefix (table = prefix, not a file)
aws s3 cp data/drug_approvals.csv s3://<bucket>/raw/drug_approvals/drug_approvals.csv
# … repeat per file …
aws glue start-crawler --name pharma-de-raw-crawler
```

Then query in Athena (workgroup `pharma-de-wg`, database `pharma_de_raw`), e.g.
`SELECT count(*) FROM drug_approvals;`

Tear everything down when idle to stay at ~$0:

```bash
cd infra && terraform destroy
```

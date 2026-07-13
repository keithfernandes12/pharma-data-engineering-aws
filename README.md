# Pharma Data Engineering on AWS

An end-to-end AWS data engineering project over 17 years of global healthcare and
pharma data (2010–2026). Raw CSVs are ingested to **Amazon S3**, transformed with
**AWS Glue** and queried with SQL in **Amazon Athena**, provisioned via
**Terraform**, and visualized in a **Power BI** dashboard.

> 🚧 Work in progress — currently at the setup stage.

## Data

Five source files (~6,300 rows) covering pharma company financials, FDA drug
approvals, clinical trials, disease burden (DALYs), and biotech funding/M&A.
Source: [Global Healthcare & Pharma 2010–2026](https://www.kaggle.com/datasets/sergionefedov/global-healthcare-and-pharma-2010-2026) (CC0).

## Stack

`Amazon S3` · `AWS Glue (PySpark)` · `Amazon Athena` · `Terraform` · `Power BI`

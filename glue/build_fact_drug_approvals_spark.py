"""
Glue PySpark ETL — build the drug-approvals fact with company resolution.

Showcase job: the dataset is small and clean, so the project models data in
Athena SQL (right tool for the size). This one Spark job demonstrates the AWS
Glue PySpark ETL pattern on the most transformation-heavy step — resolving
company names and fanning out co-developed drugs (Pfizer/BioNTech -> two rows).

It mirrors sql/marts/31_fact_drug_approvals.sql, so the Spark output can be
validated against the SQL-built table (both should be 732 rows).

Reads : s3://<bucket>/raw/drug_approvals/
Writes: s3://<bucket>/processed/spark/fact_drug_approvals_spark/  (Parquet)

Job parameters (passed by Glue): --bucket
"""

import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F


# --- company crosswalk (same mapping as the SQL crosswalk) -------------------
# raw_name -> canonical company_name. Partnered sponsors appear TWICE so the
# join fans a combined approval out to one row per partner.
CROSSWALK_ROWS = [
    # canonical names (map to themselves)
    ("Johnson & Johnson", "Johnson & Johnson"), ("Merck", "Merck"),
    ("Pfizer", "Pfizer"), ("Roche", "Roche"), ("AbbVie", "AbbVie"),
    ("AstraZeneca", "AstraZeneca"), ("Novartis", "Novartis"),
    ("Bristol-Myers Squibb", "Bristol-Myers Squibb"), ("Eli Lilly", "Eli Lilly"),
    ("Bayer", "Bayer"), ("Sanofi", "Sanofi"), ("GSK", "GSK"),
    ("Boehringer Ingelheim", "Boehringer Ingelheim"), ("Takeda", "Takeda"),
    ("Novo Nordisk", "Novo Nordisk"), ("Amgen", "Amgen"),
    ("Gilead Sciences", "Gilead Sciences"),
    ("Vertex Pharmaceuticals", "Vertex Pharmaceuticals"),
    ("Regeneron", "Regeneron"), ("Moderna", "Moderna"), ("BioNTech", "BioNTech"),
    ("Biogen", "Biogen"), ("Teva", "Teva"), ("Sun Pharma", "Sun Pharma"),
    ("Hengrui Medicine", "Hengrui Medicine"), ("Daiichi Sankyo", "Daiichi Sankyo"),
    ("Abbott Laboratories", "Abbott Laboratories"), ("Medtronic", "Medtronic"),
    ("Stryker", "Stryker"), ("Danaher", "Danaher"),
    # short forms -> canonical
    ("BMS", "Bristol-Myers Squibb"), ("Lilly", "Eli Lilly"),
    ("Gilead", "Gilead Sciences"), ("J&J", "Johnson & Johnson"),
    ("Vertex", "Vertex Pharmaceuticals"),
    # non-financials sponsors seen in approvals
    ("Acadia", "Acadia"), ("Alkermes", "Alkermes"), ("Allergan", "Allergan"),
    ("Alnylam", "Alnylam"), ("BioMarin", "BioMarin"),
    ("Cytokinetics", "Cytokinetics"), ("Dendreon", "Dendreon"),
    ("Eisai", "Eisai"), ("Horizon", "Horizon"), ("Incyte", "Incyte"),
    ("Ionis", "Ionis"), ("Jazz Pharma", "Jazz Pharma"), ("Karuna", "Karuna"),
    ("Kite", "Kite"), ("Madrigal", "Madrigal"), ("Mirum", "Mirum"),
    ("Reata", "Reata"), ("Sarepta", "Sarepta"), ("Servier", "Servier"),
    ("Travere", "Travere"), ("CRISPR", "CRISPR Therapeutics"),
    # partnered sponsors: two rows each -> fan-out
    ("AbbVie/J&J", "AbbVie"), ("AbbVie/J&J", "Johnson & Johnson"),
    ("BMS/Pfizer", "Bristol-Myers Squibb"), ("BMS/Pfizer", "Pfizer"),
    ("Bayer/J&J", "Bayer"), ("Bayer/J&J", "Johnson & Johnson"),
    ("Biogen/Eisai", "Biogen"), ("Biogen/Eisai", "Eisai"),
    ("Daiichi/AstraZeneca", "Daiichi Sankyo"), ("Daiichi/AstraZeneca", "AstraZeneca"),
    ("Kite/Gilead", "Kite"), ("Kite/Gilead", "Gilead Sciences"),
    ("Pfizer/BioNTech", "Pfizer"), ("Pfizer/BioNTech", "BioNTech"),
    ("Sanofi/Regeneron", "Sanofi"), ("Sanofi/Regeneron", "Regeneron"),
    ("Vertex/CRISPR", "Vertex Pharmaceuticals"), ("Vertex/CRISPR", "CRISPR Therapeutics"),
]


def main():
    args = getResolvedOptions(sys.argv, ["JOB_NAME", "bucket"])
    bucket = args["bucket"]

    sc = SparkContext()
    glue = GlueContext(sc)
    spark = glue.spark_session
    job = Job(glue)
    job.init(args["JOB_NAME"], args)

    raw_path = f"s3://{bucket}/raw/drug_approvals/"
    out_path = f"s3://{bucket}/processed/spark/fact_drug_approvals_spark/"

    # Read raw approvals (Spark infers the CSV schema; header row skipped).
    approvals = (
        spark.read.option("header", "true").option("inferSchema", "true")
        .csv(raw_path)
    )

    # Build the crosswalk as a Spark DataFrame from the seed rows above.
    crosswalk = spark.createDataFrame(CROSSWALK_ROWS, ["raw_name", "company_name"])

    # Resolve + fan out: the join on sponsor_company multiplies partnered
    # approvals into one row per partner (the crosswalk has two rows for them).
    fact = (
        approvals.join(crosswalk, approvals.sponsor_company == crosswalk.raw_name, "inner")
        .select(
            "approval_id",
            "company_name",
            "year",
            "approval_date",
            "drug_name",
            "drug_type",
            "therapy_area",
            "peak_sales_usd_bn_est",
            "is_blockbuster",
            "is_mega_blockbuster",
            "is_real_headline",
        )
    )

    # Single output file — dataset is tiny; avoids many small part files.
    fact.coalesce(1).write.mode("overwrite").parquet(out_path)

    print(f"[showcase] wrote {fact.count()} rows to {out_path}")
    job.commit()


if __name__ == "__main__":
    main()

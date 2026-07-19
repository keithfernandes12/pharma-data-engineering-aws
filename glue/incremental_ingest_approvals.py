"""
Glue PySpark ETL — incremental ingestion of new drug-approval files.

Flow:
  1. Read any CSVs in  s3://<bucket>/landing/drug_approvals/
  2. Append their NEW rows (dedup on approval_id) into the Iceberg table
     pharma_de_processed.approvals_iceberg  (INSERT / append semantics)
  3. Move each processed file to  s3://<bucket>/archive/drug_approvals/
     so it is never reprocessed.

If landing/ is empty, the job exits cleanly (no-op). This is the "keep the
warehouse up to date as new data arrives" pattern — the reason the pipeline is
orchestrated at all.

Job parameters (Glue): --bucket
Iceberg is enabled via the job's --datalake-formats=iceberg argument + the
Spark session config below (Glue catalog as the Iceberg catalog).
"""

import sys

import boto3
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.conf import SparkConf
from pyspark.context import SparkContext

DB = "pharma_de_processed"
TABLE = "approvals_iceberg"
DATASET = "drug_approvals"

APPROVAL_COLS = [
    "approval_id", "approval_date", "year", "drug_name", "sponsor_company",
    "drug_type", "therapy_area", "peak_sales_usd_bn_est", "is_blockbuster",
    "is_mega_blockbuster", "description", "is_real_headline",
]


def list_landing_files(bucket, prefix):
    s3 = boto3.client("s3")
    resp = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    return [o["Key"] for o in resp.get("Contents", []) if o["Key"].endswith(".csv")]


def move_to_archive(bucket, key):
    s3 = boto3.client("s3")
    dest = key.replace("landing/", "archive/", 1)
    s3.copy_object(Bucket=bucket, CopySource={"Bucket": bucket, "Key": key}, Key=dest)
    s3.delete_object(Bucket=bucket, Key=key)
    return dest


def main():
    args = getResolvedOptions(sys.argv, ["JOB_NAME", "bucket"])
    bucket = args["bucket"]
    landing_prefix = f"landing/{DATASET}/"

    # Spark session with Iceberg + Glue catalog wired up.
    conf = SparkConf()
    conf.set("spark.sql.extensions",
             "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions")
    conf.set("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog")
    conf.set("spark.sql.catalog.glue_catalog.warehouse", f"s3://{bucket}/iceberg/")
    conf.set("spark.sql.catalog.glue_catalog.catalog-impl",
             "org.apache.iceberg.aws.glue.GlueCatalog")
    conf.set("spark.sql.catalog.glue_catalog.io-impl",
             "org.apache.iceberg.aws.s3.S3FileIO")

    sc = SparkContext(conf=conf)
    glue = GlueContext(sc)
    spark = glue.spark_session
    job = Job(glue)
    job.init(args["JOB_NAME"], args)

    files = list_landing_files(bucket, landing_prefix)
    if not files:
        print("[incremental] no files in landing/ — nothing to ingest.")
        job.commit()
        return

    print(f"[incremental] found {len(files)} file(s): {files}")

    # Read all landing CSVs.
    landing = (
        spark.read.option("header", "true").option("inferSchema", "true")
        .csv([f"s3://{bucket}/{k}" for k in files])
        .selectExpr(
            "cast(approval_id as string) approval_id",
            "cast(approval_date as string) approval_date",
            "cast(year as int) year",
            "cast(drug_name as string) drug_name",
            "cast(sponsor_company as string) sponsor_company",
            "cast(drug_type as string) drug_type",
            "cast(therapy_area as string) therapy_area",
            "cast(peak_sales_usd_bn_est as double) peak_sales_usd_bn_est",
            "cast(is_blockbuster as int) is_blockbuster",
            "cast(is_mega_blockbuster as int) is_mega_blockbuster",
            "cast(description as string) description",
            "cast(is_real_headline as int) is_real_headline",
        )
    )
    landing.createOrReplaceTempView("landing_approvals")

    before = spark.sql(f"SELECT count(*) c FROM glue_catalog.{DB}.{TABLE}").collect()[0]["c"]

    # Append only approval_ids not already present (idempotent re-runs).
    spark.sql(f"""
        INSERT INTO glue_catalog.{DB}.{TABLE}
        SELECT {", ".join(APPROVAL_COLS)}
        FROM landing_approvals l
        WHERE l.approval_id NOT IN (
            SELECT approval_id FROM glue_catalog.{DB}.{TABLE}
        )
    """)

    after = spark.sql(f"SELECT count(*) c FROM glue_catalog.{DB}.{TABLE}").collect()[0]["c"]
    print(f"[incremental] rows {before} -> {after} (+{after - before})")

    # Archive processed files so they are not reprocessed.
    for key in files:
        dest = move_to_archive(bucket, key)
        print(f"[incremental] archived {key} -> {dest}")

    job.commit()


if __name__ == "__main__":
    main()

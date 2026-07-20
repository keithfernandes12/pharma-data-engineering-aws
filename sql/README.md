# SQL Layer

Every persistent query that builds the pharma data model lives here — the
project's SQL centerpiece. Files are **numbered by run order** so this folder
reads top-to-bottom as documentation of the pipeline, and each file opens with a
**purpose header** (purpose · reads · writes).

All queries target **Amazon Athena** over the Glue Data Catalog.
Databases: `pharma_de_raw` (source tables) → `pharma_de_processed` (curated).

## Layout & run order

| Folder | Prefix | Purpose |
|--------|--------|---------|
| `crosswalks/` | `1x` | Reference tables that resolve join problems (see below) |
| `marts/`      | `2x`–`3x` | Dimensions (`2x`) and facts (`3x`) — the star schema |
| `analytics/`  | `4x` | One query per dashboard question (feeds Power BI) |
| `iceberg/`    | `5x` | Apache Iceberg table for incremental ingestion (create + seed) |
| `checks/`     | —   | Representative verification queries (row counts, spot-checks) |

Run files in ascending numeric order to rebuild the SQL layer from the raw
catalog.

## The two crosswalks (why this layer exists)

The five source files don't join cleanly:

1. **Company crosswalk** — financials use legal names (`Bristol-Myers Squibb`);
   approvals/trials use short forms (`BMS`) and partnered sponsors
   (`Pfizer/BioNTech`). Resolves every name to a canonical company (+ ticker),
   splitting partnered sponsors so each partner is credited.
2. **Therapy-area ↔ disease map** — disease burden keys on `disease`;
   approvals/trials key on `therapy_area`. Maps between them (e.g. oncology →
   Cancer) so burden can be compared against pipeline/R&D.

## File header convention

```sql
-- <nn>_<name>.sql
-- Purpose: <one line>
-- Reads:   <source tables>
-- Writes:  <output table, or "query only">
```

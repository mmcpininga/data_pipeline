# Fetch Rewards Coding Exercise - Analytics Engineer

## Table of Contents

- [Project Overview](#project-overview)  
- [Data Access](#data-access)  
- [Project Setup](#project-setup-linux---debianubuntu)  
- [Project Structure](#project-structure)  

## Project Overview

This project was built as part of the Fetch Rewards Analytics Engineer exercise. The goal was to explore and analyze data from users, receipts, and brands to answer real business questions, assess data quality, and communicate findings clearly to stakeholders.

To start, the original JSON files provided (receipts, users, and brands) were uploaded to a `Google Cloud Storage` bucket. From there, external tables were created in `BigQuery` by linking directly to these files. These raw tables are available in the `source_external` dataset in `Bigquery` and serve as the foundation for the data transformation pipeline. 

The transformation workflow was built using `dbt`, following a medallion architecture that organizes the logic into separate layers: `staging`, `intermediate`, and `marts`:
- Raw (Bronze) – External tables directly linked to raw JSON files stored in Google Cloud Storage (`source_external`).
- Staging & Intermediate (Silver) – Cleaned and standardized data, with transformations applied to prepare for analysis.
- Marts (Gold) – Final models answering specific business questions, structured for reporting and insights.

At the marts layer, a Star Schema design is applied, with fact tables (e.g., `fct_receipts`) linked to dimension tables (e.g., `dim_users`, `dim_brands`) to support efficient analysis and reporting.

This layered approach helps keep the project modular, scalable, and easier to maintain. You can find the ERD diagram that maps the relationships between key tables in [analytics_project/docs/erd.pdf](analytics_project/docs/erd.pdf).

Tables from the raw layer are defined in the [analytics_project/models/source.yml](analytics_project/models/source.yml) file, which includes some basic tests to check for nulls and uniqueness. The other layers (`staging`, `intermediate`, and `marts`) each have their own `schema.yml` files (e.g. [analytics_project/models/staging/schema.yml](analytics_project/models/staging/schema.yml)), where you'll find column-level documentation and other dbt tests. All tests are set to warn severity to surface potential data quality issues without blocking the pipeline.

The final layer, [analytics_project/models/marts/](analytics_project/models/marts/), contains the core business logic. These models were created to directly answer predetermined business questions, such as identifying top brands, comparing user behavior, and evaluating receipt status performance.

Additionally, the [analytics_project/docs/dbt-dag.pdf](analytics_project/docs/dbt-dag.pdf) file provides a visual overview of the dbt models and their relationships. It was exported from the dbt documentation site and serves as a quick reference for understanding the data lineage of the project, showing how models are connected across layers.

As part of the process, I also performed a detailed data quality assessment, which is documented in [analytics_project/docs/data_quality_assessment.md](analytics_project/docs/data_quality_assessment.md). This document highlights key issues like duplicated users, missing brand codes, and receipts without valid users, as well as the decisions made to handle them in a way that aligns with business needs.

To communicate findings clearly to non-technical stakeholders, I also prepared a suggested Slack message in [analytics_project/docs/slack_message_to_stakeholders.md](analytics_project/docs/slack_message_to_stakeholders.md). It summarizes the main insights, highlights key data quality issues encountered during the analysis, and flags open questions that may need further clarification.


### Data Access
This project uses two datasets in BigQuery:
1. Raw external data
- Dataset: `fetch-453421.source_external` ([View in BigQuery Console](https://console.cloud.google.com/bigquery?authuser=1&hl=pt-br&project=fetch-453421&supportedpurview=project&ws=!1m4!1m3!3m2!1sfetch-453421!2ssource_external))

2. Transformed data (dbt models)
- Dataset: `fetch-453421.data_warehouse` ([View in BigQuery Console](https://console.cloud.google.com/bigquery?authuser=1&hl=pt-br&project=fetch-453421&supportedpurview=project&ws=!1m4!1m3!3m2!1sfetch-453421!2sdata_warehouse))


## Project Setup (Linux - Debian/Ubuntu)
Here’s a step-by-step guide to get your environment ready and run the project locally

1. Clone the repository: 
```
git clone <your-repo-url>
cd <your-repo-folder>
```

2. Make sure you have Python 3.10 installed. If not, you can install it with: 
```
sudo apt-get install python3.10
```

3. Create and activate a virtual environment:
```
python3.10 -m venv venv
source venv/bin/activate
```

4. Authenticate with Google Cloud:

Since the project uses public data on BigQuery, authentication can be done using your Google account (no service account needed).

- Install Google Cloud SDK ([instructions here](https://cloud.google.com/sdk/docs/install?hl=pt-br))
- Setup gcloud authentication ([instructions here](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup#local-oauth-gcloud-setup))

5. Install required Python packages:
```
pip install -r requirements.txt
```

6. Create a dbt profile file at `~/.dbt/profiles.yml` with the following content:
Here’s a sample template:
```
analytics_project:
  target: dev # target name
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: fetch-453421
      dataset: data_warehouse
      threads: 1
      timeout_seconds: 300
```

7. Navigate to the project directory:
```
cd analytics_project
```

8. Confirm dbt installation and connection:
```
dbt --version
dbt debug
```
If dbt debug passes, your connection is set up correctly.

9. Install dbt packages 
```
dbt deps
```

10. Run models and tests:
- To run a specific model:
```
dbt run --select <model_name> --target=<target_name>
```
- To run all models:
```
dbt run --target=<target_name>
```
- To run a specific test:
```
dbt test --select <model_name> --target=<target_name>
```
- To run all tests:
```
dbt test --target=<target_name>
```
- To run everything (models and tests):
```
dbt build --target=<name_of_target>
```

11. Generate and view dbt documentation
```
dbt docs generate
dbt docs serve
```
Then open http://localhost:8080 in your browser to view it.


##  Project Structure
```
.
├── .gitignore 
├── README.md 
├── requirements.txt
└── analytics_project/
    |── docs/                                  # Supporting documentation and analysis
    │   ├── data_quality_assessment.md         # Summary of data quality checks and decisions
    │   ├── dbt-dag.pdf                        # Data lineage diagram exported from dbt docs
    │   ├── erd.pdf                            # Entity Relationship Diagram for core tables
    │   └── slack_message_to_stakeholders.md   # Suggested message for stakeholders
    |
    |── models/                                # dbt model folders
    │   ├── staging/                           # Raw sources cleaned and standardized
    │   |  ├── stg_receipts.sql
    │   |  ├── stg_receipt_items.sql
    │   |  ├── stg_users.sql
    │   |  ├── stg_brands.sql
    │   |  └── schema.yml                     # Column-level descriptions and dbt tests
    │   
    │   ├── intermediate/                      # Deduplicated, filtered models
    │   |  ├── dim_brands.sql
    │   |  ├── dim_users.sql
    │   |  ├── fct_receipt_items.sql
    │   |  ├── fct_receipts_finished.sql
    │   |  ├── fct_receipts.sql
    │   |  └── schema.yml                      # Column-level descriptions and dbt tests
    │   
    │   ├── marts/                             # Final answers for business questions
    │   |  ├── q1_mart_top5_brands_by_month.sql
    │   |  ├── q2_mart_top5_brands_monthly_comparison.sql
    │   |  ├── q3_mart_avg_spend_by_status.sql
    │   |  ├── q4_mart_total_items_by_status.sql
    │   |  ├── q5_mart_top_brand_by_spend_new_users.sql
    │   |  ├── q6_mart_top_brand_by_transactions_new_users.sql
    │   |  └── schema.yml                      # Column-level descriptions and dbt tests
    │   
    |   └── source.yml                         # Source definitions and tests
    |
    ├── dbt_project.yml
    └── packages.yml
```
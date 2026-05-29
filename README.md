# 🏠 Airbnb Medallion Data Pipeline | AWS · dbt · Snowflake

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

A production-style **ELT data pipeline** built on the **Medallion Architecture** (Bronze → Silver → Gold) using real-world Airbnb data. The pipeline ingests raw data from **AWS S3**, transforms it using **dbt (data build tool)**, and loads it into **Snowflake** for analytics.

---

## 📐 Architecture Overview

```
AWS S3 (Raw Data)
      │
      ▼
┌─────────────┐
│   BRONZE    │  ← Raw ingestion, no transformations
│  (Sources)  │
└─────────────┘
      │
      ▼
┌─────────────┐
│   SILVER    │  ← Cleaned, typed, validated data
│  (Staging)  │
└─────────────┘
      │
      ▼
┌─────────────┐
│    GOLD     │  ← Business-ready: OBT, Fact tables
│ (Analytics) │
└─────────────┘
```

---

## 🗂️ Project Structure

```
aws_dbt_snowflake_project/
│
├── models/
│   ├── bronze/                  # Raw source models
│   │   ├── bronze_bookings.sql
│   │   ├── bronze_hosts.sql
│   │   ├── bronze_listings.sql
│   │   └── properties.yml
│   │
│   ├── silver/                  # Cleaned & transformed models
│   │   ├── silver_bookings.sql
│   │   ├── silver_hosts.sql
│   │   └── silver_listings.sql
│   │
│   ├── gold/                    # Business-ready models
│   │   ├── ephemeral/
│   │   │   ├── bookings.sql
│   │   │   ├── hosts.sql
│   │   │   └── listings.sql
│   │   ├── fact.sql             # Fact table
│   │   └── obt.sql              # One Big Table (OBT)
│   │
│   └── sources/
│       └── sources.yml
│
├── macros/                      # Reusable Jinja macros
│   ├── generate_schema_name.sql
│   ├── multiply.sql
│   ├── tag.sql
│   └── trimmer.sql
│
├── snapshots/                   # SCD Type-2 snapshots
│   ├── dim_bookings.yml
│   ├── dim_hosts.yml
│   └── dim_listings.yml
│
├── tests/                       # Custom data tests
│   └── source_tests.sql
│
├── analyses/                    # Ad-hoc SQL analyses
│   ├── explore.sql
│   ├── if_else.sql
│   └── loop.sql
│
├── seeds/
├── dbt_project.yml
└── profiles.yml
```

---

## 📊 Dataset — Airbnb

The dataset contains real-world Airbnb data across three domains:

| Table | Description |
|---|---|
| `bookings` | Guest bookings with dates, amounts, status |
| `listings` | Property details — type, room, price, location |
| `hosts` | Host info — superhost status, response rate |

---

## ⚙️ Tech Stack

| Tool | Purpose |
|---|---|
| **AWS S3** | Raw data storage |
| **Snowflake** | Cloud data warehouse |
| **dbt Core** | Data transformation & testing |
| **Jinja2** | Templating inside dbt models |
| **Python** | Environment & orchestration |
| **Git** | Version control |

---

## 🔄 Key dbt Concepts Used

- ✅ **Sources** — defined in `sources.yml` with freshness checks
- ✅ **Materialization** — `table`, `view`, and `ephemeral` models
- ✅ **Jinja Macros** — reusable SQL logic (`tag`, `trimmer`, `multiply`)
- ✅ **Custom Schema Naming** — via `generate_schema_name` macro
- ✅ **Snapshots** — SCD Type-2 for `bookings`, `hosts`, `listings`
- ✅ **Tests** — source-level data quality tests
- ✅ **OBT (One Big Table)** — denormalized gold layer for analytics
- ✅ **Fact Table** — structured gold layer for BI tools

---

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- Snowflake account
- AWS account with S3 access
- dbt Core installed

### Installation

```bash
# Clone the repository
git clone https://github.com/ksoumen/airbnb-medallion-dbt-snowflake.git
cd airbnb-medallion-dbt-snowflake

# Create virtual environment
python -m venv .venv
.venv\Scripts\activate        # Windows
source .venv/bin/activate     # Mac/Linux

# Install dbt with Snowflake adapter
pip install dbt-snowflake
```

### Configure Snowflake Connection

Edit `profiles.yml` with your Snowflake credentials:

```yaml
aws_dbt_snowflake_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account>
      user: <your_username>
      password: <your_password>
      role: <your_role>
      database: AIRBNB
      warehouse: <your_warehouse>
      schema: dev
```

### Run the Pipeline

```bash
cd aws_dbt_snowflake_project

# Test connection
dbt debug

# Install dependencies
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Run snapshots
dbt snapshot

# Generate docs
dbt docs generate
dbt docs serve
```

---

## 📈 Gold Layer Output

The final **OBT (One Big Table)** in the Gold layer joins all three domains:

```sql
-- obt.sql joins:
silver_bookings   -- booking transactions
  ↳ silver_listings  -- property details (on listing_id)
      ↳ silver_hosts    -- host details (on host_id)
```

This produces a single wide table ready for BI tools like Tableau, Power BI, or Metabase.

---

## 🧪 Data Testing

Custom source tests are defined in `tests/source_tests.sql`:

```sql
-- Example: Flag bookings with unusually low amounts
SELECT 1
FROM {{ source('staging', 'bookings') }}
WHERE BOOKING_AMOUNT < 200
```

Tests run with `dbt test` and are configured with `severity = 'warn'`.

---

## 📸 Project Screenshots

> dbt model DAG and Gold layer OBT model with Jinja-templated dynamic SQL joins across Bronze → Silver → Gold layers.

---

## 👤 Author

**Soumen Karmakar**
- GitHub: [@ksoumen](https://github.com/ksoumen)

---

## 📄 License

This project is for educational and portfolio purposes.

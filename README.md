# 🏠 Airbnb Medallion Data Pipeline | AWS · dbt · Snowflake

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

A production-style **ELT data pipeline** built on the **Medallion Architecture** (Bronze → Silver → Gold) using real-world Airbnb data. Raw CSV files are ingested from **AWS S3**, transformed using **dbt Core** with Jinja macros and dynamic SQL, and loaded into **Snowflake** for analytics.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          SNOWFLAKE  ·  Data Warehouse                           │
│                                                                                 │
│  ┌──────────┐        ┌────────────┐   dbt    ┌────────────┐   dbt              │
│  │  AWS S3  │──────▶ │   BRONZE   │ ───────▶ │   SILVER   │ ─────────▶         │
│  │  Source  │        │            │          │            │           │         │
│  │ CSV files│        │ bookings   │          │ bookings   │     ┌─────┴──────┐  │
│  └──────────┘        │ listings   │          │ listings   │     │    GOLD    │  │
│                      │ hosts      │          │ hosts      │     │            │  │
│                      └────────────┘          └────────────┘     │ ┌────────┐ │  │
│                            │                       │            │ │  OBT   │ │  │
│                            │ (tests)               │ (snapshot) │ └────────┘ │  │
│                            ▼                       ▼            │ ┌────────┐ │  │
│                      ┌──────────┐         ┌──────────────┐      │ │  Fact  │ │  │
│                      │  Tests   │         │  Snapshots   │      │ └────────┘ │  │
│                      │ quality  │         │ SCD Type-2   │      └─────┬──────┘  │
│                      └──────────┘         └──────────────┘            │         │
│                                                                        ▼         │
│                                                               ┌──────────────┐  │
│   ┌───────────────────────────┐                              │    GitHub    │  │
│   │   Macros  (Jinja SQL)     │                              │    Version   │  │
│   │ tag · trimmer · multiply  │                              │    Control   │  │
│   └───────────────────────────┘                              └──────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

| Stage | Layer | What happens |
|---|---|---|
| **Ingest** | AWS S3 → Bronze | Raw CSV files loaded as-is, no transformations |
| **Clean** | Bronze → Silver | Type casting, null handling, business rules applied |
| **Serve** | Silver → Gold | Denormalized OBT + Fact table for analytics |
| **Track** | Silver → Snapshots | SCD Type-2 history for bookings, listings, hosts |

---

## 🗂️ Project Structure

```
aws_dbt_snowflake_project/
│
├── models/
│   ├── bronze/                  # Raw source models (views over S3 data)
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
│   ├── gold/                    # Business-ready analytical models
│   │   ├── ephemeral/           # CTEs (no physical table)
│   │   │   ├── bookings.sql
│   │   │   ├── hosts.sql
│   │   │   └── listings.sql
│   │   ├── fact.sql             # Fact table for star schema
│   │   └── obt.sql              # One Big Table — dynamic Jinja JOIN
│   │
│   └── sources/
│       └── sources.yml          # Source definitions with freshness checks
│
├── macros/                      # Reusable Jinja macros
│   ├── generate_schema_name.sql # Custom schema naming logic
│   ├── multiply.sql
│   ├── tag.sql                  # Price tagging macro
│   └── trimmer.sql              # String cleaner macro
│
├── snapshots/                   # SCD Type-2 slowly changing dimensions
│   ├── dim_bookings.yml
│   ├── dim_hosts.yml
│   └── dim_listings.yml
│
├── tests/                       # Custom singular data tests
│   └── source_tests.sql
│
├── analyses/                    # Ad-hoc exploration SQL
│   ├── explore.sql
│   ├── if_else.sql              # Jinja if/else demo
│   └── loop.sql                 # Jinja loop demo
│
├── dbt_project.yml
└── profiles.yml
```

---

## 📊 Dataset — Airbnb

Three interconnected datasets covering real-world Airbnb operations:

| Table | Key Columns | Description |
|---|---|---|
| `bookings` | booking_id, listing_id, guest_id, amount, status | Guest booking transactions |
| `listings` | listing_id, host_id, property_type, city, price_per_night | Property details |
| `hosts` | host_id, host_name, is_superhost, response_rate | Host profiles |

---

## ⚙️ Tech Stack

| Tool | Version | Purpose |
|---|---|---|
| **AWS S3** | — | Raw data storage |
| **Snowflake** | — | Cloud data warehouse |
| **dbt Core** | — | Transformation, testing, docs |
| **Jinja2** | — | Dynamic SQL templating |
| **Python** | 3.8+ | Virtual environment |
| **Git + GitHub** | — | Version control |

---

## 🔄 Key dbt Concepts Used

| Concept | Where used |
|---|---|
| **Sources** | `sources.yml` — with freshness checks |
| **Materializations** | `table`, `view`, `ephemeral` across layers |
| **Jinja Macros** | `tag`, `trimmer`, `multiply`, `generate_schema_name` |
| **Dynamic SQL (OBT)** | `obt.sql` — loop-driven JOIN builder |
| **Snapshots (SCD-2)** | `dim_bookings`, `dim_hosts`, `dim_listings` |
| **Singular Tests** | `source_tests.sql` — booking amount validation |
| **Custom Schema** | `generate_schema_name.sql` macro |

---

## 🥇 Gold Layer — OBT Design

The `obt.sql` model uses a **metadata-driven Jinja loop** to dynamically build multi-table JOINs:

```sql
-- Jinja config drives the entire SELECT + JOIN block
{% set configs = [
    { "table": "silver_BOOKINGS", "columns": "silver_bookings.*", ... },
    { "table": "silver_LISTINGS", "join_condition": "...", ... },
    { "table": "silver_HOSTS",    "join_condition": "...", ... }
] %}

SELECT
    {% for config in configs %}
        {{ config['columns'] }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM ...
    {% for config in configs %}
        {% if loop.first %} {{ config['table'] }}
        {% else %} LEFT JOIN {{ config['table'] }} ON {{ config['join_condition'] }}
        {% endif %}
    {% endfor %}
```

This produces a single wide analytical table joining bookings + listings + hosts.

---

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- Snowflake account
- AWS account with S3 access
- dbt Core installed

### Installation

```bash
# Clone the repo
git clone https://github.com/ksoumen/airbnb-medallion-dbt-snowflake.git
cd airbnb-medallion-dbt-snowflake

# Create and activate virtual environment
python -m venv .venv
.venv\Scripts\activate          # Windows
source .venv/bin/activate        # Mac / Linux

# Install dbt Snowflake adapter
pip install dbt-snowflake
```

### Configure Snowflake Connection

Edit `profiles.yml`:

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
      threads: 4
```

### Run the Pipeline

```bash
cd aws_dbt_snowflake_project

dbt debug          # Test connection
dbt deps           # Install packages
dbt run            # Build all models
dbt test           # Run data quality tests
dbt snapshot       # Run SCD Type-2 snapshots
dbt docs generate  # Generate documentation
dbt docs serve     # Open docs in browser
```

---

## 🧪 Data Quality Tests

```sql
-- source_tests.sql: flag suspiciously low booking amounts
{{ config(severity = 'warn') }}

SELECT 1
FROM {{ source('staging', 'bookings') }}
WHERE BOOKING_AMOUNT < 200
```

Run with:
```bash
dbt test --select source:staging
```

---

## 👤 Author

**Soumen Karmakar**  
GitHub: [@ksoumen](https://github.com/ksoumen)

---

## 📄 License

This project is for educational and portfolio purposes.

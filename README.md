# 📊 Data Warehouse & Analytics Project

/* 4@Blue$Skies&9#Clouds */

🚀 **Comprehensive Data Warehousing & Analytics Solution**<br>
This project demonstrates a complete end-to-end **data warehouse implementation** — from raw data ingestion to actionable business insights. It follows industry best practices in **Data Engineering, ETL, Data-Cleansing, Data Modeling, and Analytics**.

---
## 🖼 Architectural Diagram
<img width="1024" height="1024" alt="image-1" src="https://github.com/user-attachments/assets/207fdd64-5954-4700-91fc-049c3ed4b8e3" />

---

## 📑 Table of Contents

1. [Project Overview](#project-overview)
2. [Project Images](#project-images)
3. [Architecture](#architecture)
4. [Folder Structure](#folder-structure)
5. [Layers and Data Flow](#layers-and-data-flow)
6. [ETL Process](#etl-process)
7. [Quality Checks](#quality-checks)
8. [Stored Procedures](#stored-procedures)
9. [Gold Layer Views](#gold-layer-views)
10. [Usage](#usage)
11. [Business Insights](#business-insights)
12. [Future Enhancements](#future-enhancements)
13. [License](#license)

---

## 📖 Project Overview
![image-2](https://github.com/user-attachments/assets/ea04bb58-c22c-49f5-b274-53165e3f64ed)

**Purpose:** Build a modern data warehouse using **Medallion Architecture** for CRM & ERP systems.

**Highlights:**

* 🗄 **Data Architecture** – Bronze, Silver, and Gold layers.
* ⚙ **ETL Pipelines** – Extract, Transform, Load from multiple source systems.
* 📐 **Data Modeling** – Build fact and dimension tables for analytical queries.
* 📊 **Analytics & Reporting** – SQL-based insights for business decisions.

This repository contains scripts for **Bronze, Silver, and Gold layers**, along with **quality checks** and **ETL loading procedures**.

---


## 🛠 Tools & Technologies

* 📂 **Datasets:** CSV files from CRM and ERP sources.
* 🗄 **SQL Server Express:** Database hosting for the warehouse.
* 🖥 **SSMS:** SQL Server Management Studio for querying and management.
* 🛠 **Git & GitHub:** Version control and collaboration.
* 📐 **Draw.io:** ER diagrams and data flow visualization.
* 🗒 **Notion:** Project planning, templates, and documentation.

---

## 🏛 Architecture

```
Bronze Layer (Raw Data)
       |
       v
Silver Layer (Cleansed & Enriched)
       |
       v
Gold Layer (Dimensions + Fact Tables / Star Schema)
       |
       v
Analytics & Reporting
```

---

## 📁 Folder Structure

```
C:.
├───datasets
│   ├───source_crm
│   └───source_erp
├───docs
├───draw_io_diagrams
├───ETL_applied
├───project_planning_notion
├───quality_tests
├───sql_scripts
│   ├───bronze
│   ├───silver
│   └───gold
└───understading_data
```

* **datasets/source_crm & source_erp:** Raw CSV/Excel files from CRM and ERP systems
* **docs:** Documentation files, project briefs
* **draw_io_diagrams:** ER diagrams and data flow diagrams
* **ETL_applied:** Scripts or notebooks demonstrating ETL transformations
* **project_planning_notion:** Project planning and timelines
* **quality_tests:** SQL scripts and reports for data quality checks
* **sql_scripts:** All SQL scripts for Bronze, Silver, and Gold layers
* **understading_data:** Notes, observations, or data profiling results

---

## 🥉 Bronze Layer

* **Purpose:** Raw ingestion from CRM and ERP systems
* **Tables:**

  * `crm_cust_info` – Customer details
  * `crm_prd_info` – Product information
  * `crm_sales_details` – Sales transactions
  * `erp_cust_az12` – ERP customer master
  * `erp_loc_a101` – Location master
  * `erp_px_cat_g1v2` – Product category master
* **Data Characteristics:** May contain duplicates, nulls, inconsistent formats

---

## 🥈 Silver Layer

* **Purpose:** Cleansed and standardized dataset
* **Actions Performed:**

  * Remove duplicates and null primary keys
  * Trim unwanted spaces
  * Standardize marital status and gender
  * Handle invalid dates and negative values
  * Map ERP codes to descriptive values
* **Tables:** Mirrors Bronze tables with transformed data

---

## 🥇 Gold Layer

* **Purpose:** Analytics-ready star schema
* **Views:**

  * `dim_customers` – Enriched customer dimension
  * `dim_products` – Product dimension with category mapping
  * `fact_sales` – Sales fact table linking customers and products
* **Features:**

  * Surrogate keys for analytics
  * Filter out historical or invalid records
  * Consolidated facts ready for reporting

---

## ETL Process

1. **Extraction:** Read raw data from Bronze tables
2. **Transformation:**

   * Deduplicate using `ROW_NUMBER()`
   * Normalize string fields (trim spaces, standardize codes)
   * Handle nulls, missing values, invalid dates
   * Map codes to human-readable values
3. **Load:** Populate Silver tables using stored procedures
4. **Gold Layer:** Generate analytical views using joins and transformations

---

## Quality Checks

* **Bronze Layer:** Validate primary keys, detect spaces, check date ranges, standardize codes
* **Silver Layer:** Confirm uniqueness, validate calculations, ensure field consistency
* **Gold Layer:** Confirm dimensional integrity, validate fact tables, filter historical/invalid data

---

## Stored Procedures

### `silver.load_silver`

* Truncates Silver tables before loading
* Loads data from Bronze with transformations:

  * `crm_cust_info` → Cleanses and normalizes customer data
  * `crm_prd_info` → Maps product lines, calculates end dates
  * `crm_sales_details` → Recalculates sales, derives missing prices
  * `erp_cust_az12` → Standardizes gender, filters future birthdates
  * `erp_loc_a101` → Maps country codes
  * `erp_px_cat_g1v2` → Loads product categories
* Includes timing logs for monitoring ETL performance
* Handles errors using `TRY...CATCH`

---

## Gold Layer Views

| View Name       | Description                                          |
| --------------- | ---------------------------------------------------- |
| `dim_customers` | Consolidated customer data from CRM + ERP + location |
| `dim_products`  | Product dimension with category and line mapping     |
| `fact_sales`    | Sales fact table linking products and customers      |

---

## Usage

1. **Create Bronze tables and load raw data**
2. **Run Silver ETL:**

```sql
EXEC silver.load_silver;
```

3. **Query Gold views for analytics:**

```sql
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;
```

4. **Run quality checks periodically**

---

## Business Insights

* 👥 **Customer Behavior:** Purchasing patterns & segmentation
* 📦 **Product Performance:** Bestsellers, low performers, and trends
* 📈 **Sales Trends:** Time-based revenue and growth insights

---

## Future Enhancements

* Automate ETL scheduling using SQL Agent
* Implement incremental loads for Silver and Gold layers
* Add additional dimensions (Time, Location)
* Create Gold layer physical tables for faster BI performance
* Add data validation reports to monitor KPIs

---

## License

🛡 Licensed under the **MIT License** — you are free to use, modify, and share with proper attribution.

---

**Author:** theBappy<br>
**Date:** 2025-12-01<br>
**Project:** Data Warehouse with MSSQL Server


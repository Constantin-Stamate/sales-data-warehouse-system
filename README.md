# Sales Data Warehouse System

## Overview

Sales Data Warehouse System is a complete ETL and analytics platform designed to load, clean, and transform sales data from CSV files of varying sizes into a structured Data Warehouse, ready for BI reporting and dashboarding.

## Features

- **Data Loading**: Import CSV sales files of different volumes (100 rows, monthly, multi-month, yearly) into a SQL Server staging layer.
- **Staging Layer**: Temporary storage for raw imported data before validation and transformation.
- **Data Validation**: Type checking, format normalization, and error handling during processing.
- **Overlap Handling**: Detects and prevents duplicate records when the same or overlapping data is re-imported.
- **Data Enrichment**: Adds derived attributes to raw records to support deeper analysis.
- **Data Warehouse**: Star-schema design with dimension and fact tables, populated from the staging layer through stored procedures.
- **Presentation Layer**: SQL Views prepared for analytics, including customer segmentation and anomaly detection.
- **ETL Orchestration**: Automated pipeline scheduling and execution via Apache Airflow.
- **File Archiving**: Processed CSV files are automatically archived with a timestamp to prevent reprocessing.
- **BI-Ready Output**: Enriched views designed for direct consumption in Power BI.

## Technologies

- **Database**: Microsoft SQL Server
- **ETL Orchestration**: Apache Airflow
- **Metadata Store**: PostgreSQL
- **Data Processing**: Python
- **Containerization**: Docker Compose
- **Visualization**: Power BI
- **Version Control**: Git, GitHub

## Installation

To install the application, follow these steps:
 
1. **Clone this repository:**
```bash
   git clone https://github.com/Constantin-Stamate/sales-data-warehouse-system
```

2. **Navigate to the project directory:**
```bash
   cd sales-data-warehouse-system
```

3. **Create the database structure:**
```bash
   # Run in SQL Server, in order, the scripts from database/ddl (01_create_database.sql to 05_create_fact_tables.sql)
```

4. **Run the data import:**
```bash
   python import_sales_data.py
```

5. **Load and prepare the data:**
```bash
   # Run in SQL Server the scripts from database/procedures, database/views and database/scripts
```

6. **Start the Airflow & Postgres services (Docker):**
```bash
   docker-compose up -d
```

The Airflow UI will be available at `http://localhost:8080`.

## Resources

- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Airflow DAGs Concepts](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html)
- [Data Warehouse Concepts (Microsoft Learn)](https://learn.microsoft.com/en-us/azure/architecture/data-guide/relational-data/data-warehousing)

## Contributors

**Sales Data Warehouse System** was developed as part of the UTM 2026 DB Contest. This project welcomes contributions from developers interested in improving the ETL logic, adding new analytical views, or extending the data model.

- GitHub: [Constantin-Stamate](https://github.com/Constantin-Stamate)
- Email: constantinstamate.r@gmail.com
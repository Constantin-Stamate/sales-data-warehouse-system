from airflow import DAG
from airflow.operators.python import PythonOperator # type: ignore
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook

from datetime import datetime
from pathlib import Path
import sys

PIPELINE_DIR = Path("/opt/airflow/pipeline")
sys.path.append(str(PIPELINE_DIR))

from import_sales_data import load_sales_data

def import_csv_data():
    """
    Import CSV file into staging.Sales_Raw
    """

    load_sales_data()

def process_sales_data():
    """
    Execute SQL ETL procedure
    """

    hook = MsSqlHook(mssql_conn_id="sales_analytics_db")
    hook.run("EXEC staging.usp_ProcessAndLoadData;")

default_args = {
    "owner": "sales-data-warehouse",
    "start_date": datetime(2026, 7, 30),
    "retries": 1
}

with DAG(
    dag_id="sales_data_import_pipeline",
    default_args=default_args,
    description="Sales CSV import and warehouse loading pipeline",
    schedule="@daily",
    catchup=False
) as dag:
    import_sales_csv = PythonOperator(task_id="import_sales_csv", python_callable=import_csv_data)
    load_datawarehouse = PythonOperator(task_id="load_datawarehouse", python_callable=process_sales_data)

    import_sales_csv >> load_datawarehouse
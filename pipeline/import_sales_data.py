import os
import shutil
from datetime import datetime
from pathlib import Path
import urllib

import pandas as pd
from sqlalchemy import create_engine

DEFAULT_DATA_DIR = Path(__file__).resolve().parent.parent / "data"
DEFAULT_ARCHIVE_DIR = DEFAULT_DATA_DIR / "archive"

DEFAULT_CONN = (
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=localhost;"
    "Database=SalesAnalyticsDB;"
    "Trusted_Connection=yes;"
)

FILE_NAME = "Export_Wiz_1_100.csv"
TABLE_NAME = "Sales_Raw"
SCHEMA_NAME = "staging"

def archive_file(file_path: Path, archive_dir: Path):
    archive_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    destination = archive_dir / f"{file_path.stem}_{timestamp}{file_path.suffix}"

    shutil.move(str(file_path), str(destination))

    print(f"[ARCHIVE] {destination}")


def create_sql_engine(connection_string: str):
    params = urllib.parse.quote_plus(connection_string)

    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}", fast_executemany=True)


def load_sales_data(source_dir=None, archive_dir=None, connection_string=None):
    source_dir = Path(source_dir or os.getenv("INPUT_DIR", DEFAULT_DATA_DIR))
    archive_dir = Path(archive_dir or os.getenv("ARCHIVE_DIR", DEFAULT_ARCHIVE_DIR))
    connection_string = connection_string or os.getenv("MSSQL_CONN_STR", DEFAULT_CONN)

    file_path = source_dir / FILE_NAME

    if not file_path.exists():
        print(f"[SKIP] {FILE_NAME} was not found.")
        return

    print(f"[START] Loading {FILE_NAME}")

    engine = create_sql_engine(connection_string)
    df = pd.read_csv(file_path, dtype=str, keep_default_na=False, encoding="cp1251")

    try:
        df = df.map(lambda x: x.strip() if isinstance(x, str) else x)
    except AttributeError:
        df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

    df["SourceFileName"] = file_path.name

    df.to_sql(TABLE_NAME, schema=SCHEMA_NAME, con=engine, if_exists="append", index=False, chunksize=10000)
    print(f"[SUCCESS] Inserted {len(df)} rows into {SCHEMA_NAME}.{TABLE_NAME}")

    archive_file(file_path, archive_dir)
    print("[DONE]")


if __name__ == "__main__":
    load_sales_data()
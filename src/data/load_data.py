from dotenv import load_dotenv
import os
import pandas as pd
from sqlalchemy import create_engine
from config import db_cities, db_infant_mortality, db_join

load_dotenv()


def get_engine():
    engine = create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )
    return engine


def load_data() -> pd.DataFrame:
    engine = get_engine()

    with engine.connect() as connection:
        cities_df = pd.read_sql(f"SELECT * FROM {db_cities}", connection)
        infant_mortality_df = pd.read_sql(
            f"SELECT * FROM {db_infant_mortality}", connection
        )
        df = pd.merge(cities_df, infant_mortality_df, on=db_join)
    return df

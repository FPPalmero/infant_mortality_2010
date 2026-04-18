import pandas as pd
from src.config import cols_to_drop, float_to_int_cols, outlier_threshold


def drop_columns(df: pd.DataFrame) -> pd.DataFrame:
    return df.drop(columns=cols_to_drop)


def fix_dtypes(df: pd.DataFrame) -> pd.DataFrame:
    df[float_to_int_cols] = df[float_to_int_cols].astype("Int64")
    return df


def remove_outliers(df: pd.DataFrame) -> pd.DataFrame:
    return df.query("infant_mortality_rate < @outlier_threshold")


def fill_nulls(df: pd.DataFrame) -> pd.DataFrame:
    return df.fillna(df.median(numeric_only=True).round(0).astype(int))


def preprocess_data(df: pd.DataFrame) -> pd.DataFrame:

    df = drop_columns(df)
    df = fix_dtypes(df)
    df = remove_outliers(df)
    df = fill_nulls(df)

    return df

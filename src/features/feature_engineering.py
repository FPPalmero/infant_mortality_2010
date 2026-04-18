import pandas as pd
from config import pct_cols, cols_to_1000_pop, region_map


def scale_cols(df: pd.DataFrame) -> pd.DataFrame:

    df[pct_cols] = df[pct_cols].div(df["total_births"], axis=0) * 100
    df[cols_to_1000_pop] = df[cols_to_1000_pop].div(df["total_births"], axis=0) * 1000

    return df.reset_index(drop=True)


def remove_invalid_pct_rows(df: pd.DataFrame) -> pd.DataFrame:
    return df[df[pct_cols].le(100).all(axis=1)].reset_index(drop=True)


def add_region(df: pd.DataFrame) -> pd.DataFrame:

    df = df.copy()
    df["region"] = df["state_code"].map(region_map)

    return df


def feature_engineering(df: pd.DataFrame) -> pd.DataFrame:

    df = scale_cols(df)
    df = remove_invalid_pct_rows(df)
    df = add_region(df)

    return df

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import Ridge
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

from src.config import (
    cols_to_drop_before_split,
    cat_cols,
    target,
    test_size,
    random_state,
    multicollinear_cols,
    model_path,
    fine_tuning_params,
)


def split_model_data(df: pd.DataFrame):

    X = df.drop(cols_to_drop_before_split)
    y = df[target]

    return X, y


def remove_multicollinear_cols(X: pd.DataFrame) -> list:

    num_cols = X.drop(multicollinear_cols, axis=1).columns.tolist()

    return num_cols


def build_preprocessor(num_cols: list) -> ColumnTransformer:

    preprocessor = ColumnTransformer(
        transformers=[
            ("ohe", OneHotEncoder(handle_unknown="ignore"), cat_cols),
            ("num", StandardScaler(), num_cols),
        ]
    )

    return preprocessor


def train(df: pd.DataFrame):

    X, y = split_model_data(df)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state
    )

    num_cols = remove_multicollinear_cols(X)

    preprocessor = build_preprocessor(num_cols)

    pipeline = Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("model", Ridge(random_state=random_state)),
        ]
    )

    grid_search = GridSearchCV(
        estimator=pipeline,
        param_grid=fine_tuning_params,
        cv=5,
        n_jobs=-1,
        verbose=2,
    )

    grid_search.fit(X_train, y_train)

    model = grid_search.best_estimator_

    joblib.dump(model, model_path)

    return model


def load_model():
    return joblib.load(model_path)

import numpy as np
import pandas as pd
from sklearn.dummy import DummyRegressor
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split

from src.config import random_state, target, test_size, cols_to_drop_before_split
from src.models.schemas import EvaluationResponse


def evaluate_model(model, df: pd.DataFrame) -> EvaluationResponse:

    X = df.drop(columns=cols_to_drop_before_split)
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state
    )

    y_pred_train = model.predict(X_train)
    y_pred_test = model.predict(X_test)

    r2_train = f"{r2_score(y_train, y_pred_train):.4f}"
    r2_test = f"{r2_score(y_test, y_pred_test):.4f}"

    dummy = DummyRegressor(strategy="mean").fit(X_train, y_train)

    rmse_dummy = f"{np.sqrt(mean_squared_error(y_test, dummy.predict(X_test))):.4f}"
    rmse_model = f"{np.sqrt(mean_squared_error(y_test, y_pred_test)):.4f}"

    rmse_gap = (1 - float(rmse_model) / float(rmse_dummy)) * 100
    rmse_gap = f"{rmse_gap:.2f} %"

    return EvaluationResponse(
        r2_train=r2_train,
        r2_test=r2_test,
        rmse_dummy=rmse_dummy,
        rmse_model=rmse_model,
        rmse_gap=rmse_gap,
    )

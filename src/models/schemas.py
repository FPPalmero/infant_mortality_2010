from pydantic import BaseModel


class EvaluationResponse(BaseModel):
    r2_train: float
    r2_test: float
    rmse_dummy: float
    rmse_model: float
    rmse_gap: str

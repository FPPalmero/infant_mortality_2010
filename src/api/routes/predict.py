from fastapi import APIRouter
from src.ml.predict import predict
from src.models.schemas import PredictionRequest, PredictionResponse


router = APIRouter(
    prefix="/predict",
    tags=["Predict"],
)


@router.post(
    "",
    description="Predict infant mortality rate based on custom params",
    response_model=PredictionResponse,
)
def predict_route(request: PredictionRequest):
    return predict(request)

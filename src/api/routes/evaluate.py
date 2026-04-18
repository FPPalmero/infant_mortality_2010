from fastapi import APIRouter

from src.api.dependencies import model, df
from src.ml.evaluate import evaluate_model
from src.models.schemas import EvaluationResponse

router = APIRouter(
    prefix="/evaluate",
    tags=["Evaluate"],
)


@router.get(
    "",
    description="Endpoint to evaluate the model performance",
    response_model=EvaluationResponse,
)
def evaluate():
    return evaluate_model(model, df)

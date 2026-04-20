from fastapi import FastAPI
from src.api.routes import evaluate
from src.api.routes import predict

app = FastAPI(
    title="Infant Mortality Prediction API",
    description="API for predicting and evaluating infant mortality rates based on socioeconomic and health indicators",
)

app.include_router(evaluate.router)
app.include_router(predict.router)

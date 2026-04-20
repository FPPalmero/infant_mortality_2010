from pydantic import BaseModel
from enum import Enum


class EvaluationResponse(BaseModel):
    r2_train: float
    r2_test: float
    rmse_dummy: float
    rmse_model: float
    rmse_gap: str


class Level(str, Enum):
    very_low = "very_low"
    low = "low"
    medium = "medium"
    high = "high"
    very_high = "very_high"


class PredictionRequest(BaseModel):
    socioeconomic_level: Level
    infrastructure: Level
    mother_age: Level
    mother_education: Level
    prenatal_visits: Level
    birth_weight: Level
    gestational_age: Level
    congenital_anomaly: Level
    healthcare_access: Level
    racial_distribution: Level
    state_code: str


class PredictionResponse(BaseModel):
    infant_mortality_rate: float

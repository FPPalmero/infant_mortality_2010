import pandas as pd
from fastapi import HTTPException
from src.api.dependencies import model
from src.ml.mappings import (
    birth_weight_map,
    congenital_anomaly_map,
    gestational_age_map,
    healthcare_access_map,
    infrastructure_map,
    mother_age_map,
    mother_education_map,
    prenatal_visits_map,
    socioeconomic_map,
)
from src.models.schemas import PredictionRequest, PredictionResponse
from src.config import region_map


def predict(request: PredictionRequest) -> PredictionResponse:

    features = {}

    state_code = request.state_code.upper()

    if state_code not in region_map:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid state code: {request.state_code}. Correct format is XX.",
        )

    features["state_code"] = state_code
    features["region"] = region_map[state_code]

    features.update(socioeconomic_map[request.socioeconomic_level])
    features.update(infrastructure_map[request.infrastructure])
    features.update(mother_age_map[request.mother_age])
    features.update(mother_education_map[request.mother_education])
    features.update(prenatal_visits_map[request.prenatal_visits])
    features.update(birth_weight_map[request.birth_weight])
    features.update(gestational_age_map[request.gestational_age])
    features.update(congenital_anomaly_map[request.congenital_anomaly])
    features.update(healthcare_access_map[request.healthcare_access])
    features.update({"births_non_white_mothers": 61.0})

    df = pd.DataFrame([features])

    predict = round(float(model.predict(df)[0]), 4)

    return PredictionResponse(
        infant_mortality_rate=predict,
    )

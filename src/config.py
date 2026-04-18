db_cities = "prod.cities"
db_infant_mortality = "prod.infant_mortality"
db_join = "ibge_code"

cols_to_drop = ["ibge_code", "id", "total_esf"]

float_to_int_cols = [
    "infant_deaths",
    "mother_education_0_years",
    "mother_education_1_3_years",
    "mother_education_4_7_years",
    "mother_education_12_more_years",
    "mother_age_10_to_19",
    "mother_age_30_to_39",
    "prenatal_0_visits",
    "prenatal_1_to_3_visits",
    "prenatal_4_to_6_visits",
    "birth_weight_1000g_to_1499g",
    "birth_weight_1500g_to_2499g",
    "birth_weight_4000g_or_more",
    "birth_weight_less_than_1000g",
    "mother_age_40_to_49",
    "congenital_anomaly_births",
    "gestational_age_less_than_32_weeks",
    "gestational_age_32_to_36_weeks",
    "births_non_white_mothers",
    "primary_care_units",
]

outlier_threshold = 50

pct_cols = [
    "mother_education_0_years",
    "mother_education_1_3_years",
    "mother_education_4_7_years",
    "mother_education_8_11_years",
    "mother_education_12_more_years",
    "mother_age_10_to_19",
    "mother_age_20_to_29",
    "mother_age_30_to_39",
    "mother_age_40_to_49",
    "prenatal_0_visits",
    "prenatal_1_to_3_visits",
    "prenatal_4_to_6_visits",
    "prenatal_7_or_more_visits",
    "birth_weight_less_than_1000g",
    "birth_weight_1000g_to_1499g",
    "birth_weight_1500g_to_2499g",
    "birth_weight_2500g_to_3999g",
    "birth_weight_4000g_or_more",
    "congenital_anomaly_births",
    "gestational_age_less_than_32_weeks",
    "gestational_age_32_to_36_weeks",
    "births_non_white_mothers",
]

cols_to_1000_pop = ["primary_care_units"]

education_cols = {
    "0 anos": "mother_education_0_years",
    "1-3 anos": "mother_education_1_3_years",
    "4-7 anos": "mother_education_4_7_years",
    "8-11 anos": "mother_education_8_11_years",
    "12+ anos": "mother_education_12_more_years",
}

mother_age_cols = {
    "mother_age_10_to_19": "10 a 19 anos",
    "mother_age_20_to_29": "20 a 29 anos",
    "mother_age_30_to_39": "30 a 39 anos",
    "mother_age_40_to_49": "40 a 49 anos",
}

prenatal_cols = {
    "prenatal_0_visits": "Nenhuma",
    "prenatal_1_to_3_visits": "1 a 3",
    "prenatal_4_to_6_visits": "4 a 6",
    "prenatal_7_or_more_visits": "7 ou mais",
}

region_map = {
    "PA": "Norte",
    "TO": "Norte",
    "AM": "Norte",
    "AC": "Norte",
    "RO": "Norte",
    "RR": "Norte",
    "AP": "Norte",
    "BA": "Nordeste",
    "PE": "Nordeste",
    "CE": "Nordeste",
    "MA": "Nordeste",
    "SE": "Nordeste",
    "AL": "Nordeste",
    "PI": "Nordeste",
    "RN": "Nordeste",
    "PB": "Nordeste",
    "MT": "Centro-Oeste",
    "GO": "Centro-Oeste",
    "DF": "Centro-Oeste",
    "MS": "Centro-Oeste",
    "SP": "Sudeste",
    "RJ": "Sudeste",
    "MG": "Sudeste",
    "ES": "Sudeste",
    "RS": "Sul",
    "PR": "Sul",
    "SC": "Sul",
}

random_state = 12345

test_size = 0.25

cols_to_drop_before_split = [
    "infant_mortality_rate",
    "total_births",
    "infant_deaths",
    "city_name",
]

target = "infant_mortality_rate"

multicollinear_cols = [
    "mother_age_40_to_49",
    "prenatal_7_or_more_visits",
    "region",
    "state_code",
    "mother_education_12_more_years",
    "birth_weight_4000g_or_more",
]

cat_cols = ["state_code", "region"]

fine_tuning_params = {
    "model__alpha": [80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 150, 200],
}

model_path = "models/ridge_pipeline.pkl"

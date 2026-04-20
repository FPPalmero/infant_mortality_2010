"""
Este arquivo tem a função de agrupar features que possuem uma estrutura em comum, por exemplo, idade da mãe, onde existem valores de 10 a 19, 20 a 29, 30 a 39 e 40 a 49, e atribuir valores padrão.
Foi pensado para simplificar a experiência do usuário, onde ele irá apenas preencher o grupo com valores entre muito baixo a muito alto.
Também tem a função de evitar que sejam aplicados valores irreais, que fogem da capacidade dos dados mapeados no treinamento do modelo.

Cada um dos valores foi manualmente selecionado a partir do describe de cada uma das features.
Para variáveis independentes, os valores que representam os quartis (Q1, Q2 e Q3) estão definidos como low, medium e high.
Os valores extremos (very_low e very_high) foram atribuídos com um valor entre min e Q1, e entre Q3 e max, respectivamente.
Para variáveis relacionadas entre si (idade da mãe, consultas pré-natais, etc), os valores foram atribuídos de forma coerente com os quartis, pois seguir a estratégia anterior extrapolaria 100%.

Algumas features possuem multicoliaridade perfeita entre elas, como é o caso das features de idade da mãe, onde a soma de todas as faixas etárias é igual a 100%.
Será aplicada a mesma correção realizada no notebook, removendo uma variável (definidas na variável multicollinear_cols) de cada grupo.
"""

socioeconomic_map = {
    "very_low": {"hdi": 0.50, "gini": 0.60, "average_income_per_capita": 150.0},
    "low": {"hdi": 0.59, "gini": 0.54, "average_income_per_capita": 260.0},
    "medium": {"hdi": 0.65, "gini": 0.50, "average_income_per_capita": 413.0},
    "high": {"hdi": 0.71, "gini": 0.46, "average_income_per_capita": 633.0},
    "very_high": {"hdi": 0.80, "gini": 0.38, "average_income_per_capita": 1200.0},
}


infrastructure_map = {
    "very_low": {
        "pct_sewage": 5.0,
        "pct_water_supply": 30.0,
        "pct_waste_collection": 25.0,
    },
    "low": {"pct_sewage": 12.0, "pct_water_supply": 58.0, "pct_waste_collection": 54.0},
    "medium": {
        "pct_sewage": 38.0,
        "pct_water_supply": 73.0,
        "pct_waste_collection": 75.0,
    },
    "high": {
        "pct_sewage": 71.0,
        "pct_water_supply": 85.0,
        "pct_waste_collection": 90.0,
    },
    "very_high": {
        "pct_sewage": 95.0,
        "pct_water_supply": 97.0,
        "pct_waste_collection": 98.0,
    },
}


mother_age_map = {
    "very_low": {
        "mother_age_10_to_19": 40.0,
        "mother_age_20_to_29": 45.0,
        "mother_age_30_to_39": 13.0,
    },
    "low": {
        "mother_age_10_to_19": 30.0,
        "mother_age_20_to_29": 50.0,
        "mother_age_30_to_39": 18.0,
    },
    "medium": {
        "mother_age_10_to_19": 22.0,
        "mother_age_20_to_29": 54.0,
        "mother_age_30_to_39": 22.0,
    },
    "high": {
        "mother_age_10_to_19": 16.0,
        "mother_age_20_to_29": 55.0,
        "mother_age_30_to_39": 27.0,
    },
    "very_high": {
        "mother_age_10_to_19": 10.0,
        "mother_age_20_to_29": 56.0,
        "mother_age_30_to_39": 32.0,
    },
}


mother_education_map = {
    "very_low": {
        "mother_education_0_years": 8.0,
        "mother_education_1_3_years": 20.0,
        "mother_education_4_7_years": 38.0,
        "mother_education_8_11_years": 28.0,
    },
    "low": {
        "mother_education_0_years": 4.0,
        "mother_education_1_3_years": 12.0,
        "mother_education_4_7_years": 33.0,
        "mother_education_8_11_years": 40.0,
    },
    "medium": {
        "mother_education_0_years": 2.0,
        "mother_education_1_3_years": 7.0,
        "mother_education_4_7_years": 32.0,
        "mother_education_8_11_years": 42.0,
    },
    "high": {
        "mother_education_0_years": 1.0,
        "mother_education_1_3_years": 4.0,
        "mother_education_4_7_years": 25.0,
        "mother_education_8_11_years": 50.0,
    },
    "very_high": {
        "mother_education_0_years": 0.5,
        "mother_education_1_3_years": 2.0,
        "mother_education_4_7_years": 15.0,
        "mother_education_8_11_years": 55.0,
    },
}


prenatal_visits_map = {
    "very_low": {
        "prenatal_0_visits": 8.0,
        "prenatal_1_to_3_visits": 25.0,
        "prenatal_4_to_6_visits": 45.0,
    },
    "low": {
        "prenatal_0_visits": 4.0,
        "prenatal_1_to_3_visits": 15.0,
        "prenatal_4_to_6_visits": 40.0,
    },
    "medium": {
        "prenatal_0_visits": 2.0,
        "prenatal_1_to_3_visits": 6.0,
        "prenatal_4_to_6_visits": 32.0,
    },
    "high": {
        "prenatal_0_visits": 1.0,
        "prenatal_1_to_3_visits": 3.0,
        "prenatal_4_to_6_visits": 20.0,
    },
    "very_high": {
        "prenatal_0_visits": 0.5,
        "prenatal_1_to_3_visits": 1.5,
        "prenatal_4_to_6_visits": 10.0,
    },
}


birth_weight_map = {
    "very_low": {
        "birth_weight_less_than_1000g": 3.0,
        "birth_weight_1000g_to_1499g": 3.0,
        "birth_weight_1500g_to_2499g": 15.0,
        "birth_weight_2500g_to_3999g": 74.0,
    },
    "low": {
        "birth_weight_less_than_1000g": 2.0,
        "birth_weight_1000g_to_1499g": 2.0,
        "birth_weight_1500g_to_2499g": 9.0,
        "birth_weight_2500g_to_3999g": 82.0,
    },
    "medium": {
        "birth_weight_less_than_1000g": 1.0,
        "birth_weight_1000g_to_1499g": 1.0,
        "birth_weight_1500g_to_2499g": 7.0,
        "birth_weight_2500g_to_3999g": 86.0,
    },
    "high": {
        "birth_weight_less_than_1000g": 0.5,
        "birth_weight_1000g_to_1499g": 0.5,
        "birth_weight_1500g_to_2499g": 5.0,
        "birth_weight_2500g_to_3999g": 88.0,
    },
    "very_high": {
        "birth_weight_less_than_1000g": 0.2,
        "birth_weight_1000g_to_1499g": 0.2,
        "birth_weight_1500g_to_2499g": 3.0,
        "birth_weight_2500g_to_3999g": 91.0,
    },
}


gestational_age_map = {
    "very_low": {
        "gestational_age_less_than_32_weeks": 4.0,
        "gestational_age_32_to_36_weeks": 15.0,
    },
    "low": {
        "gestational_age_less_than_32_weeks": 2.0,
        "gestational_age_32_to_36_weeks": 8.0,
    },
    "medium": {
        "gestational_age_less_than_32_weeks": 1.25,
        "gestational_age_32_to_36_weeks": 5.0,
    },
    "high": {
        "gestational_age_less_than_32_weeks": 0.8,
        "gestational_age_32_to_36_weeks": 3.5,
    },
    "very_high": {
        "gestational_age_less_than_32_weeks": 0.3,
        "gestational_age_32_to_36_weeks": 2.0,
    },
}


congenital_anomaly_map = {
    "very_low": {"congenital_anomaly_births": 0.3},
    "low": {"congenital_anomaly_births": 0.5},
    "medium": {"congenital_anomaly_births": 1.0},
    "high": {"congenital_anomaly_births": 1.5},
    "very_high": {"congenital_anomaly_births": 3},
}


healthcare_access_map = {
    "very_low": {"primary_care_units": 5.0},
    "low": {"primary_care_units": 16.0},
    "medium": {"primary_care_units": 24.0},
    "high": {"primary_care_units": 35.0},
    "very_high": {"primary_care_units": 70.0},
}


racial_distribution_map = {
    "very_low": {"births_non_white_mothers": 10.0},
    "low": {"births_non_white_mothers": 19.0},
    "medium": {"births_non_white_mothers": 61.0},
    "high": {"births_non_white_mothers": 87.0},
    "very_high": {"births_non_white_mothers": 98.0},
}

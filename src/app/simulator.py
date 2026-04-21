import streamlit as st
from src.ml.predict import predict
from src.models.schemas import PredictionRequest
from src.config import (
    region_map,
)
from src.app.descriptions import level_options, simulator_descriptions


def render_tab_simulator():
    _, col_header, _ = st.columns([1, 4, 1])

    with col_header:
        st.title("Simulador de Mortalidade Infantil")

        st.markdown(
            "Nesta tela, é possível simular a taxa de mortalidade infantil de um município brasileiro com base em diferentes níveis de indicadores socioeconômicos, de infraestrutura, saúde materna e acesso à saúde. "
            "O modelo utilizado para a simulação é o Ridge Regression, que apresentou o melhor desempenho durante a fase de avaliação. "
            "Os valores dos indicadores foram categorizados em 5 níveis (Muito Baixo, Baixo, Médio, Alto e Muito Alto) para facilitar a interpretação dos resultados. "
            "A simulação permite entender como diferentes combinações de indicadores podem impactar a taxa de mortalidade infantil, ajudando a identificar áreas prioritárias para intervenção e políticas públicas."
        )

        st.info(
            "A variável de distribuição racial foi removida do simulador pois o modelo apresentou comportamento contrário do esperado para esta variável, provavelmente resultado de multicolinearidade com outras features, como IDH e renda."
        )

        st.info(
            "Ao fixar todos os indicadores no mesmo nível, estados como MA podem apresentar taxa menor que SC, pois o modelo Ridge pode estar penalizando o coeficiente quando fatores como IDH e renda já explicam as diferenças regionais."
        )

        st.divider()

    _, col_form, _ = st.columns([1, 4, 1])

    with col_form:
        st.caption(
            "Selecione os indicadores abaixo para simular a taxa de mortalidade infantil de um município brasileiro."
        )

        state_code = st.selectbox("Estado", options=sorted(region_map.keys()))

        col1, col2 = st.columns(2)

        inputs = {}

        for i, (key, label) in enumerate(simulator_descriptions.items()):
            col = col1 if i % 2 == 0 else col2

            with col:
                inputs[key] = st.selectbox(
                    label, options=list(level_options.keys()), key=key, index=2
                )

        st.divider()

        if st.button("Simular", type="primary", use_container_width=True):
            request = PredictionRequest(
                state_code=state_code,
                socioeconomic_level=level_options[inputs["socioeconomic_level"]],
                infrastructure=level_options[inputs["infrastructure"]],
                mother_age=level_options[inputs["mother_age"]],
                mother_education=level_options[inputs["mother_education"]],
                prenatal_visits=level_options[inputs["prenatal_visits"]],
                birth_weight=level_options[inputs["birth_weight"]],
                gestational_age=level_options[inputs["gestational_age"]],
                congenital_anomaly=level_options[inputs["congenital_anomaly"]],
                healthcare_access=level_options[inputs["healthcare_access"]],
            )

            result = predict(request)
            st.session_state["result"] = result

        if "result" in st.session_state:
            rate = st.session_state["result"].infant_mortality_rate

            if rate < 13:
                risk, color = "Baixo", "green"
            elif rate < 17:
                risk, color = "Moderado", "orange"
            elif rate < 22:
                risk, color = "Alto", "orange"
            else:
                risk, color = "Crítico", "red"

            st.metric("Taxa de Mortalidade Infantil", f"{rate:.2f}%", delta_color=color)

            st.markdown(f"**Grau de Risco:** :{color}[{risk}]")

            st.caption(
                "Taxa representa o número de óbitos infantis por mil nascidos vivos."
            )

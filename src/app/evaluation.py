import streamlit as st
from src.data.load_data import get_data
from src.visualization.plots import (
    plot_residuals,
    plot_shap,
)
from src.ml.evaluate import evaluate_model
from src.ml.train import load_model
from sklearn.model_selection import train_test_split
from src.config import (
    cols_to_drop_before_split,
    target,
    test_size,
    random_state,
)


@st.cache_resource
def load_cached_model():
    return load_model()


@st.cache_data
def load_cached_df():
    return get_data()


def render_tab_evaluation():
    _, col_header, _ = st.columns([1, 4, 1])

    with col_header:
        st.title("Avaliação do Modelo")
        st.markdown(
            "Métricas de avaliação do modelo Ridge Regression treinado para prever a taxa de mortalidade infantil."
        )
        st.divider()

    _, col_metrics, _ = st.columns([2, 4, 2])

    with col_metrics:
        df_eval = load_cached_df()
        model = load_cached_model()
        metrics = evaluate_model(model, df_eval)

        X = df_eval.drop(columns=cols_to_drop_before_split)
        y = df_eval[target]

        X_train, X_test, _, y_test = train_test_split(
            X, y, test_size=test_size, random_state=random_state
        )

        col1, col2, col3, col4, col5 = st.columns(5)

        col1.metric("R² Treino", metrics.r2_train)
        col2.metric("R² Teste", metrics.r2_test)
        col3.metric("RMSE Dummy", metrics.rmse_dummy)
        col4.metric("RMSE Modelo", metrics.rmse_model)
        col5.metric("Ganho", metrics.rmse_gap)

        st.divider()

        option_eval = st.selectbox(
            "Selecione a visualização",
            [
                "Escolha uma opção",
                "Distribuição dos Resíduos",
                "SHAP: Importância das Features",
            ],
        )

        if option_eval == "Distribuição dos Resíduos":
            st.caption(
                "A distribuição dos resíduos é uma ferramenta importante para avaliar a qualidade do ajuste do modelo. Resíduos são as diferenças entre os valores observados/reais e os valores previstos pelo modelo. "
            )
            st.pyplot(plot_residuals(model, X_test, y_test))
        elif option_eval == "SHAP: Importância das Features":
            st.caption(
                "A análise SHAP (SHapley Additive exPlanations) é uma técnica de interpretação de modelos que atribui a cada feature uma importância baseada em sua contribuição para a previsão do modelo. As features com valores SHAP mais altos têm um impacto maior na previsão, enquanto as features com valores SHAP mais baixos têm um impacto menor. Neste caso, a feature birth weight less than 1000g é a feature com maior impacto na previsão da taxa de mortalidade infantil, indicando que bebês com baixo peso ao nascer têm uma probabilidade significativamente maior de mortalidade."
            )
            st.pyplot(plot_shap(model, X_train))

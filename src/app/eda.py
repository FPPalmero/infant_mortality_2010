import streamlit as st
from src.data.load_data import get_data
from src.visualization.plots import (
    plot_target_distribution,
    plot_correlation_heatmap,
    plot_education_scatter,
    plot_mother_age_scatter,
    plot_prenatal_scatter,
)
from src.app.descriptions import eda_descriptions


@st.cache_data
def load_cached_df():
    return get_data()


def render_tab_eda():
    _, col_header, _ = st.columns([1, 4, 1])

    with col_header:
        st.title("Análise Exploratória de Dados")

        st.markdown(
            "Nesta tela, é possível visualizar alguns resultados da análise exploratória de dados, incluindo a distribuição da taxa de mortalidade infantil no Brasil no ano de 2010 e a relação entre variáveis específicas como escolaridade da mãe, idade da mãe e número de consultas pré-natais com a taxa de mortalidade infantil. Para selecionar a análise desejada, utilize o menu suspenso abaixo. Cada gráfico é acompanhado por uma breve descrição para facilitar a interpretação dos resultados."
        )

        st.divider()

    _, col_select, _ = st.columns([2, 3, 2])

    with col_select:
        df = load_cached_df()

        option = st.selectbox(
            "Selecione a análise",
            [
                "Escolha uma opção",
                "Distribuição da Taxa de Mortalidade Infantil",
                "Correlação de Spearman",
                "Escolaridade da Mãe",
                "Idade da Mãe",
                "Consultas Pré-Natais",
            ],
        )

    if option != "Escolha uma opção":
        _, col_plot, _ = st.columns([2, 4, 2])

        with col_plot:
            st.caption(eda_descriptions[option])

            if option == "Distribuição da Taxa de Mortalidade Infantil":
                st.pyplot(plot_target_distribution(df))
            elif option == "Correlação de Spearman":
                st.pyplot(plot_correlation_heatmap(df))
            elif option == "Escolaridade da Mãe":
                st.pyplot(plot_education_scatter(df))
            elif option == "Idade da Mãe":
                st.pyplot(plot_mother_age_scatter(df))
            elif option == "Consultas Pré-Natais":
                st.pyplot(plot_prenatal_scatter(df))

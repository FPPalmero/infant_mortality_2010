import streamlit as st
from src.app.eda import render_tab_eda
from src.app.evaluation import render_tab_evaluation
from src.app.simulator import render_tab_simulator
from src.data.load_data import get_data


st.set_page_config(page_title="Mortalidade Infantil no Brasil", layout="wide")

tab_simulator, tab_eda, tab_evaluation = st.tabs(
    [
        "Simulador",
        "Análise Exploratória",
        "Avaliação do Modelo",
    ]
)


@st.cache_data
def load_df():
    return get_data()


with tab_simulator:
    render_tab_simulator()

with tab_eda:
    render_tab_eda()

with tab_evaluation:
    render_tab_evaluation()

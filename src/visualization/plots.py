import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import shap

from src.config import education_cols, mother_age_cols, prenatal_cols, target


def plot_target_distribution(df: pd.DataFrame) -> plt.Figure:

    plt.close("all")

    plt.figure(figsize=(8, 4))
    sns.histplot(df[target], kde=True, bins=50)
    plt.xlabel("Taxa de Mortalidade Infantil (%)")
    plt.ylabel("Frequência")
    plt.title("Distribuição da Taxa de Mortalidade Infantil")

    plt.tight_layout()

    return plt.gcf()


def plot_correlation_heatmap(df: pd.DataFrame) -> plt.Figure:

    plt.close("all")

    plt.figure(figsize=(8, 12))
    corr = (
        df.select_dtypes(include="number")
        .corr(method="spearman")[[target]]
        .sort_values(by=target)
    )
    sns.heatmap(corr, annot=True, fmt=".2f", cmap="coolwarm")

    plt.tight_layout()

    return plt.gcf()


def plot_education_scatter(df: pd.DataFrame) -> plt.Figure:

    plt.close("all")

    plt.figure(figsize=(14, 11))
    plt.suptitle("Análise da Mortalidade Infantil por Educação da Mãe", y=1, size=16)

    for i, (label, col) in enumerate(education_cols.items()):
        plt.subplot(3, 2, i + 1)
        sns.scatterplot(x=df[col], y=df[target], alpha=0.3, s=10)
        sns.regplot(
            x=df[col],
            y=df[target],
            scatter=False,
            color="red",
            line_kws={"linewidth": 2},
        )
        plt.xlabel(f"% de Nascimentos por Escolaridade: {label}", size=13)
        plt.ylabel("Mortalidade Infantil (‰)", size=13)

    plt.tight_layout()

    return plt.gcf()


def plot_mother_age_scatter(df: pd.DataFrame) -> plt.Figure:

    plt.close("all")

    plt.figure(figsize=(11, 6))
    plt.suptitle("Análise da Mortalidade Infantil por Idade da Mãe", y=0.98)

    for i, (col, label) in enumerate(mother_age_cols.items()):
        plt.subplot(2, 2, i + 1)
        sns.scatterplot(x=df[col], y=df[target], alpha=0.3, s=10)
        sns.regplot(
            x=df[col],
            y=df[target],
            scatter=False,
            color="red",
            line_kws={"linewidth": 2},
        )
        plt.xlabel(f"% de Nascimentos por Idade - {label}")
        plt.ylabel("Taxa de Mortalidade Infantil - %")

    plt.tight_layout()

    return plt.gcf()


def plot_prenatal_scatter(df: pd.DataFrame) -> plt.Figure:

    plt.close("all")

    plt.figure(figsize=(11, 6))
    plt.suptitle(
        "Análise da Mortalidade Infantil por Total de Consultas Pré-Natais",
        y=0.98,
        size=13,
    )

    for i, (col, label) in enumerate(prenatal_cols.items()):
        plt.subplot(2, 2, i + 1)
        sns.scatterplot(x=df[col], y=df[target], alpha=0.3, s=10)
        sns.regplot(
            x=df[col],
            y=df[target],
            scatter=False,
            color="red",
            line_kws={"linewidth": 2},
        )
        plt.xlabel(f"% de Nascimentos por Nº de Pré-Natais: {label}")
        plt.ylabel("Taxa de Mortalidade Infantil - %")

    plt.tight_layout()

    return plt.gcf()


def plot_residuals(model, X_test, y_test) -> plt.Figure:

    plt.close("all")

    y_pred = model.predict(X_test)
    residual = y_test.values - y_pred

    plt.figure(figsize=(8, 4))
    sns.histplot(residual, bins=50, kde=True)
    plt.axvline(0, color="red", linestyle="--", linewidth=1)
    plt.title("Distribuição dos Resíduos")
    plt.xlabel("Resíduo (y_true - y_pred)")
    plt.ylabel("Frequência")

    plt.tight_layout()

    return plt.gcf()


def plot_shap(model, X_train) -> plt.Figure:

    plt.close("all")

    ridge = model.named_steps["model"]
    preprocessor = model.named_steps["preprocessor"]

    X_train_transformed = preprocessor.transform(X_train)

    explainer = shap.LinearExplainer(ridge, X_train_transformed)
    shap_values = explainer.shap_values(X_train_transformed)

    all_features = preprocessor.get_feature_names_out()
    feature_names = []
    num_index = []

    for i, feature in enumerate(all_features):
        if not feature.startswith("ohe__"):
            feature_names.append(feature.replace("num__", "").replace("_", " "))
            num_index.append(i)

    X_num = X_train_transformed[:, num_index]
    shap_num = shap_values[:, num_index]

    shap.summary_plot(shap_num, X_num, feature_names=feature_names, show=False)

    plt.tight_layout()

    return plt.gcf()

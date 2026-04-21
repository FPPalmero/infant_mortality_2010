level_options = {
    "Muito Baixo": "very_low",
    "Baixo": "low",
    "Médio": "medium",
    "Alto": "high",
    "Muito Alto": "very_high",
}

simulator_descriptions = {
    "socioeconomic_level": "Nível Socioeconômico: IDH, Gini e renda per capita",
    "infrastructure": "Infraestrutura: rede de esgoto, água tratada e coleta de lixo. Essas features muito provavelmente foram penalizadas pelo modelo, devido à multicolinearidade com o nível socioeconômico.",
    "mother_age": "Idade da Mãe: distribuição etária no momento do parto. Quanto maior a métrica, maior a proporção de mães na casa de 20 a 39 anos.",
    "mother_education": "Escolaridade da Mãe: nível de escolaridade da mãe no momento do parto",
    "prenatal_visits": "Consultas Pré-Natais: quantidade de consultas durante a gestação",
    "birth_weight": "Peso ao Nascer: distribuição do peso dos recém-nascidos",
    "gestational_age": "Idade Gestacional: proporção de partos prematuros. Quanto menor a métrica, maior a frequência de partos prematuros.",
    "congenital_anomaly": "Anomalia Congênita: proporção de nascimentos com algum tipo de anomalia congênita",
    "healthcare_access": "UBS por 1k habitantes: Municípios pequenos e pobres tendem a ter proporção maior de UBS por nascimento, o que explica a correlação positiva com a mortalidade infantil.",
}

eda_descriptions = {
    "Distribuição da Taxa de Mortalidade Infantil": "Histograma que mostra a distribuição da taxa de mortalidade infantil nos municípios brasileiros no ano de 2010. É possível visualizar uma distribuição assimétrica, com a maioria dos municípios apresentando taxas de mortalidade infantil relativamente baixas, mas com uma cauda longa indicando que alguns municípios têm taxas significativamente mais altas.",
    "Correlação de Spearman": "Correlação entre as features e a taxa de mortalidade infantil, utilizando o método de Spearman. Quanto mais próximo de 1, mais forte é a correlação positiva, ou seja, quando uma variável aumenta, a outra também tende a aumentar, e quanto mais próximo de -1, mais forte é a correlação negativa. A análise de correlação pode ajudar a identificar quais variáveis estão mais ou menos associadas à taxa de mortalidade infantil.",
    "Escolaridade da Mãe": "Relação entre diferentes níveis de escolaridade da mãe e a taxa de mortalidade infantil. O gráfico mostra que, em geral, quanto maior a escolaridade da mãe, menor a taxa de mortalidade infantil, indicando uma relação inversa entre esses dois fatores.",
    "Idade da Mãe": "Relação entre diferentes faixas etárias da mãe e a taxa de mortalidade infantil. O gráfico sugere que mães muito jovens (adolescentes) e mães mais velhas (acima de 40 anos) tendem a ter taxas de mortalidade infantil mais altas, enquanto mães na faixa etária de 20 a 39 anos apresentam taxas mais baixas.",
    "Consultas Pré-Natais": "Relação entre o número de consultas pré-natais e a taxa de mortalidade infantil. O gráfico indica que um número maior de consultas pré-natais está associado a uma taxa de mortalidade infantil mais baixa, sugerindo que o acompanhamento pré-natal adequado pode contribuir para a redução da mortalidade infantil.",
}

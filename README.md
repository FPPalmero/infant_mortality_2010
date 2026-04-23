# Mortalidade Infantil no Brasil — 2010

Projeto de ciência de dados e engenharia de ML que analisa e prevê a taxa de mortalidade infantil nos municípios brasileiros com base em dados do censo de 2010, coletados do IBGE e DATASUS.

---
 
## Demo

A demo está hospedada no plano gratuito do Render. Após um período de inatividade, pode levar até 2 minutos para inicializar. Aguarde o carregamento completo antes de interagir com a aplicação.
 
| Serviço | URL |
|---|---|
| Streamlit | [infant-mortality-app.onrender.com](https://infant-mortality-app.onrender.com) |
| FastAPI (Swagger) | [infant-mortality-api.onrender.com/docs](https://infant-mortality-api.onrender.com/docs) |

> **ATENÇÃO:** Para rodar localmente é necessário configurar um banco PostgreSQL e executar os scripts de ETL disponíveis em `sql/`. Para apenas testar a aplicação, acesse a demo pública acima.
 
---

## 1. Sobre o Projeto

O objetivo é identificar os principais fatores socioeconômicos, de saúde materna e de infraestrutura associados à mortalidade infantil nos municípios brasileiros, e disponibilizar um simulador interativo que permite estimar a taxa de mortalidade infantil de acordo com diferentes combinações de indicadores.

O modelo preditivo é um **Ridge Regression**, selecionado após processo de seleção com baseline, tuning com RandomizedSearchCV e fine-tune com GridSearchCV.

---

## 2. Estrutura do Projeto

```
infant_mortality_2010/
│
├── data/
│   └── raw/                        # CSVs originais coletados do IBGE e DATASUS
│
├── models/
│   └── ridge_pipeline.pkl          # Modelo treinado exportado
│
├── notebooks/
│   └── infant_mortality_analysis.ipynb  # Notebook com EDA, testes de hipótese e modelagem
│
├── sql/
│   └── 01_schemas.sql              # Criação dos schemas para camada ETL (Raw > Stage > Prod)
│   └── 02_raw.sql                  # Criação das tabelas na camada raw
│   └── 03_stage.sql                # Criação das tabelas na camada stage
│   └── 04_stage_fixes.sql          # Correções necessárias para criação das tabelas na camada prod
│   └── 05_prod.sql                 # Criação das tabelas na camada prod
│
├── src/
│   ├── api/
│   │   ├── app.py                  # Instância do FastAPI e registro de rotas
│   │   ├── dependencies.py         # Modelo e DataFrame carregados na inicialização
│   │   └── routes/
│   │       ├── predict.py          # POST /predict
│   │       └── evaluate.py         # GET /evaluate
│   │
│   ├── app/
│   │   ├── descriptions.py         # Variáveis de descrições utilizadas nos demais arquivos
│   │   ├── streamlit.py            # Arquivo principal do Streamlit
│   │   ├── simulator.py            # Aba do simulador
│   │   ├── eda.py                  # Aba de análise exploratória
│   │   └── evaluation.py           # Aba de avaliação do modelo
│   │
│   ├── data/
│   │   ├── load_data.py            # Conexão com banco e carregamento dos dados
│   │   └── preprocess.py           # Limpeza, tipagem, outliers e preenchimento de nulos
│   │
│   ├── features/
│   │   └── feature_engineering.py  # Escalonamento, criação de região
│   │
│   ├── ml/
│   │   ├── train.py                # Pipeline de treino e exportação do modelo
│   │   ├── evaluate.py             # Métricas de avaliação
│   │   └── mappings.py             # Mapeamentos de valores das features
│   │   └── predict.py              # Serviço de predict do modelo
│   │
│   ├── models/
│   │   └── schemas.py              # Modelos Pydantic (request/response)
│   │
│   ├── visualization/
│   │   └── plots.py                # Funções de visualização (EDA e avaliação)
│   │
│   ├── config.py                   # Variáveis gerais, colunas e hiperparâmetros
│   ├── main.py                     # Orquestrador: sobe FastAPI + Streamlit
├── Dockerfile.api                  # Configuração do arquivo docker do swagger
├── Dockerfile.streamlit            # Configuração do arquivo docker do streamlit
├── requirements.txt                # Dependências para build da imagem docker
├── environment.yml                 # Ambiente conda para desenvolvimento local
└── .env                            # Variáveis de ambiente
```

---

## 3. Metodologia

### 3.1. Análise Exploratória
- Verificação de tipos, nulos e distribuição das features
- Identificação e remoção de outliers do target (`infant_mortality_rate >= 50`)
- Correlação de Spearman entre features e target
- Análise de dispersão por escolaridade materna, idade da mãe e consultas pré-natais
- Análise de mortalidade por região e estado

### 3.2. Testes de Hipótese
- **Shapiro-Wilk**: distribuição não normal do target confirmada
- **Mann-Whitney**: diferença significativa entre municípios com alto e baixo índice de Gini
- **Kruskal-Wallis**: diferença significativa entre regiões

### 3.3. Feature Engineering
- Escalonamento das contagens absolutas para porcentagem e taxa por 1k nascimentos
- Criação da coluna `region` a partir do estado
- Remoção de features com multicolinearidade perfeita

### 3.4. Modelagem
- **Fase 1:** Baseline com 6 modelos (Linear Regression, Ridge, Random Forest, XGBoost, LightGBM, CatBoost)
- **Fase 2:** Tuning com RandomizedSearchCV nos melhores modelos
- **Fase 3:** Fine-tune com GridSearchCV no modelo selecionado (Ridge)
- Avaliação com R², RMSE, comparação com DummyRegressor e SHAP values

### 3.5. Resultado Final
O modelo Ridge apresentou a melhor combinação de desempenho e generalização, sem overfitting, com R² semelhante entre treino e teste.

---

## 4. Interface — Streamlit
 
A interface possui três abas:
 
### 4.1. Simulador
Permite simular a taxa de mortalidade infantil de um município brasileiro selecionando o estado e os níveis dos indicadores socioeconômicos, de saúde materna, infraestrutura e acesso à saúde. O resultado exibe a taxa prevista e o grau de risco (Baixo, Moderado, Alto ou Crítico) com base nos dados reais do censo de 2010.
 
### 4.2. Análise Exploratória
Exibe os principais gráficos da EDA: distribuição da taxa de mortalidade infantil, correlação de Spearman, análise de dispersão por escolaridade materna, idade da mãe e consultas pré-natais.
 
### 4.3. Avaliação do Modelo
Exibe as métricas de avaliação do modelo (R² treino e teste, RMSE vs Dummy e ganho percentual), distribuição dos resíduos e SHAP values das features.

---

## 5. Limitações do Modelo

- **Dados agregados por município:** O modelo trabalha com dados agregados por município, o que limita naturalmente o poder preditivo. Informações individuais relevantes como vacinação, condições de saúde da criança, qualidade do atendimento médico e causas externas de morte (acidentes, afogamentos) são perdidas na agregação.
- **Dados estáticos do censo 2010:** o modelo não captura mudanças ocorridas após esse período
- **Distribuição racial:** a variável `births_non_white_mothers` foi removida do simulador pois, após controlar fatores como IDH e renda, o modelo apresentou comportamento contrário ao esperado, resultado de multicolinearidade com outras features socioeconômicas
- **Comportamento por estado:** ao fixar todos os indicadores no mesmo nível, alguns estados podem apresentar taxas inesperadas, pois o modelo Ridge penaliza o coeficiente do estado quando fatores como IDH e renda já explicam as diferenças regionais

---

## 6. Como Rodar

### Pré-requisitos
- Docker instalado
- Banco PostgreSQL configurado com os scripts SQL disponíveis em `sql/`
- Arquivo `.env` configurado

### Com Docker

O projeto possui dois Dockerfiles separados, um para a API e outro para o Streamlit. Em dois terminais, faça o build e rode o container.

**API (FastAPI):**
```bash
docker build -f Dockerfile.api -t infant-api .
docker run -p 8000:8000 --env-file .env infant-api
```

**Streamlit:**
```bash
docker build -f Dockerfile.streamlit -t infant-streamlit .
docker run -p 8501:8501 --env-file .env infant-streamlit
```

Acesse:
- **Streamlit:** `http://localhost:8501`
- **FastAPI (Swagger):** `http://localhost:8000/docs`

### Localmente com Conda

```bash
# Criar o ambiente
conda env create -f environment.yml

# Ativar o ambiente
conda activate infant_mortality

# Rodar o projeto
python -m src.main
```

---

## 7. Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto com as variáveis abaixo e preencha os valores com as configurações do seu banco PostgreSQL:

```
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=
DB_NAME=
```

---

## 8. Stack

| Categoria | Tecnologias |
|---|---|
| Linguagem | Python 3.12 |
| Análise de Dados | Pandas, NumPy, SciPy |
| Machine Learning | Scikit-learn, XGBoost, LightGBM, CatBoost, SHAP |
| Visualização | Matplotlib, Seaborn |
| API | FastAPI, Uvicorn, Pydantic |
| Interface | Streamlit |
| Banco de Dados | PostgreSQL (Supabase), SQLAlchemy |
| Containerização | Docker |

---

## 9. Fontes dos Dados

- **IBGE** — Censo Demográfico 2010 (IDH, Gini, renda per capita, população)
- **DATASUS** — Sistema de Informações sobre Nascidos Vivos (SINASC) e Sistema de Informações sobre Mortalidade (SIM)

---

## 10. API Endpoints

| Método | Endpoint | Descrição |
|---|---|---|
| `POST` | `/predict/` | Prediz a taxa de mortalidade infantil com base nos indicadores selecionados |
| `GET` | `/evaluate/` | Retorna as métricas de avaliação do modelo (R², RMSE, ganho vs dummy) |

---

## 11. Autor

Fillipe Palmero — [LinkedIn](https://www.linkedin.com/in/fillipe-palmero-fritsch/) · [GitHub](https://github.com/FPPalmero)
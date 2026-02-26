-- Nesta camada, são criadas as tabelas que receberão os dados finais estruturados e prontos para serem utilizados.
-- Foi aplicada a metodologia Kimball, separando as tabelas de fato (infant_mortality) e dimensões (cities).
-- Na tabela de fato, estão todas as métricas que serão utilizadas durante o projeto.
-- Na tabela de dimensão, estão as descrições dos municípios.

-- Criação da tabela de municípios na camada de produção
CREATE TABLE prod.cities (
	ibge_code INT NOT NULL PRIMARY KEY,
	city_name TEXT NOT NULL,
	state_code CHAR(2)
);

-- Inserção dos dados da tabela de municípios da stage para a produção
INSERT INTO prod.cities (ibge_code, city_name, state_code)
SELECT 
	ibge_code, 
	city_name, 
	state_code 
FROM 
	stage.cities;
    
-------------------------------------------------------------------------------------------------

-- Criação da tabela de mortalidade infantil na camada de produção
CREATE TABLE prod.infant_mortality (
	id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ibge_code INT NOT NULL,

    -- Indicadores socioeconômicos
    hdi NUMERIC(4,3),
    gini NUMERIC(4,3),
    average_income_per_capita NUMERIC(18,2),

    -- total_births (nascimentos no município)
    total_births INT,
    -- infant_deaths (óbitos infantis no município)
    infant_deaths INT,
    -- infant_mortality_rate (taxa de mortalidade infantil no município)
    infant_mortality_rate NUMERIC(10,4),

    -- total_esf (totais de ESF no município)
    total_esf INT,

    -- mother_education (nascimentos por escolaridade da mãe)
    mother_education_0_years INT,
    mother_education_1_3_years INT,
    mother_education_4_7_years INT,
    mother_education_8_11_years INT,
    mother_education_12_more_years INT,

    -- mother_age (nascimentos por faixa etária da mãe)
    mother_age_10_to_19 INT,
    mother_age_20_to_29 INT,
    mother_age_30_to_39 INT,

    -- prenatal_visits (nascimentos por consultas prenatais realizadas)
    prenatal_0_visits INT,
    prenatal_1_to_3_visits INT,
    prenatal_4_to_6_visits INT,
    prenatal_7_or_more_visits INT,

    -- birth_weight (nascimentos por faixa de peso)
    birth_weight_1000g_to_1499g INT,
    birth_weight_1500g_to_2499g INT,
    birth_weight_2500g_to_3999g INT,
    birth_weight_4000g_or_more INT,

    -- Constraint para fazer referência a tabela de municípios
    CONSTRAINT fk_cities_information
        FOREIGN KEY (ibge_code) REFERENCES prod.cities (ibge_code)
);

-------------------------------------------------------------------------------------------------

INSERT INTO prod.infant_mortality (
	ibge_code,
	hdi,
	gini,
	average_income_per_capita,
	total_births,
	infant_deaths,
	infant_mortality_rate,
	total_esf,
	mother_education_0_years,
	mother_education_1_3_years,
	mother_education_4_7_years,
	mother_education_8_11_years,
	mother_education_12_more_years,
	mother_age_10_to_19,
	mother_age_20_to_29,
	mother_age_30_to_39,
	prenatal_0_visits,
	prenatal_1_to_3_visits,
	prenatal_4_to_6_visits,
	prenatal_7_or_more_visits,
	birth_weight_1000g_to_1499g,
	birth_weight_1500g_to_2499g,
	birth_weight_2500g_to_3999g,
	birth_weight_4000g_or_more
)
SELECT
    b.ibge_code,
    h.hdi,
    g.gini,
    ai.average_income_per_capita,
    b.total_births,
    d.infant_deaths,
    -- Criando a taxa de mortalidade infantil (Mortes / Nascimentos) * 1000
    CASE 
        WHEN b.total_births > 0
        THEN CAST(d.infant_deaths AS NUMERIC) / b.total_births * 1000
        ELSE NULL
    END AS infant_mortality_rate,
    e.total_esf,
    me.mother_education_0_years,
    me.mother_education_1_3_years,
    me.mother_education_4_7_years,
    me.mother_education_8_11_years,
    me.mother_education_12_more_years,
    ma.mother_age_10_to_19,
    ma.mother_age_20_to_29,
    ma.mother_age_30_to_39,
    pv.prenatal_0_visits,
    pv.prenatal_1_to_3_visits,
    pv.prenatal_4_to_6_visits,
    pv.prenatal_7_or_more_visits,
    bw.birth_weight_1000g_to_1499g,
    bw.birth_weight_1500g_to_2499g,
    bw.birth_weight_2500g_to_3999g,
    bw.birth_weight_4000g_or_more

FROM stage.births b

LEFT JOIN stage.infant_deaths d 
    ON b.ibge_code = d.ibge_code

LEFT JOIN stage.hdi h 
    ON b.ibge_code = h.ibge_code

LEFT JOIN stage.gini g 
    ON b.ibge_code = g.ibge_code

LEFT JOIN stage.average_income_per_capita ai 
    ON b.ibge_code = ai.ibge_code

LEFT JOIN stage.esf e 
    ON b.ibge_code = e.ibge_code

-- Subquery mother_education
-- Nesta subquery, é realizado um CASE WHEN para separar o total de nascimentos (total_births) de acordo com cada nível de escolaridade da mãe (mother_education)
-- E em seguida, é realizado um GROUP BY para agrupar os nascimentos por município (ibge_code)
-- A mesma lógica é aplicada para as demais subqueries abaixo desta.
LEFT JOIN (
    SELECT
        ibge_code,
        SUM(CASE WHEN mother_education = '0_years' THEN total_births END) AS mother_education_0_years,
        SUM(CASE WHEN mother_education = '1_3_years' THEN total_births END) AS mother_education_1_3_years,
        SUM(CASE WHEN mother_education = '4_7_years' THEN total_births END) AS mother_education_4_7_years,
        SUM(CASE WHEN mother_education = '8_11_years' THEN total_births END) AS mother_education_8_11_years,
        SUM(CASE WHEN mother_education = '12_more_years' THEN total_births END) AS mother_education_12_more_years
    FROM stage.mother_education
    GROUP BY ibge_code
) me ON b.ibge_code = me.ibge_code

-- Subquery mother_age
LEFT JOIN (
    SELECT
        ibge_code,
        SUM(CASE WHEN mother_age = '10_to_19_age' THEN total_births END) AS mother_age_10_to_19,
        SUM(CASE WHEN mother_age = '20_to_29_age' THEN total_births END) AS mother_age_20_to_29,
        SUM(CASE WHEN mother_age = '30_to_39_age' THEN total_births END) AS mother_age_30_to_39
    FROM stage.mother_age
    GROUP BY ibge_code
) ma ON b.ibge_code = ma.ibge_code

-- Subquery prenatal_visits
LEFT JOIN (
    SELECT
        ibge_code,
        SUM(CASE WHEN prenatal_visits = '0_visits' THEN total_births END) AS prenatal_0_visits,
        SUM(CASE WHEN prenatal_visits = '1_to_3_visits' THEN total_births END) AS prenatal_1_to_3_visits,
        SUM(CASE WHEN prenatal_visits = '4_to_6_visits' THEN total_births END) AS prenatal_4_to_6_visits,
        SUM(CASE WHEN prenatal_visits = '7_or_more_visits' THEN total_births END) AS prenatal_7_or_more_visits
    FROM stage.prenatal_visits
    GROUP BY ibge_code
) pv ON b.ibge_code = pv.ibge_code

-- Subquery birth_weight
LEFT JOIN (
    SELECT
        ibge_code,
        SUM(CASE WHEN birth_weight = '1kg_to_1499g' THEN total_births END) AS birth_weight_1000g_to_1499g,
        SUM(CASE WHEN birth_weight = '1500g_to_2499g' THEN total_births END) AS birth_weight_1500g_to_2499g,
        SUM(CASE WHEN birth_weight = '2500g_to_3999g' THEN total_births END) AS birth_weight_2500g_to_3999g,
        SUM(CASE WHEN birth_weight = '4000g_or_more' THEN total_births END) AS birth_weight_4000g_or_more
    FROM stage.birth_weight
    GROUP BY ibge_code
) bw ON b.ibge_code = bw.ibge_code;

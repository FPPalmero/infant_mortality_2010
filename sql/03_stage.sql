-- Nesta camada, são criadas as tabelas que receberão os dados brutos da tabela raw.
-- Todas as transformações e limpezas serão realizadas nesta camada.

-- Criação da tabela de municípios na camada de stage
CREATE TABLE stage.cities AS
SELECT DISTINCT
-- Foi necessário transformar o código IBGE em string para aplicar a função LEFT e extrair os 6 primeiros caracteres
-- Depois, o código IBGE foi convertido novamente para INT
-- A mesma lógica foi aplicada para as tabelas de IDH e GINI, pois em ambas o código IBGE possui 7 dígitos
-- A medida foi necessária, dada que em todas as outras tabelas o código IBGE possui 6 dígitos
-- Então esta foi a metodologia utilizada para resolver o problema.
    CAST(LEFT(CAST(ibge_city_code AS TEXT), 6) AS INT) AS ibge_code,
    INITCAP(TRIM(ibge_city_name)) AS city_name,
    UPPER(TRIM(state_code)) as state_code
FROM raw.cities
WHERE ibge_city_name IS NOT NULL;

-------------------------------------------------------------------------------------------------

-- Criação da tabela de IDH na camada de stage
CREATE TABLE stage.hdi AS
SELECT DISTINCT
    CAST(LEFT(CAST(ibge_city_code AS TEXT), 6) AS INT) AS ibge_code,
    CAST(hdi_2010 AS NUMERIC(4,3)) AS hdi
FROM raw.hdi
WHERE ibge_city_code IS NOT NULL;

-------------------------------------------------------------------------------------------------

-- Criação da tabela de GINI na camada de stage
CREATE TABLE stage.gini AS
SELECT DISTINCT 
	CAST(LEFT(CAST(ibge_city_code AS TEXT), 6) AS INT) AS ibge_code,
	CAST(gini_2010 AS NUMERIC(4,3)) AS gini
FROM raw.gini_index
WHERE ibge_city_code IS NOT NULL;

-------------------------------------------------------------------------------------------------

-- Criação da tabela de óbitos por município na camada de stage
CREATE TABLE stage.infant_deaths AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(
            SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair apenas o número de óbitos infantis.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS infant_deaths
FROM raw.infant_deaths
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.births AS 
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
	CAST(NULLIF(
		REGEXP_REPLACE(
			SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair apenas o número total de nascimentos.
	CAST(NULLIF(
		REGEXP_REPLACE(
			SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births
FROM raw.births
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.prenatal_visits AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(
            SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair apenas o número total de nascimentos de acordo com cada categoria de visitas prenatais.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS prenatal_visits
FROM raw.prenatal_visits
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS stage.mother_age;

CREATE TABLE stage.mother_age AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair o total de nascimentos de acordo com a idade da mãe.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS mother_age
FROM raw.mother_age
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.average_income_per_capita AS
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
SELECT
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '\D', '', 'g'),'') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para validar se o valor é numérico, se passar, é convertido para NUMERIC(18,2)
-- Foi substituída a vírgula por ponto para adequar o formato aceito pelo banco de dados
    CASE
        WHEN REPLACE(SPLIT_PART(raw_data, ';', 2), ',', '.') ~ '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(REPLACE(SPLIT_PART(raw_data, ';', 2), ',', '.') AS NUMERIC(18,2)) ELSE NULL
    END AS average_income_per_capita

FROM raw.average_income_per_capita
WHERE raw_data LIKE '%;%';

-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS stage.birth_weight;

CREATE TABLE stage.birth_weight AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(
            SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair o total de nascimentos de acordo com o peso do bebê.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS birth_weight
FROM raw.birth_weight
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.esf AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair apenas o número total de ESF.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_esf
FROM raw.esf
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';


-------------------------------------------------------------------------------------------------

CREATE TABLE stage.mother_education AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair o total de nascimentos de acordo com o nível de escolaridade da mãe.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS mother_education
FROM raw.mother_education
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';


-------------------------------------------------------------------------------------------------

CREATE TABLE stage.pct_sewage AS
SELECT
 -- Foi necessário utilizar regex pra extrair apenas o código do ibge.
-- Em seguida, foi utilizado left 6 para manter apenas os 6 primeiros dígitos do código ibge,
-- pois neste arquivo o código vem com 7 dígitos (mesma lógica aplicada para cities, hdi e gini).
-- A mesma lógica abaixo é utilizada nas tabelas pct_water e pct_waste_collection, já que a estrutura é exatamente igual.
    CAST(NULLIF(
        LEFT(
            REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), 6), '') AS INT) AS ibge_code,
-- Removidas as aspas da coluna porcentagem, e trocando vírgula por ponto
-- Depois, o valor foi convertido para numeric.
    CASE
        WHEN REPLACE(TRIM(BOTH '"' FROM SPLIT_PART(raw_data, ';', 5)), ',', '.') ~ '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(REPLACE(TRIM(BOTH '"' FROM SPLIT_PART(raw_data, ';', 5)), ',', '.') AS NUMERIC(10,2))
        ELSE NULL
    END AS pct_sewage
FROM raw.pct_sewage
WHERE raw_data LIKE '%;%'
-- Filtra apenas as linhas em que possuem dados, ignorando cabeçalhos, legendas, etc.
    AND REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g') <> '';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.pct_water_supply AS
SELECT
    CAST(NULLIF(
        LEFT(
            REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), 6), '') AS INT) AS ibge_code,
    CASE
        WHEN REPLACE(TRIM(BOTH '"' FROM SPLIT_PART(raw_data, ';', 5)), ',', '.') ~ '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(REPLACE(TRIM(BOTH '"' FROM SPLIT_PART(raw_data, ';', 5)), ',', '.') AS NUMERIC(10,2))
        ELSE NULL
    END AS pct_water_supply
FROM raw.pct_water_supply
WHERE raw_data LIKE '%;%'
    AND REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g') <> '';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.pct_waste_collection AS
SELECT
    CAST(NULLIF(
        LEFT(
            REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), 6), '') AS INT) AS ibge_code,
    CASE
        WHEN REPLACE(TRIM(BOTH '"' FROM SPLIT_PART(raw_data, ';', 5)), ',', '.') ~ '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(REPLACE(TRIM(BOTH '"' FROM SPLIT_PART(raw_data, ';', 5)), ',', '.') AS NUMERIC(10,2))
        ELSE NULL
    END AS pct_waste_collection
FROM raw.pct_waste_collection
WHERE raw_data LIKE '%;%'
    AND REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g') <> '';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.congenital_anomaly_births AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair o total de nascimentos com anomalia congênita.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS congenital_anomaly_births
FROM raw.congenital_anomaly_births
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.gestational_age AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair o total de nascimentos de acordo com o período gestacional.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS gestational_age
FROM raw.gestational_age
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.births_non_white_mothers AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair o total de nascimentos onde as mães são não brancas.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births_non_white_mothers
FROM raw.births_non_white_mothers
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';


-------------------------------------------------------------------------------------------------

CREATE TABLE stage.primary_care_units AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair o total de postos de saúde/UBS por município.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_primary_care_units
FROM raw.primary_care_units
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';
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
-- Foi necessário utilizar expressões regulares para extrair apenas o número total de visitas prenatais.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS prenatal_visits
FROM raw.prenatal_visits
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';

-------------------------------------------------------------------------------------------------

CREATE TABLE stage.mother_age AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair apenas a idade da mãe.
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

CREATE TABLE stage.birth_weight AS
SELECT
-- Foi necessário utilizar expressões regulares para extrair apenas o código IBGE.
    CAST(NULLIF(
        REGEXP_REPLACE(
            SPLIT_PART(raw_data, ';', 1), '[^0-9]', '', 'g'), '') AS INT) AS ibge_code,
-- Foi necessário utilizar expressões regulares para extrair apenas o peso do bebê.
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
-- Foi necessário utilizar expressões regulares para extrair apenas o número total de mães com diferentes níveis de escolaridade.
    CAST(NULLIF(
        REGEXP_REPLACE(SPLIT_PART(raw_data, ';', 2), '[^0-9]', '', 'g'), '') AS INT) AS total_births,
    CAST(source_file AS TEXT) AS mother_education
FROM raw.mother_education
WHERE raw_data LIKE '%;%'
    AND raw_data NOT ILIKE '%IGNORADO%'
    AND raw_data NOT ILIKE '%Fonte%';



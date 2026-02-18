-- Criação da tabela de municípios na camada raw
CREATE TABLE raw.cities (
    tom_city_code INTEGER,
    ibge_city_code INTEGER,
    tom_city_name TEXT,
    ibge_city_name TEXT,
    state_code CHAR(2)
);

-- Importação dos dados de municípios para a tabela raw.cities
copy raw.cities (tom_city_code, ibge_city_code, tom_city_name, ibge_city_name, state_code) 
FROM 'domain/ibge_municipalities.csv' 
DELIMITER ';' 
CSV HEADER 
ENCODING 'WIN1252';

-------------------------------------------------------------------------------------------------

-- Criação da tabela de IDH na camada raw
-- Foi necessário criar a coluna "extra_column" para conseguir importar o arquivo CSV corretamente, pois o mesmo possui uma vírgula a mais em cada linha.
CREATE TABLE raw.hdi (
    state_code CHAR(2),
    ibge_city_code INT,
    city_name TEXT,
    hdi_2010 NUMERIC,
    extra_column TEXT
);

-- Importação dos dados de IDH 2010 para a tabela raw.hdi
copy raw.hdi (state_code, ibge_city_code, city_name, hdi_2010, extra_column)
FROM 'domain/hdi_index_2010.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-------------------------------------------------------------------------------------------------

-- Criação da tabela de gini_index na camada raw
-- Foi necessário criar a coluna "extra_column" para conseguir importar o arquivo CSV corretamente, pois o mesmo possui uma vírgula a mais em cada linha.
CREATE TABLE raw.gini_index (
    state_code CHAR(2),
    ibge_city_code INT,
    city_name TEXT,
    gini_2010 NUMERIC(4,3),
    extra_column TEXT
);

--Importação dos dados de GINI 2010 para a tabela raw.gini_index
copy raw.gini_index (state_code, ibge_city_code, city_name, gini_2010, extra_column)
FROM 'domain/gini_index_2010.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-------------------------------------------------------------------------------------------------

-- Criação da tabela de óbitos por município na camada raw
-- Devido a diversos erros de parsing, foi necessário importar todo arquivo em uma única coluna de texto bruto.
-- Toda a limpeza e estruturação da tabela será realizada na camada de stage.
CREATE TABLE raw.infant_deaths (
    raw_data TEXT
);

-- Importação dos dados de óbitos infantis por município para a tabela raw.infant_deaths
COPY raw.infant_deaths
FROM 'domain/infant_deaths_2010.csv'
ENCODING 'UTF8';

-------------------------------------------------------------------------------------------------

-- Criação da tabela de nascimentos por município na camada raw
-- Devido a diversos erros de parsing, foi necessário importar todo arquivo em uma única coluna de texto bruto.
-- Toda a limpeza e estruturação da tabela será realizada na camada de stage.
CREATE TABLE raw.births (
    raw_data TEXT
);

-- Importação dos dados de nascimentos por município para a tabela raw.births
COPY raw.births
FROM 'domain/births_2010.csv'
ENCODING 'UTF8';

-------------------------------------------------------------------------------------------------

-- Criação da tabela de visitas prenatais por município na camada raw
-- Devido a diversos erros de parsing, foi necessário importar todo arquivo em uma única coluna de texto bruto.
-- A coluna source_file será utilizada para identificar o arquivo original.
CREATE TABLE raw.prenatal_visits (
    raw_data TEXT,
    source_file TEXT
    );

-- Importação dos dados de visitas prenatais por município para a tabela raw.prenatal_visits
COPY raw.prenatal_visits (raw_data)
FROM 'domain/mother_no_prenatal_visits.csv'
ENCODING 'WIN1252';

-- Atribuição das informações do arquivo original para a coluna source_file
UPDATE raw.prenatal_visits
SET source_file = '0_visits';


COPY raw.prenatal_visits (raw_data)
FROM 'domain/mother_1_to_3_prenatal_visits.csv'
ENCODING 'WIN1252';

UPDATE raw.prenatal_visits
SET source_file = '1_to_3_visits'
WHERE source_file IS NULL;


COPY raw.prenatal_visits (raw_data)
FROM 'domain/mother_4_to_6_prenatal_visits.csv'
ENCODING 'WIN1252';

UPDATE raw.prenatal_visits
SET source_file = '4_to_6_visits'
WHERE source_file IS NULL;


COPY raw.prenatal_visits (raw_data)
FROM 'domain/mother_7_or_more_prenatal_visits.csv'
ENCODING 'WIN1252';

UPDATE raw.prenatal_visits
SET source_file = '7_or_more_visits'
WHERE source_file IS NULL;


-------------------------------------------------------------------------------------------------

-- Criação da tabela de idade da mãe na camada raw
-- Devido a diversos erros de parsing, foi necessário importar todo arquivo em uma coluna de texto bruto.
-- A coluna source_file será utilizada para identificar o arquivo original.
-- Toda a limpeza e estruturação da tabela será realizada na camada de stage.
CREATE TABLE raw.mother_age(
    raw_data TEXT, 
    source_file TEXT
    );

-- Importação dos dados de idade da mãe para a tabela raw.mother_age
COPY raw.mother_age (raw_data)
FROM 'domain/mother_age_10_to_19.csv'
ENCODING 'WIN1252';

-- Atribuição das informações do arquivo original para a coluna source_file
UPDATE raw.mother_age
SET source_file = '10_to_19_age';


COPY raw.mother_age (raw_data)
FROM 'domain/mother_age_20_to_29.csv'
ENCODING 'WIN1252';

UPDATE raw.mother_age
SET source_file = '20_to_29_age'
WHERE source_file IS NULL;


COPY raw.mother_age (raw_data)
FROM 'domain/mother_age_30_to_39.csv'
ENCODING 'WIN1252';

UPDATE raw.mother_age
SET source_file = '30_to_39_age'
WHERE source_file IS NULL;


-------------------------------------------------------------------------------------------------

-- Criação da tabela de renda per capita média por município na camada raw
-- Devido a diversos erros de parsing, foi necessário importar todo arquivo em uma única coluna de texto bruto.
-- Toda a limpeza e estruturação da tabela será realizada na camada de stage.
CREATE TABLE raw.average_income_per_capita(
    raw_data TEXT
);

-- Importação dos dados de renda per capita média por município para a tabela raw.average_income_per_capita
COPY raw.average_income_per_capita (raw_data)
FROM 'domain/average_income_per_capita_2010.csv'
ENCODING 'WIN1252';

-------------------------------------------------------------------------------------------------

-- Criação da tabela de peso do bebê na camada raw
-- Devido a diversos erros de parsing, foi necessário importar todo arquivo em uma coluna de texto bruto.
-- A coluna source_file será utilizada para identificar o arquivo original.
-- Toda a limpeza e estruturação da tabela será realizada na camada de stage.
CREATE TABLE raw.birth_weight(
    raw_data TEXT,
    source_file TEXT
);

-- Importação dos dados de peso do bebê para a tabela raw.birth_weight
COPY raw.birth_weight (raw_data)
FROM 'domain/birth_weight_1kg_to_1499g.csv'
ENCODING 'WIN1252';

-- Atribuição das informações do arquivo original para a coluna source_file
UPDATE raw.birth_weight
SET source_file = '1kg_to_1499g';


COPY raw.birth_weight (raw_data)
FROM 'domain/birth_weight_1500g_to_2499g.csv'
ENCODING 'WIN1252';

UPDATE raw.birth_weight
SET source_file = '1500g_to_2499g'
WHERE source_file IS NULL;


COPY raw.birth_weight (raw_data)
FROM 'domain/birth_weight_2500g_to_3999g.csv'
ENCODING 'WIN1252';

UPDATE raw.birth_weight
SET source_file = '2500g_to_3999g'
WHERE source_file IS NULL;


COPY raw.birth_weight (raw_data)
FROM 'domain/birth_weight_4000g_or_more.csv'
ENCODING 'WIN1252';

UPDATE raw.birth_weight
SET source_file = '4000g_or_more'
WHERE source_file IS NULL;

-------------------------------------------------------------------------------------------------

-- Criação da tabela de esf na camada raw
CREATE TABLE raw.esf(
    raw_data TEXT
);

-- Importação dos dados de esf para a tabela raw.esf
COPY raw.esf
FROM 'domain/esf_june_2010.csv'
ENCODING 'WIN1252';

-------------------------------------------------------------------------------------------------

-- Criação da tabela de escolaridade da mãe na camada raw
-- Devido a diversos erros de parsing, foi necessário importar todo arquivo em uma coluna de texto bruto.
-- A coluna source_file será utilizada para identificar o arquivo original.
-- Toda a limpeza e estruturação da tabela será realizada na camada de stage.
CREATE TABLE raw.mother_education(
    raw_data TEXT,
    source_file TEXT
);

-- Importação dos dados de escolaridade da mãe para a tabela raw.mother_education
COPY raw.mother_education (raw_data)
FROM 'domain/mother_education_0_years.csv'
ENCODING 'WIN1252';

-- Atribuição das informações do arquivo original para a coluna source_file
UPDATE raw.mother_education
SET source_file = '0_years';


COPY raw.mother_education (raw_data)
FROM 'domain/mother_education_1_3_years.csv'
ENCODING 'WIN1252';

UPDATE raw.mother_education
SET source_file = '1_3_years'
WHERE source_file IS NULL;


COPY raw.mother_education (raw_data)
FROM 'domain/mother_education_4_7_years.csv'
ENCODING 'WIN1252';

UPDATE raw.mother_education
SET source_file = '4_7_years'
WHERE source_file IS NULL;


COPY raw.mother_education (raw_data)
FROM 'domain/mother_education_8_11_years.csv'
ENCODING 'WIN1252';

UPDATE raw.mother_education
SET source_file = '8_11_years'
WHERE source_file IS NULL;


COPY raw.mother_education (raw_data)
FROM 'domain/mother_education_12_more_years.csv'
ENCODING 'WIN1252';

UPDATE raw.mother_education
SET source_file = '12_more_years'
WHERE source_file IS NULL;
-- Criação dos schemas no banco de dados para separar as camadas do processo de ETL;
-- raw: Esta camada contém os dados brutos importados dos arquivos CSV;
-- stage: Esta camada contém os dados recebidos pela raw, onde são realizadas as transformações necessárias para serem utilizados na produção;
-- prod: Esta camada contém os dados finais estruturados e prontos para serem utilizados.

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stage;
CREATE SCHEMA IF NOT EXISTS prod;
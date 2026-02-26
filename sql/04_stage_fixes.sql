-- Neste arquivo, estão os scripts que foram utilizados para realizar algumas tratativas necessárias para corrigir erros de criação das tabelas de produção.

DELETE FROM stage.hdi WHERE hdi IS NULL;

DELETE FROM stage.gini WHERE gini IS NULL;

DELETE FROM stage.infant_deaths WHERE infant_deaths IS NULL;

DELETE FROM stage.births WHERE births IS NULL;
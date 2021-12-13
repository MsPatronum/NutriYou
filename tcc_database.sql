-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 13-Dez-2021 às 11:43
-- Versão do servidor: 10.4.18-MariaDB
-- versão do PHP: 8.0.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `tcc_database`
--
CREATE DATABASE IF NOT EXISTS `tcc_database` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `tcc_database`;

DELIMITER $$
--
-- Procedimentos
--
DROP PROCEDURE IF EXISTS `add_receitanarefeicao`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_receitanarefeicao` (IN `user_id` INT, `cod_refeicao` INT, `cod_receita` INT, `porcoes` FLOAT, `todaydate` DATE, OUT `resposta` VARCHAR(40))  BEGIN
	declare userdia_id, udmacros_id, udmomento_id int; 
    declare momento_kcal, kcal, rec_kcal, new_kcal, rec_porcoes, new_porcoes, prot, rec_prot, carb, rec_carb, gord, rec_gord, fibra, rec_fibra float;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
            ROLLBACK;
            RESIGNAL;
		END;
	SET resposta = 'ERRO';
	START TRANSACTION;
	
    -- get id do user_dia, macros e momento e kcal
    set userdia_id = (select ud.user_dia_id from user_dia ud where ud.usuario_id = user_id and user_dia_data = todaydate);
    set udmacros_id = (select udm.user_dia_macros_id from user_dia_macros udm where udm.user_dia_id = userdia_id);
    
                        
	-- get macros
	set kcal = (select udm.udm_kcal from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_kcal = (select r.energy_kcal from receita_val_nutricional r where r.receita_id = cod_receita);
    set prot = (select udm.udm_prot from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_prot = (select r.protein_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set carb = (select udm.udm_carb from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_carb = (select r.carbohydrate_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set gord = (select udm.udm_gord from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_gord = (select r.lipid_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set fibra = (select udm.udm_fibra from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_fibra = (select r.fiber_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set rec_porcoes = (select r.receita_porcoes from receita r where r.receita_id = cod_receita);
    
    -- calcular porcoes
    set new_porcoes = porcoes/rec_porcoes;
    -- calcular macros
    set kcal = kcal + (rec_kcal*new_porcoes);
    set prot = prot + (rec_prot*new_porcoes);
    set carb = carb + (rec_carb*new_porcoes);
    set gord = gord + (rec_gord*new_porcoes);
    set fibra = fibra + (rec_fibra*new_porcoes);
    
    -- vendo se já existe momento
    if 
		(select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao) is not null
    then
		set udmomento_id = (select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao);
        set momento_kcal = (select udo.momento_kcal from user_dia_momento udo where udo.user_dia_momento_id = udmomento_id);
        set momento_kcal = momento_kcal + (rec_kcal * new_porcoes);
        update user_dia_momento udo set udo.momento_kcal = momento_kcal where udo.user_dia_momento_id = udmomento_id;
	else 
		insert into user_dia_momento (user_dia_id, momento_id, momento_kcal) value (userdia_id, cod_refeicao, kcal); 
		set udmomento_id = (select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao);
	end if;  
    
    
    -- adicionar receita na refeição
    insert into udm_receita(user_dia_momento_id, receita_id, udm_porcoes) value (udmomento_id, cod_receita, porcoes);
  -- adicionar macros da receita no user_dia_macros
	UPDATE user_dia_macros 	SET udm_kcal = kcal, udm_prot = prot, udm_carb = carb, udm_gord = gord,	udm_fibra = fibra WHERE user_dia_id = userdia_id;
	  
    SET resposta = 'OK';
	COMMIT;

END$$

DROP PROCEDURE IF EXISTS `create_user`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_user` (IN `nome` VARCHAR(45), IN `sobrenome` VARCHAR(45), IN `email` VARCHAR(45), IN `senha` VARCHAR(45), IN `tipo` BOOL, IN `token` VARCHAR(12), IN `is_active` BOOL, IN `peso` FLOAT, IN `altura` FLOAT, IN `sexo` CHAR(1), IN `data_nasc` DATE, OUT `resposta` TEXT)  BEGIN
	declare kcal_total int;
	declare carb double;
	declare gord double;
	declare prot double;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
            ROLLBACK;
            RESIGNAL;
		END;
	SET resposta = 'ERRO';
	START TRANSACTION;
    -- INSERINDO O USUÁRIO
	INSERT INTO usuario ( usuario_nome, usuario_sobrenome, usuario_email, usuario_senha, usuario_tipo, usuario_token) VALUES (nome,sobrenome,email,senha,tipo,token);
	SET @last_id = LAST_INSERT_ID();
    -- INSERINDO INFORMAÇÕES DO USUÁRIO
	INSERT INTO usuario_configs_ref (usuario_id, ucr_datanasc, ucr_peso, ucr_sexo, ucr_is_active, ucr_altura) 
		VALUES( @last_id, data_nasc, peso, sexo, is_active, altura );
	-- INSERINDO O PRIMEIRO REGISTRO DE PESO NA TABELA DE HISTÓRICO DE PESO
	INSERT INTO user_peso_historico values (null, @last_id, curdate(), peso);  
    -- INSERINDO A CONFIGURAÇÃO PADRÃO DA TABELA MOOD
    INSERT INTO usuario_configs_mood (usuario_id) VALUES (@last_id);
    
     -- INSERINDO AS CONFIGURAÇÕES PADRÃO DE MACRONUTRIENTES
    SET kcal_total = new_kcaltotal(peso, data_nasc, sexo);
    set carb =  divide_macros(65,kcal_total, 'carb');
    set gord =  divide_macros(22.5,kcal_total, 'gord');
    set prot =  divide_macros(12.5,kcal_total, 'prot');
    INSERT INTO usuario_configs_macros (usuario_id, ucm_kcal, ucm_carb, ucm_prot, ucm_gord) values (@last_id, kcal_total, carb, prot, gord); 
	SET resposta = 'OK';
	COMMIT;
end$$

DROP PROCEDURE IF EXISTS `new_day`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `new_day` (IN `user_id` INT, IN `user_data` DATE, OUT `resposta` TEXT)  BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
            ROLLBACK;
            RESIGNAL;
		END;
	SET resposta = 'ERRO';
	START TRANSACTION;
	INSERT INTO user_dia (usuario_id, user_dia_data) values (user_id, user_data);
		SET @last_id = LAST_INSERT_ID();
	INSERT INTO user_dia_macros (user_dia_id, udc_kcal, udc_prot, udc_carb, udc_gord) 
		SELECT @last_id, ucm.ucm_kcal, ucm.ucm_prot, ucm.ucm_carb, ucm.ucm_gord FROM usuario_configs_macros ucm where ucm.usuario_id = user_id;
	SET resposta = 'OK';
	COMMIT;
end$$

DROP PROCEDURE IF EXISTS `remove_ingredient`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `remove_ingredient` (IN `receita_id` INT, `ingrediente_id` INT)  BEGIN
	DECLARE qtd,
			new_humidity_qtd, new_protein_qtd, new_lipid_qtd, new_carbohydrate_qtd, new_fiber_qtd, new_energy_kcal, new_energy_kj, 
			rec_humidity_qtd, rec_protein_qtd, rec_lipid_qtd, rec_carbohydrate_qtd, rec_fiber_qtd, rec_energy_kcal, rec_energy_kj, 
			ing_humidity_qtd, ing_protein_qtd, ing_lipid_qtd, ing_carbohydrate_qtd, ing_fiber_qtd, ing_energy_kcal, ing_energy_kj float;
    declare	new_humidity_unit, new_protein_unit, new_lipid_unit, new_carbohydrate_unit, new_fiber_unit,
			rec_humidity_unit, rec_protein_unit, rec_lipid_unit, rec_carbohydrate_unit, rec_fiber_unit, 
			ing_humidity_unit, ing_protein_unit, ing_lipid_unit, ing_carbohydrate_unit, ing_fiber_unit Varchar(2);
    
    -- setar quantidade dos ingredientes
    set qtd = (SELECT ri.receita_ingredientes_qtd from receita_ingredientes ri 
				where ri.receita_id = receita_id and ri.ingredientes_id = ingrediente_id);
    
    -- setar os valores do ingrediente
    set ing_humidity_qtd = (SELECT ivn.humidity_qtd from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_protein_qtd = (SELECT ivn.protein_qtd from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_lipid_qtd = (SELECT ivn.lipid_qtd from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_carbohydrate_qtd = (SELECT ivn.carbohydrate_qtd from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_fiber_qtd = (SELECT ivn.fiber_qtd from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_energy_kcal = (SELECT ivn.energy_kcal from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_energy_kj = (SELECT ivn.energy_kj from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_humidity_unit = (SELECT ivn.humidity_unit from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_protein_unit = (SELECT ivn.protein_unit from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_lipid_unit = (SELECT ivn.lipid_unit from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_carbohydrate_unit = (SELECT ivn.carbohydrate_unit from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    set ing_fiber_unit = (SELECT ivn.fiber_unit from ingrediente_val_nutricional ivn where ivn.ingrediente_id = ingrediente_id); 
    
    -- setar os valores da receita
    set rec_humidity_qtd = (SELECT rvn.humidity_qtd from receita_val_nutricional rvn where rvn.receita_id = receita_id);
    set rec_protein_qtd = (SELECT rvn.protein_qtd from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_lipid_qtd = (SELECT rvn.lipid_qtd from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_carbohydrate_qtd = (SELECT rvn.carbohydrate_qtd from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_fiber_qtd = (SELECT rvn.fiber_qtd from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_energy_kcal = (SELECT rvn.energy_kcal from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_energy_kj = (SELECT rvn.energy_kj from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_humidity_unit = (SELECT rvn.humidity_unit from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_protein_unit = (SELECT rvn.protein_unit from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_lipid_unit = (SELECT rvn.lipid_unit from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_carbohydrate_unit = (SELECT rvn.carbohydrate_unit from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    set rec_fiber_unit = (SELECT rvn.fiber_unit from receita_val_nutricional rvn where rvn.receita_id = receita_id); 
    
    set new_humidity_qtd =				rec_humidity_qtd - (ing_humidity_qtd * qtd) ; 
    set new_protein_qtd =				rec_protein_qtd - (ing_protein_qtd *qtd); 
    set new_lipid_qtd =					rec_lipid_qtd - (ing_lipid_qtd *qtd); 
    set new_carbohydrate_qtd =			rec_carbohydrate_qtd - (ing_carbohydrate_qtd *qtd) ; 
    set new_fiber_qtd =					rec_fiber_qtd - (ing_fiber_qtd *qtd); 
    set new_energy_kcal =				rec_energy_kcal - (ing_energy_kcal *qtd); 
    set new_energy_kj =					rec_energy_kj - (ing_energy_kj *qtd);
    
    -- update receita_val_nutricional
    UPDATE receita_val_nutricional rvn set  rvn.humidity_qtd = new_humidity_qtd, rvn.protein_qtd = new_protein_qtd, 
    rvn.lipid_qtd = new_lipid_qtd, rvn.carbohydrate_qtd = new_carbohydrate_qtd, rvn.fiber_qtd = new_fiber_qtd, rvn.energy_kcal = new_energy_kcal, 
    rvn.energy_kj = new_energy_kj where rvn.receita_id = receita_id;
    
    delete from receita_ingredientes where receita_id = receita_id and ingredientes_id = ingrediente_id;
    

END$$

DROP PROCEDURE IF EXISTS `remove_receitadarefeica`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `remove_receitadarefeica` (IN `user_id` INT, `cod_refeicao` INT, `cod_receita` INT, `todaydate` DATE, OUT `resposta` VARCHAR(40))  BEGIN

	declare userdia_id, udmacros_id, udmomento_id int; 
    declare momento_kcal, kcal, rec_kcal, new_kcal, prot, rec_prot, carb, rec_carb, gord, rec_gord, fibra, rec_fibra float;
    
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
            ROLLBACK;
            RESIGNAL;
		END;
	SET resposta = 'ERRO';
	START TRANSACTION;
	
    -- get id do user_dia, macros e momento e kcal
    set userdia_id = (select ud.user_dia_id from user_dia ud where ud.usuario_id = user_id and user_dia_data = todaydate);
    set udmacros_id = (select udm.user_dia_macros_id from user_dia_macros udm where udm.user_dia_id = userdia_id);
    
                        
	-- get macros
	set kcal = (select udm.udm_kcal from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_kcal = (select r.energy_kcal from receita_val_nutricional r where r.receita_id = cod_receita);
    set prot = (select udm.udm_prot from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_prot = (select r.protein_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set carb = (select udm.udm_carb from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_carb = (select r.carbohydrate_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set gord = (select udm.udm_gord from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_gord = (select r.lipid_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set fibra = (select udm.udm_fibra from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_fibra = (select r.fiber_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    
    -- calcular macros
    set kcal = kcal - rec_kcal;
    set prot = prot - rec_prot;
    set carb = carb - rec_carb;
    set gord = gord - rec_gord;
    set fibra = fibra - rec_fibra;
    
    -- vendo se já existe momento
    if 
		(select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao) is not null
    then
		set udmomento_id = (select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao);
        set momento_kcal = (select udo.momento_kcal from user_dia_momento udo where udo.user_dia_momento_id = udmomento_id);
        set momento_kcal = momento_kcal - rec_kcal;
        update user_dia_momento udo set udo.momento_kcal = momento_kcal where udo.user_dia_momento_id = udmomento_id;
	else 
		insert into user_dia_momento (user_dia_id, momento_id, momento_kcal) value (userdia_id, cod_refeicao, rec_kcal); 
		set udmomento_id = (select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao);
	end if;  
    
    
    -- remover receita da refeição
    delete from udm_receita where user_dia_momento = udmomento_id and receita_id = cod_receita;
	-- remover macros da receita no user_dia_macros
	UPDATE user_dia_macros 	SET udm_kcal = kcal, udm_prot = prot, udm_carb = carb, udm_gord = gord,	udm_fibra = fibra WHERE user_dia_id = userdia_id;
	  
    SET resposta = 'OK';
	COMMIT;
    

END$$

DROP PROCEDURE IF EXISTS `remove_receitadarefeicao`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `remove_receitadarefeicao` (IN `user_id` INT, `cod_refeicao` INT, `udmId` INT, `cod_receita` INT, `todaydate` DATE, OUT `resposta` VARCHAR(40))  BEGIN

	declare userdia_id, udmacros_id, udmomento_id int; 
    declare momento_kcal, kcal, rec_kcal, new_kcal, prot, rec_prot, carb, rec_carb, gord, rec_gord, fibra, rec_fibra,porcoes, rec_porcoes, new_porcoes float;
    
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
            ROLLBACK;
            RESIGNAL;
		END;
	SET resposta = 'ERRO';
	START TRANSACTION;
	
    -- get id do user_dia, macros e momento e kcal
    set userdia_id = (select ud.user_dia_id from user_dia ud where ud.usuario_id = user_id and user_dia_data = todaydate);
    set udmacros_id = (select udm.user_dia_macros_id from user_dia_macros udm where udm.user_dia_id = userdia_id);
    
                        
	-- get macros
	set kcal = (select udm.udm_kcal from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_kcal = (select r.energy_kcal from receita_val_nutricional r where r.receita_id = cod_receita);
    set prot = (select udm.udm_prot from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_prot = (select r.protein_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set carb = (select udm.udm_carb from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_carb = (select r.carbohydrate_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set gord = (select udm.udm_gord from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_gord = (select r.lipid_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set fibra = (select udm.udm_fibra from user_dia_macros udm where udm.user_dia_id = userdia_id);
    set rec_fibra = (select r.fiber_qtd from receita_val_nutricional r where r.receita_id = cod_receita);
    set porcoes = (select r.udm_porcoes from udm_receita r where r.receita_id = cod_receita and r.user_dia_momento_id = userdia_id);
    set rec_porcoes = (select r.receita_porcoes from receita r where r.receita_id = cod_receita);
    
    -- calcular porcoes
    set new_porcoes = porcoes/rec_porcoes;
    
    -- calcular macros
    set kcal = kcal - (rec_kcal * new_porcoes);
	set prot = prot - (rec_prot * new_porcoes);
	set carb = carb - (rec_carb * new_porcoes);
	set gord = gord - (rec_gord * new_porcoes);
	set fibra = fibra - (rec_fibra * new_porcoes);
    
    -- vendo se já existe momento
    if 
		(select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao) is not null
    then
		set udmomento_id = (select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao);
        set momento_kcal = (select udo.momento_kcal from user_dia_momento udo where udo.user_dia_momento_id = udmomento_id);
        set momento_kcal = momento_kcal - (rec_kcal * new_porcoes);
        update user_dia_momento udo set udo.momento_kcal = momento_kcal where udo.user_dia_momento_id = udmomento_id;
	else 
		insert into user_dia_momento (user_dia_id, momento_id, momento_kcal) value (userdia_id, cod_refeicao, kcal); 
		set udmomento_id = (select udo.user_dia_momento_id from user_dia_momento udo where udo.user_dia_id = userdia_id and udo.momento_id = cod_refeicao);
	end if;  
    
    
    -- remover receita da refeição
    delete from udm_receita where user_dia_momento_id = udmomento_id and receita_id = cod_receita and udm_receita_id = udmId;
	-- remover macros da receita no user_dia_macros
	UPDATE user_dia_macros 	SET udm_kcal = kcal, udm_prot = prot, udm_carb = carb, udm_gord = gord,	udm_fibra = fibra WHERE user_dia_id = userdia_id;
	  
    SET resposta = 'OK';
	COMMIT;
    

END$$

DROP PROCEDURE IF EXISTS `set_mood`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_mood` (IN `func` TEXT, `user_id` INT, `user_dia` DATE, `e_feliz` BOOL, `e_sensivel` BOOL, `e_triste` BOOL, `e_raiva` BOOL, `s_0a3` BOOL, `s_3a6` BOOL, `s_6a9` BOOL, `s_9oumais` BOOL, `v_ativo` BOOL, `v_alta` BOOL, `v_baixa` BOOL, `v_exaustao` BOOL, `b_otimo` BOOL, `b_normal` BOOL, `b_prisaoventre` BOOL, `b_diarreia` BOOL, `d_doce` BOOL, `d_salgado` BOOL, `d_carboidratos` BOOL, `d_otimo` BOOL, `d_inchaco` BOOL, `d_enjoo` BOOL, `d_comgases` BOOL, `p_boa` BOOL, `p_oleosa` BOOL, `p_seca` BOOL, `p_acne` BOOL, `m_focado` BOOL, `m_tranquilidade` BOOL, `m_distracao` BOOL, `m_estresse` BOOL, `m_motivado` BOOL, `m_desaminado` BOOL, `m_produtivo` BOOL, `m_preguica` BOOL, `p_kg` FLOAT, `e_corrida` BOOL, `e_academia` BOOL, `e_bicicleta` BOOL, `e_natacao` BOOL, `f_bebidas` BOOL, `f_fumo` BOOL, `f_ressaca` BOOL, `f_outrassubs` BOOL)  BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
            ROLLBACK;
            RESIGNAL;
		END;
	START TRANSACTION;
		     
        -- SE FUNÇÃO FOR IGUAL À INSERT, INSERIR NA BASE DE DADOS
        IF (func = "INSERT") then
        SET @dia_id = (SELECT user_dia_id FROM user_dia WHERE usuario_id = user_id AND  user_dia_data = user_dia);
		INSERT INTO user_dia_mood (user_dia_id,  emocoes_feliz,  emocoes_sensivel,  emocoes_triste,  emocoes_raiva,  sono_0a3,  sono_3a6,  sono_6a9,  sono_9oumais,  vitalidade_ativo,  vitalidade_alta,  vitalidade_baixa,  vitalidade_exaustao,  banheiro_otimo,  banheiro_normal,  banheiro_prisaoventre,  banheiro_diarreia,  desejo_doce,  desejo_salgado,  desejo_carboidratos,  digestao_otimo,  digestao_inchaco,  digestao_enjoo,  digestao_comgases,  pele_boa, pele_oleosa,  pele_seca, pele_acne,  mental_focado,  mental_tranquilidade,  mental_distracao,  mental_estresse,  motivacao_motivado,  motivacao_desanimado,  motivacao_produtivo,  motivacao_preguica,  peso_kg,  exercicio_corrida,  exercicio_academia,  exercicio_bicicleta,  exercicio_natacao,  festa_bebidas,  festa_fumo,  festa_ressaca,  festa_outrassubs) 
		VALUES (  @dia_id, e_feliz, e_sensivel, e_triste, e_raiva, s_0a3, s_3a6, s_6a9, s_9oumais, v_ativo, v_alta, v_baixa, v_exaustao, b_otimo, b_normal, b_prisaoventre, b_diarreia, d_doce, d_salgado, d_carboidratos, d_otimo, d_inchaco, d_enjoo, d_comgases, p_boa, p_oleosa, p_seca, p_acne, m_focado, m_tranquilidade, m_distracao, m_estresse, m_motivado, m_desaminado, m_produtivo, m_preguica, p_kg, e_corrida, e_academia, e_bicicleta, e_natacao, f_bebidas, f_fumo, f_ressaca, f_outrassubs);
		
        -- SE FUNÇÃO FOR IGUAL A UPDATE, REALIZAR O UPDATE DAS INFORMAÇÕES
        ELSEIF (func = "UPDATE") THEN
        SET @dia_id = (SELECT user_dia_id FROM v_userdiamood WHERE usuario_id = user_id AND  user_dia_data = user_dia);
        UPDATE user_dia_mood SET emocoes_feliz = e_feliz,  emocoes_sensivel = e_sensivel,  emocoes_triste = e_triste,  emocoes_raiva = e_raiva,  sono_0a3 = s_0a3,  sono_3a6 = s_3a6,  sono_6a9 = s_6a9,  sono_9oumais = s_9oumais,  vitalidade_ativo = v_ativo,  vitalidade_alta = v_alta,  vitalidade_baixa = v_baixa,  vitalidade_exaustao = v_exaustao,  banheiro_otimo = b_otimo,  banheiro_normal = b_normal,  banheiro_prisaoventre = b_prisaoventre,  banheiro_diarreia = b_diarreia,  desejo_doce = d_doce,  desejo_salgado = d_salgado,  desejo_carboidratos = d_carboidratos,  digestao_otimo = d_otimo,  digestao_inchaco = d_inchaco,  digestao_enjoo = d_enjoo,  digestao_comgases = d_comgases,  pele_boa = p_boa, pele_oleosa = p_oleosa,  pele_seca = p_seca, pele_acne = p_acne,  mental_focado = m_focado,  mental_tranquilidade = m_tranquilidade,  mental_distracao = m_distracao,  mental_estresse = m_estresse,  motivacao_motivado = m_motivado,  motivacao_desanimado = m_desaminado,  motivacao_produtivo = m_produtivo,  motivacao_preguica = m_preguica,  peso_kg = p_kg,  exercicio_corrida = e_corrida,  exercicio_academia = e_academia,  exercicio_bicicleta = e_bicicleta,  exercicio_natacao = e_natacao,  festa_bebidas = f_bebidas,  festa_fumo = f_fumo,  festa_ressaca = f_ressaca,  festa_outrassubs = f_outrassubs WHERE user_dia_mood_id = @dia_id; 
        END IF;
		
	COMMIT;
end$$

--
-- Funções
--
DROP FUNCTION IF EXISTS `divide_macros`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `divide_macros` (`perc_macro` INT, `kcal_total` INT, `tipo` CHAR) RETURNS DOUBLE BEGIN

	DECLARE macro_total double;
    set macro_total = kcal_total * perc_macro/100;
    
    CASE tipo
		when tipo = "carb"
        then set macro_total = macro_total / 4;
        when tipo = "prot"
        then set macro_total = macro_total / 4;
        when tipo = "gord"
        then set macro_total = macro_total / 9;
	end case;
    
    return macro_total;
END$$

DROP FUNCTION IF EXISTS `new_kcaltotal`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `new_kcaltotal` (`peso` DOUBLE, `datanasc` DATE, `sexo` CHAR(1)) RETURNS INT(11) BEGIN
declare kcal_total double;
declare idade int;
	set idade = FLOOR(DATEDIFF(now(),datanasc)/365); 
	if (sexo = "M") then
		if (idade >= 0 && idade <= 2) then  
			set kcal_total = ((60.9 * peso) - 54);
		elseif (idade >= 3 && idade <= 9) then
			set kcal_total = ((22.7 * peso) + 495);
		elseif (idade >= 10 && idade <= 17) then
			set kcal_total = ((17.5 * peso) + 651);
		elseif (idade >= 18 && idade <= 29) then
			set kcal_total = ((15.3 * peso) + 679);
		elseif (idade >= 30 && idade <= 59) then
			set kcal_total = ((11.6 * peso) + 879);
		elseif (idade >= 60) then
			set kcal_total = ((13.5 * peso) + 487);
		end if;
	elseif (sexo = "F") then
		if (idade >= 0 && idade <= 2) then  
			set kcal_total = ((61.0 * peso) - 51);
		elseif (idade >= 3 && idade <= 9) then
			set kcal_total = ((22.5 * peso) + 499);
		elseif (idade >= 10 && idade <= 17) then
			set kcal_total = ((12.2 * peso) + 746);
		elseif (idade >= 18 && idade <= 29) then
			set kcal_total = ((14.7 * peso) + 496);
		elseif (idade >= 30 && idade <= 59) then
			set kcal_total = ((8.7 * peso) + 829);
		elseif (idade >= 60) then
			set kcal_total = ((12.5 * peso) + 596);
		end if;
	end if;
RETURN kcal_total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `categoria_i`
--

DROP TABLE IF EXISTS `categoria_i`;
CREATE TABLE `categoria_i` (
  `categoria_i_id` int(11) NOT NULL,
  `categoria_desc` varchar(45) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Extraindo dados da tabela `categoria_i`
--

INSERT INTO `categoria_i` (`categoria_i_id`, `categoria_desc`) VALUES
(1, 'Cereais e derivados'),
(2, 'Verduras, hortaliças e derivados'),
(3, 'Frutas e derivados'),
(4, 'Gorduras e óleos'),
(5, 'Pescados e frutos do mar'),
(6, 'Carnes e derivados'),
(7, 'Leite e derivados'),
(8, 'Bebidas (alcoólicas e não alcoólicas)'),
(9, 'Ovos e derivados'),
(10, 'Produtos açucarados'),
(11, 'Miscelâneas'),
(12, 'Outros alimentos industrializados'),
(13, 'Alimentos preparados'),
(14, 'Leguminosas e derivados'),
(15, 'Nozes e sementes');

-- --------------------------------------------------------

--
-- Estrutura da tabela `categoria_r`
--

DROP TABLE IF EXISTS `categoria_r`;
CREATE TABLE `categoria_r` (
  `categoria_r_id` int(11) NOT NULL,
  `categoria_r_nome` varchar(50) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Extraindo dados da tabela `categoria_r`
--

INSERT INTO `categoria_r` (`categoria_r_id`, `categoria_r_nome`) VALUES
(1, 'Sem açúcar'),
(2, 'Vegano'),
(3, 'Sem Lactose'),
(4, 'Sem Glúten'),
(5, 'Vegetariano'),
(6, 'Sem Leite'),
(7, 'Sem Gorduras Trans');

-- --------------------------------------------------------

--
-- Estrutura da tabela `ingredientes`
--

DROP TABLE IF EXISTS `ingredientes`;
CREATE TABLE `ingredientes` (
  `ingredientes_id` int(11) NOT NULL,
  `ingredientes_desc` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `ingredientes_base_qtd` float DEFAULT NULL,
  `ingredientes_base_unity` varchar(45) COLLATE utf8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Extraindo dados da tabela `ingredientes`
--

INSERT INTO `ingredientes` (`ingredientes_id`, `ingredientes_desc`, `ingredientes_base_qtd`, `ingredientes_base_unity`) VALUES
(1, 'Arroz, integral, cozido', 100, 'g'),
(2, 'Arroz, integral, cru', 100, 'g'),
(3, 'Arroz, tipo 1, cozido', 100, 'g'),
(4, 'Arroz, tipo 1, cru', 100, 'g'),
(5, 'Arroz, tipo 2, cozido', 100, 'g'),
(6, 'Arroz, tipo 2, cru', 100, 'g'),
(7, 'Aveia, flocos, crua', 100, 'g'),
(8, 'Biscoito, doce, maisena', 100, 'g'),
(9, 'Biscoito, doce, recheado com chocolate', 100, 'g'),
(10, 'Biscoito, doce, recheado com morango', 100, 'g'),
(11, 'Biscoito, doce, wafer, recheado de chocolate', 100, 'g'),
(12, 'Biscoito, doce, wafer, recheado de morango', 100, 'g'),
(13, 'Biscoito, salgado, cream cracker', 100, 'g'),
(14, 'Bolo, mistura para', 100, 'g'),
(15, 'Bolo, pronto, aipim', 100, 'g'),
(16, 'Bolo, pronto, chocolate', 100, 'g'),
(17, 'Bolo, pronto, coco', 100, 'g'),
(18, 'Bolo, pronto, milho', 100, 'g'),
(19, 'Canjica, branca, crua', 100, 'g'),
(20, 'Canjica, com leite integral', 100, 'g'),
(21, 'Cereais, milho, flocos, com sal', 100, 'g'),
(22, 'Cereais, milho, flocos, sem sal', 100, 'g'),
(23, 'Cereais, mingau, milho, infantil', 100, 'g'),
(24, 'Cereais, mistura para vitamina, trigo, cevada e aveia', 100, 'g'),
(25, 'Cereal matinal, milho', 100, 'g'),
(26, 'Cereal matinal, milho, açúcar', 100, 'g'),
(27, 'Creme de arroz, pó', 100, 'g'),
(28, 'Creme de milho, pó', 100, 'g'),
(29, 'Curau, milho verde', 100, 'g'),
(30, 'Curau, milho verde, mistura para', 100, 'g'),
(31, 'Farinha, de arroz, enriquecida', 100, 'g'),
(32, 'Farinha, de centeio, integral', 100, 'g'),
(33, 'Farinha, de milho, amarela', 100, 'g'),
(34, 'Farinha, de rosca', 100, 'g'),
(35, 'Farinha, de trigo', 100, 'g'),
(36, 'Farinha, láctea, de cereais', 100, 'g'),
(37, 'Lasanha, massa fresca, cozida', 100, 'g'),
(38, 'Lasanha, massa fresca, crua', 100, 'g'),
(39, 'Macarrão, instantâneo', 100, 'g'),
(40, 'Macarrão, trigo, cru', 100, 'g'),
(41, 'Macarrão, trigo, cru, com ovos', 100, 'g'),
(42, 'Milho, amido, cru', 100, 'g'),
(43, 'Milho, fubá, cru', 100, 'g'),
(44, 'Milho, verde, cru', 100, 'g'),
(45, 'Milho, verde, enlatado, drenado', 100, 'g'),
(46, 'Mingau tradicional, pó', 100, 'g'),
(47, 'Pamonha, barra para cozimento, pré-cozida', 100, 'g'),
(48, 'Pão, aveia, forma', 100, 'g'),
(49, 'Pão, de soja', 100, 'g'),
(50, 'Pão, glúten, forma', 100, 'g'),
(51, 'Pão, milho, forma', 100, 'g'),
(52, 'Pão, trigo, forma, integral', 100, 'g'),
(53, 'Pão, trigo, francês', 100, 'g'),
(54, 'Pão, trigo, sovado', 100, 'g'),
(55, 'Pastel, de carne, cru', 100, 'g'),
(56, 'Pastel, de carne, frito', 100, 'g'),
(57, 'Pastel, de queijo, cru', 100, 'g'),
(58, 'Pastel, de queijo, frito', 100, 'g'),
(59, 'Pastel, massa, crua', 100, 'g'),
(60, 'Pastel, massa, frita', 100, 'g'),
(61, 'Pipoca, com óleo de soja, sem sal', 100, 'g'),
(62, 'Polenta, pré-cozida', 100, 'g'),
(63, 'Torrada, pão francês', 100, 'g'),
(64, 'Abóbora, cabotian, cozida', 100, 'g'),
(65, 'Abóbora, cabotian, crua', 100, 'g'),
(66, 'Abóbora, menina brasileira, crua', 100, 'g'),
(67, 'Abóbora, moranga, crua', 100, 'g'),
(68, 'Abóbora, moranga, refogada', 100, 'g'),
(69, 'Abóbora, pescoço, crua', 100, 'g'),
(70, 'Abobrinha, italiana, cozida', 100, 'g'),
(71, 'Abobrinha, italiana, crua', 100, 'g'),
(72, 'Abobrinha, italiana, refogada', 100, 'g'),
(73, 'Abobrinha, paulista, crua', 100, 'g'),
(74, 'Acelga, crua', 100, 'g'),
(75, 'Agrião, cru', 100, 'g'),
(76, 'Aipo, cru', 100, 'g'),
(77, 'Alface, americana, crua', 100, 'g'),
(78, 'Alface, crespa, crua', 100, 'g'),
(79, 'Alface, lisa, crua', 100, 'g'),
(80, 'Alface, roxa, crua', 100, 'g'),
(81, 'Alfavaca, crua', 100, 'g'),
(82, 'Alho, cru', 100, 'g'),
(83, 'Alho-poró, cru', 100, 'g'),
(84, 'Almeirão, cru', 100, 'g'),
(85, 'Almeirão, refogado', 100, 'g'),
(86, 'Batata, baroa, cozida', 100, 'g'),
(87, 'Batata, baroa, crua', 100, 'g'),
(88, 'Batata, doce, cozida', 100, 'g'),
(89, 'Batata, doce, crua', 100, 'g'),
(90, 'Batata, frita, tipo chips, industrializada', 100, 'g'),
(91, 'Batata, inglesa, cozida', 100, 'g'),
(92, 'Batata, inglesa, crua', 100, 'g'),
(93, 'Batata, inglesa, frita', 100, 'g'),
(94, 'Batata, inglesa, sauté', 100, 'g'),
(95, 'Berinjela, cozida', 100, 'g'),
(96, 'Berinjela, crua', 100, 'g'),
(97, 'Beterraba, cozida', 100, 'g'),
(98, 'Beterraba, crua', 100, 'g'),
(99, 'Biscoito, polvilho doce', 100, 'g'),
(100, 'Brócolis, cozido', 100, 'g'),
(101, 'Brócolis, cru', 100, 'g'),
(102, 'Cará, cozido', 100, 'g'),
(103, 'Cará, cru', 100, 'g'),
(104, 'Caruru, cru', 100, 'g'),
(105, 'Catalonha, crua', 100, 'g'),
(106, 'Catalonha, refogada', 100, 'g'),
(107, 'Cebola, crua', 100, 'g'),
(108, 'Cebolinha, crua', 100, 'g'),
(109, 'Cenoura, cozida', 100, 'g'),
(110, 'Cenoura, crua', 100, 'g'),
(111, 'Chicória, crua', 100, 'g'),
(112, 'Chuchu, cozido', 100, 'g'),
(113, 'Chuchu, cru', 100, 'g'),
(114, 'Coentro, folhas desidratadas', 100, 'g'),
(115, 'Couve, manteiga, crua', 100, 'g'),
(116, 'Couve, manteiga, refogada', 100, 'g'),
(117, 'Couve-flor, crua', 100, 'g'),
(118, 'Couve-flor, cozida', 100, 'g'),
(119, 'Espinafre, Nova Zelândia, cru', 100, 'g'),
(120, 'Espinafre, Nova Zelândia, refogado', 100, 'g'),
(121, 'Farinha, de mandioca, crua', 100, 'g'),
(122, 'Farinha, de mandioca, torrada', 100, 'g'),
(123, 'Farinha, de puba', 100, 'g'),
(124, 'Fécula, de mandioca', 100, 'g'),
(125, 'Feijão, broto, cru', 100, 'g'),
(126, 'Inhame, cru', 100, 'g'),
(127, 'Jiló, cru', 100, 'g'),
(128, 'Jurubeba, crua', 100, 'g'),
(129, 'Mandioca, cozida', 100, 'g'),
(130, 'Mandioca, crua', 100, 'g'),
(131, 'Mandioca, farofa, temperada', 100, 'g'),
(132, 'Mandioca, frita', 100, 'g'),
(133, 'Manjericão, cru', 100, 'g'),
(134, 'Maxixe, cru', 100, 'g'),
(135, 'Mostarda, folha, crua', 100, 'g'),
(136, 'Nhoque, batata, cozido', 100, 'g'),
(137, 'Nabo, cru', 100, 'g'),
(138, 'Palmito, Juçara, em conserva', 100, 'g'),
(139, 'Palmito, pupunha, em conserva', 100, 'g'),
(140, 'Pão, de queijo, assado', 100, 'g'),
(141, 'Pão, de queijo, cru', 100, 'g'),
(142, 'Pepino, cru', 100, 'g'),
(143, 'Pimentão, amarelo, cru', 100, 'g'),
(144, 'Pimentão, verde, cru', 100, 'g'),
(145, 'Pimentão, vermelho, cru', 100, 'g'),
(146, 'Polvilho, doce', 100, 'g'),
(147, 'Quiabo, cru', 100, 'g'),
(148, 'Rabanete, cru', 100, 'g'),
(149, 'Repolho, branco, cru', 100, 'g'),
(150, 'Repolho, roxo, cru', 100, 'g'),
(151, 'Repolho, roxo, refogado', 100, 'g'),
(152, 'Rúcula, crua', 100, 'g'),
(153, 'Salsa, crua', 100, 'g'),
(154, 'Seleta de legumes, enlatada', 100, 'g'),
(155, 'Serralha, crua', 100, 'g'),
(156, 'Taioba, crua', 100, 'g'),
(157, 'Tomate, com semente, cru', 100, 'g'),
(158, 'Tomate, extrato', 100, 'g'),
(159, 'Tomate, molho industrializado', 100, 'g'),
(160, 'Tomate, purê', 100, 'g'),
(161, 'Tomate, salada', 100, 'g'),
(162, 'Vagem, crua', 100, 'g'),
(163, 'Abacate, cru', 100, 'g'),
(164, 'Abacaxi, cru', 100, 'g'),
(165, 'Abacaxi, polpa, congelada', 100, 'g'),
(166, 'Abiu, cru', 100, 'g'),
(167, 'Açaí, polpa, com xarope de guaraná e glucose', 100, 'g'),
(168, 'Açaí, polpa, congelada', 100, 'g'),
(169, 'Acerola, crua', 100, 'g'),
(170, 'Acerola, polpa, congelada', 100, 'g'),
(171, 'Ameixa, calda, enlatada', 100, 'g'),
(172, 'Ameixa, crua', 100, 'g'),
(173, 'Ameixa, em calda, enlatada, drenada', 100, 'g'),
(174, 'Atemóia, crua', 100, 'g'),
(175, 'Banana, da terra, crua', 100, 'g'),
(176, 'Banana, doce em barra', 100, 'g'),
(177, 'Banana, figo, crua', 100, 'g'),
(178, 'Banana, maçã, crua', 100, 'g'),
(179, 'Banana, nanica, crua', 100, 'g'),
(180, 'Banana, ouro, crua', 100, 'g'),
(181, 'Banana, pacova, crua', 100, 'g'),
(182, 'Banana, prata, crua', 100, 'g'),
(183, 'Cacau, cru', 100, 'g'),
(184, 'Cajá-Manga, cru', 100, 'g'),
(185, 'Cajá, polpa, congelada', 100, 'g'),
(186, 'Caju, cru', 100, 'g'),
(187, 'Caju, polpa, congelada', 100, 'g'),
(188, 'Caju, suco concentrado, envasado', 100, 'g'),
(189, 'Caqui, chocolate, cru', 100, 'g'),
(190, 'Carambola, crua', 100, 'g'),
(191, 'Ciriguela, crua', 100, 'g'),
(192, 'Cupuaçu, cru', 100, 'g'),
(193, 'Cupuaçu, polpa, congelada', 100, 'g'),
(194, 'Figo, cru', 100, 'g'),
(195, 'Figo, enlatado, em calda', 100, 'g'),
(196, 'Fruta-pão, crua', 100, 'g'),
(197, 'Goiaba, branca, com casca, crua', 100, 'g'),
(198, 'Goiaba, doce em pasta', 100, 'g'),
(199, 'Goiaba, doce, cascão', 100, 'g'),
(200, 'Goiaba, vermelha, com casca, crua', 100, 'g'),
(201, 'Graviola, crua', 100, 'g'),
(202, 'Graviola, polpa, congelada', 100, 'g'),
(203, 'Jabuticaba, crua', 100, 'g'),
(204, 'Jaca, crua', 100, 'g'),
(205, 'Jambo, cru', 100, 'g'),
(206, 'Jamelão, cru', 100, 'g'),
(207, 'Kiwi, cru', 100, 'g'),
(208, 'Laranja, baía, crua', 100, 'g'),
(209, 'Laranja, baía, suco', 100, 'g'),
(210, 'Laranja, da terra, crua', 100, 'g'),
(211, 'Laranja, da terra, suco', 100, 'g'),
(212, 'Laranja, lima, crua', 100, 'g'),
(213, 'Laranja, lima, suco', 100, 'g'),
(214, 'Laranja, pêra, crua', 100, 'g'),
(215, 'Laranja, pêra, suco', 100, 'g'),
(216, 'Laranja, valência, crua', 100, 'g'),
(217, 'Laranja, valência, suco', 100, 'g'),
(218, 'Limão, cravo, suco', 100, 'g'),
(219, 'Limão, galego, suco', 100, 'g'),
(220, 'Limão, tahiti, cru', 100, 'g'),
(221, 'Maçã, Argentina, com casca, crua', 100, 'g'),
(222, 'Maçã, Fuji, com casca, crua', 100, 'g'),
(223, 'Macaúba, crua', 100, 'g'),
(224, 'Mamão, doce em calda, drenado', 100, 'g'),
(225, 'Mamão, Formosa, cru', 100, 'g'),
(226, 'Mamão, Papaia, cru', 100, 'g'),
(227, 'Mamão verde, doce em calda, drenado', 100, 'g'),
(228, 'Manga, Haden, crua', 100, 'g'),
(229, 'Manga, Palmer, crua', 100, 'g'),
(230, 'Manga, polpa, congelada', 100, 'g'),
(231, 'Manga, Tommy Atkins, crua', 100, 'g'),
(232, 'Maracujá, cru', 100, 'g'),
(233, 'Maracujá, polpa, congelada', 100, 'g'),
(234, 'Maracujá, suco concentrado, envasado', 100, 'g'),
(235, 'Melancia, crua', 100, 'g'),
(236, 'Melão, cru', 100, 'g'),
(237, 'Mexerica, Murcote, crua', 100, 'g'),
(238, 'Mexerica, Rio, crua', 100, 'g'),
(239, 'Morango, cru', 100, 'g'),
(240, 'Nêspera, crua', 100, 'g'),
(241, 'Pequi, cru', 100, 'g'),
(242, 'Pêra, Park, crua', 100, 'g'),
(243, 'Pêra, Williams, crua', 100, 'g'),
(244, 'Pêssego, Aurora, cru', 100, 'g'),
(245, 'Pêssego, enlatado, em calda', 100, 'g'),
(246, 'Pinha, crua', 100, 'g'),
(247, 'Pitanga, crua', 100, 'g'),
(248, 'Pitanga, polpa, congelada', 100, 'g'),
(249, 'Romã, crua', 100, 'g'),
(250, 'Tamarindo, cru', 100, 'g'),
(251, 'Tangerina, Poncã, crua', 100, 'g'),
(252, 'Tangerina, Poncã, suco', 100, 'g'),
(253, 'Tucumã, cru', 100, 'g'),
(254, 'Umbu, cru', 100, 'g'),
(255, 'Umbu, polpa, congelada', 100, 'g'),
(256, 'Uva, Itália, crua', 100, 'g'),
(257, 'Uva, Rubi, crua', 100, 'g'),
(258, 'Uva, suco concentrado, envasado', 100, 'g'),
(259, 'Azeite, de dendê', 100, 'g'),
(260, 'Azeite, de oliva, extra virgem', 100, 'g'),
(261, 'Manteiga, com sal', 100, 'g'),
(262, 'Manteiga, sem sal', 100, 'g'),
(263, 'Margarina, com óleo hidrogenado, com sal (65% de lipídeos)', 100, 'g'),
(264, 'Margarina, com óleo hidrogenado, sem sal (80% de lipídeos)', 100, 'g'),
(265, 'Margarina, com óleo interesterificado, com sal (65%de lipídeos)', 100, 'g'),
(266, 'Margarina, com óleo interesterificado, sem sal (65% de lipídeos)', 100, 'g'),
(267, 'Óleo, de babaçu', 100, 'g'),
(268, 'Óleo, de canola', 100, 'g'),
(269, 'Óleo, de girassol', 100, 'g'),
(270, 'Óleo, de milho', 100, 'g'),
(271, 'Óleo, de pequi', 100, 'g'),
(272, 'Óleo, de soja', 100, 'g'),
(273, 'Abadejo, filé, congelado, assado', 100, 'g'),
(274, 'Abadejo, filé, congelado,cozido', 100, 'g'),
(275, 'Abadejo, filé, congelado, cru', 100, 'g'),
(276, 'Abadejo, filé, congelado, grelhado', 100, 'g'),
(277, 'Atum, conserva em óleo', 100, 'g'),
(278, 'Atum, fresco, cru', 100, 'g'),
(279, 'Bacalhau, salgado, cru', 100, 'g'),
(280, 'Bacalhau, salgado, refogado', 100, 'g'),
(281, 'Cação, posta, com farinha de trigo, frita', 100, 'g'),
(282, 'Cação, posta, cozida', 100, 'g'),
(283, 'Cação, posta, crua', 100, 'g'),
(284, 'Camarão, Rio Grande, grande, cozido', 100, 'g'),
(285, 'Camarão, Rio Grande, grande, cru', 100, 'g'),
(286, 'Camarão, Sete Barbas, sem cabeça, com casca, frito', 100, 'g'),
(287, 'Caranguejo, cozido', 100, 'g'),
(288, 'Corimba, cru', 100, 'g'),
(289, 'Corimbatá, assado', 100, 'g'),
(290, 'Corimbatá, cozido', 100, 'g'),
(291, 'Corvina de água doce, crua', 100, 'g'),
(292, 'Corvina do mar, crua', 100, 'g'),
(293, 'Corvina grande, assada', 100, 'g'),
(294, 'Corvina grande, cozida', 100, 'g'),
(295, 'Dourada de água doce, fresca', 100, 'g'),
(296, 'Lambari, congelado, cru', 100, 'g'),
(297, 'Lambari, congelado, frito', 100, 'g'),
(298, 'Lambari, fresco,cru', 100, 'g'),
(299, 'Manjuba, com farinha de trigo, frita', 100, 'g'),
(300, 'Manjuba, frita', 100, 'g'),
(301, 'Merluza, filé, assado', 100, 'g'),
(302, 'Merluza, filé, cru', 100, 'g'),
(303, 'Merluza, filé, frito', 100, 'g'),
(304, 'Pescada, branca, crua', 100, 'g'),
(305, 'Pescada, branca, frita', 100, 'g'),
(306, 'Pescada, filé, com farinha de trigo, frito', 100, 'g'),
(307, 'Pescada, filé, cru', 100, 'g'),
(308, 'Pescada, filé, frito', 100, 'g'),
(309, 'Pescada, filé, molho escabeche', 100, 'g'),
(310, 'Pescadinha, crua', 100, 'g'),
(311, 'Pintado, assado', 100, 'g'),
(312, 'Pintado, cru', 100, 'g'),
(313, 'Pintado, grelhado', 100, 'g'),
(314, 'Porquinho, cru', 100, 'g'),
(315, 'Salmão, filé, com pele, fresco,  grelhado', 100, 'g'),
(316, 'Salmão, sem pele, fresco, cru', 100, 'g'),
(317, 'Salmão, sem pele, fresco, grelhado', 100, 'g'),
(318, 'Sardinha, assada', 100, 'g'),
(319, 'Sardinha, conserva em óleo', 100, 'g'),
(320, 'Sardinha, frita', 100, 'g'),
(321, 'Sardinha, inteira, crua', 100, 'g'),
(322, 'Tucunaré, filé, congelado, cru', 100, 'g'),
(323, 'Apresuntado', 100, 'g'),
(324, 'Caldo de carne, tablete', 100, 'g'),
(325, 'Caldo de galinha, tablete', 100, 'g'),
(326, 'Carne, bovina, acém, moído, cozido', 100, 'g'),
(327, 'Carne, bovina, acém, moído, cru', 100, 'g'),
(328, 'Carne, bovina, acém, sem gordura, cozido', 100, 'g'),
(329, 'Carne, bovina, acém, sem gordura, cru', 100, 'g'),
(330, 'Carne, bovina, almôndegas, cruas', 100, 'g'),
(331, 'Carne, bovina, almôndegas, fritas', 100, 'g'),
(332, 'Carne, bovina, bucho, cozido', 100, 'g'),
(333, 'Carne, bovina, bucho, cru', 100, 'g'),
(334, 'Carne, bovina, capa de contra-filé, com gordura, crua', 100, 'g'),
(335, 'Carne, bovina, capa de contra-filé, com gordura, grelhada', 100, 'g'),
(336, 'Carne, bovina, capa de contra-filé, sem gordura, crua', 100, 'g'),
(337, 'Carne, bovina, capa de contra-filé, sem gordura, grelhada', 100, 'g'),
(338, 'Carne, bovina, charque, cozido', 100, 'g'),
(339, 'Carne, bovina, charque, cru', 100, 'g'),
(340, 'Carne, bovina, contra-filé, à milanesa', 100, 'g'),
(341, 'Carne, bovina, contra-filé de costela, cru', 100, 'g'),
(342, 'Carne, bovina, contra-filé de costela, grelhado', 100, 'g'),
(343, 'Carne, bovina, contra-filé, com gordura, cru', 100, 'g'),
(344, 'Carne, bovina, contra-filé, com gordura, grelhado', 100, 'g'),
(345, 'Carne, bovina, contra-filé, sem gordura, cru', 100, 'g'),
(346, 'Carne, bovina, contra-filé, sem gordura, grelhado', 100, 'g'),
(347, 'Carne, bovina, costela, assada', 100, 'g'),
(348, 'Carne, bovina, costela, crua', 100, 'g'),
(349, 'Carne, bovina, coxão duro, sem gordura, cozido', 100, 'g'),
(350, 'Carne, bovina, coxão duro, sem gordura, cru', 100, 'g'),
(351, 'Carne, bovina, coxão mole, sem gordura, cozido', 100, 'g'),
(352, 'Carne, bovina, coxão mole, sem gordura, cru', 100, 'g'),
(353, 'Carne, bovina, cupim, assado', 100, 'g'),
(354, 'Carne, bovina, cupim, cru', 100, 'g'),
(355, 'Carne, bovina, fígado, cru', 100, 'g'),
(356, 'Carne, bovina, fígado, grelhado', 100, 'g'),
(357, 'Carne, bovina, filé mingnon, sem gordura, cru', 100, 'g'),
(358, 'Carne, bovina, filé mingnon, sem gordura, grelhado', 100, 'g'),
(359, 'Carne, bovina, flanco, sem gordura, cozido', 100, 'g'),
(360, 'Carne, bovina, flanco, sem gordura, cru', 100, 'g'),
(361, 'Carne, bovina, fraldinha, com gordura, cozida', 100, 'g'),
(362, 'Carne, bovina, fraldinha, com gordura, crua', 100, 'g'),
(363, 'Carne, bovina, lagarto, cozido', 100, 'g'),
(364, 'Carne, bovina, lagarto, cru', 100, 'g'),
(365, 'Carne, bovina, língua, cozida', 100, 'g'),
(366, 'Carne, bovina, língua, crua', 100, 'g'),
(367, 'Carne, bovina, maminha, crua', 100, 'g'),
(368, 'Carne, bovina, maminha, grelhada', 100, 'g'),
(369, 'Carne, bovina, miolo de alcatra, sem gordura, cru', 100, 'g'),
(370, 'Carne, bovina, miolo de alcatra, sem gordura, grelhado', 100, 'g'),
(371, 'Carne, bovina, músculo, sem gordura, cozido', 100, 'g'),
(372, 'Carne, bovina, músculo, sem gordura, cru', 100, 'g'),
(373, 'Carne, bovina, paleta, com gordura, crua', 100, 'g'),
(374, 'Carne, bovina, paleta, sem gordura, cozida', 100, 'g'),
(375, 'Carne, bovina, paleta, sem gordura, crua', 100, 'g'),
(376, 'Carne, bovina, patinho, sem gordura, cru', 100, 'g'),
(377, 'Carne, bovina, patinho, sem gordura, grelhado', 100, 'g'),
(378, 'Carne, bovina, peito, sem gordura, cozido', 100, 'g'),
(379, 'Carne, bovina, peito, sem gordura, cru', 100, 'g'),
(380, 'Carne, bovina, picanha, com gordura, crua', 100, 'g'),
(381, 'Carne, bovina, picanha, com gordura, grelhada', 100, 'g'),
(382, 'Carne, bovina, picanha, sem gordura, crua', 100, 'g'),
(383, 'Carne, bovina, picanha, sem gordura, grelhada', 100, 'g'),
(384, 'Carne, bovina, seca, cozida', 100, 'g'),
(385, 'Carne, bovina, seca, crua', 100, 'g'),
(386, 'Coxinha de frango, frita', 100, 'g'),
(387, 'Croquete, de carne, cru', 100, 'g'),
(388, 'Croquete, de carne, frito', 100, 'g'),
(389, 'Empada de frango, pré-cozida, assada', 100, 'g'),
(390, 'Empada, de frango, pré-cozida', 100, 'g'),
(391, 'Frango, asa, com pele, crua', 100, 'g'),
(392, 'Frango, caipira, inteiro, com pele, cozido', 100, 'g'),
(393, 'Frango, caipira, inteiro, sem pele, cozido', 100, 'g'),
(394, 'Frango, coração, cru', 100, 'g'),
(395, 'Frango, coração, grelhado', 100, 'g'),
(396, 'Frango, coxa, com pele, assada', 100, 'g'),
(397, 'Frango, coxa, com pele, crua', 100, 'g'),
(398, 'Frango, coxa, sem pele, cozida', 100, 'g'),
(399, 'Frango, coxa, sem pele, crua', 100, 'g'),
(400, 'Frango, fígado, cru', 100, 'g'),
(401, 'Frango, filé, à milanesa', 100, 'g'),
(402, 'Frango, inteiro, com pele, cru', 100, 'g'),
(403, 'Frango, inteiro, sem pele, assado', 100, 'g'),
(404, 'Frango, inteiro, sem pele, cozido', 100, 'g'),
(405, 'Frango, inteiro, sem pele, cru', 100, 'g'),
(406, 'Frango, peito, com pele, assado', 100, 'g'),
(407, 'Frango, peito, com pele, cru', 100, 'g'),
(408, 'Frango, peito, sem pele, cozido', 100, 'g'),
(409, 'Frango, peito, sem pele, cru', 100, 'g'),
(410, 'Frango, peito, sem pele, grelhado', 100, 'g'),
(411, 'Frango, sobrecoxa, com pele, assada', 100, 'g'),
(412, 'Frango, sobrecoxa, com pele, crua', 100, 'g'),
(413, 'Frango, sobrecoxa, sem pele, assada', 100, 'g'),
(414, 'Frango, sobrecoxa, sem pele, crua', 100, 'g'),
(415, 'Hambúrguer, bovino, cru', 100, 'g'),
(416, 'Hambúrguer, bovino, frito', 100, 'g'),
(417, 'Hambúrguer, bovino, grelhado', 100, 'g'),
(418, 'Lingüiça, frango, crua', 100, 'g'),
(419, 'Lingüiça, frango, frita', 100, 'g'),
(420, 'Lingüiça, frango, grelhada', 100, 'g'),
(421, 'Lingüiça, porco, crua', 100, 'g'),
(422, 'Lingüiça, porco, frita', 100, 'g'),
(423, 'Lingüiça, porco, grelhada', 100, 'g'),
(424, 'Mortadela', 100, 'g'),
(425, 'Peru, congelado, assado', 100, 'g'),
(426, 'Peru, congelado, cru', 100, 'g'),
(427, 'Porco, bisteca, crua', 100, 'g'),
(428, 'Porco, bisteca, frita', 100, 'g'),
(429, 'Porco, bisteca, grelhada', 100, 'g'),
(430, 'Porco, costela, assada', 100, 'g'),
(431, 'Porco, costela, crua', 100, 'g'),
(432, 'Porco, lombo, assado', 100, 'g'),
(433, 'Porco, lombo, cru', 100, 'g'),
(434, 'Porco, orelha, salgada, crua', 100, 'g'),
(435, 'Porco, pernil, assado', 100, 'g'),
(436, 'Porco, pernil, cru', 100, 'g'),
(437, 'Porco, rabo, salgado, cru', 100, 'g'),
(438, 'Presunto, com capa de gordura', 100, 'g'),
(439, 'Presunto, sem capa de gordura', 100, 'g'),
(440, 'Quibe, assado', 100, 'g'),
(441, 'Quibe, cru', 100, 'g'),
(442, 'Quibe, frito', 100, 'g'),
(443, 'Salame', 100, 'g'),
(444, 'Toucinho, cru', 100, 'g'),
(445, 'Toucinho, frito', 100, 'g'),
(446, 'Bebida láctea, pêssego', 100, 'g'),
(447, 'Creme de Leite', 100, 'g'),
(448, 'Iogurte, natural', 100, 'g'),
(449, 'Iogurte, natural, desnatado', 100, 'g'),
(450, 'Iogurte, sabor abacaxi', 100, 'g'),
(451, 'Iogurte, sabor morango', 100, 'g'),
(452, 'Iogurte, sabor pêssego', 100, 'g'),
(453, 'Leite, condensado', 100, 'g'),
(454, 'Leite, de cabra', 100, 'g'),
(455, 'Leite, de vaca, achocolatado', 100, 'g'),
(456, 'Leite, de vaca, desnatado, pó', 100, 'g'),
(457, 'Leite, de vaca, desnatado, UHT', 100, 'g'),
(458, 'Leite, de vaca, integral', 100, 'g'),
(459, 'Leite, de vaca, integral, pó', 100, 'g'),
(460, 'Leite, fermentado', 100, 'g'),
(461, 'Queijo, minas, frescal', 100, 'g'),
(462, 'Queijo, minas, meia cura', 100, 'g'),
(463, 'Queijo, mozarela', 100, 'g'),
(464, 'Queijo, parmesão', 100, 'g'),
(465, 'Queijo, pasteurizado', 100, 'g'),
(466, 'Queijo, petit suisse, morango', 100, 'g'),
(467, 'Queijo, prato', 100, 'g'),
(468, 'Maria mole', 100, 'g'),
(469, 'Queijo, ricota', 100, 'g'),
(470, 'Bebida isotônica, sabores variados', 100, 'g'),
(471, 'Café, infusão 10%', 100, 'g'),
(472, 'Cana, aguardente 1', 100, 'g'),
(473, 'Cana, caldo de', 100, 'g'),
(474, 'Cerveja, pilsen 2', 100, 'g'),
(475, 'Chá, erva-doce, infusão 5%', 100, 'g'),
(476, 'Chá, mate, infusão 5%', 100, 'g'),
(477, 'Chá, preto, infusão 5%', 100, 'g'),
(478, 'Coco, água de', 100, 'g'),
(479, 'Refrigerante, tipo água tônica', 100, 'g'),
(480, 'Refrigerante, tipo cola', 100, 'g'),
(481, 'Refrigerante, tipo guaraná', 100, 'g'),
(482, 'Refrigerante, tipo laranja', 100, 'g'),
(483, 'Refrigerante, tipo limão', 100, 'g'),
(484, 'Omelete, de queijo', 100, 'g'),
(485, 'Ovo, de codorna, inteiro, cru', 100, 'g'),
(486, 'Ovo, de galinha, clara, cozida/10minutos', 100, 'g'),
(487, 'Ovo, de galinha, gema, cozida/10minutos', 100, 'g'),
(488, 'Ovo, de galinha, inteiro, cozido/10minutos', 100, 'g'),
(489, 'Ovo, de galinha, inteiro, cru', 100, 'g'),
(490, 'Ovo, de galinha, inteiro, frito', 100, 'g'),
(491, 'Achocolatado, pó', 100, 'g'),
(492, 'Açúcar, cristal', 100, 'g'),
(493, 'Açúcar, mascavo', 100, 'g'),
(494, 'Açúcar, refinado', 100, 'g'),
(495, 'Chocolate, ao leite', 100, 'g'),
(496, 'Chocolate, ao leite, com castanha do Pará', 100, 'g'),
(497, 'Chocolate, ao leite, dietético', 100, 'g'),
(498, 'Chocolate, meio amargo', 100, 'g'),
(499, 'Cocada branca', 100, 'g'),
(500, 'Doce, de abóbora, cremoso', 100, 'g'),
(501, 'Doce, de leite, cremoso', 100, 'g'),
(502, 'Geléia, mocotó, natural', 100, 'g'),
(503, 'Glicose de milho', 100, 'g'),
(504, 'Maria mole', 100, 'g'),
(505, 'Maria mole, coco queimado', 100, 'g'),
(506, 'Marmelada', 100, 'g'),
(507, 'Mel, de abelha', 100, 'g'),
(508, 'Melado', 100, 'g'),
(509, 'Quindim', 100, 'g'),
(510, 'Rapadura', 100, 'g'),
(511, 'Café, pó, torrado', 100, 'g'),
(512, 'Capuccino, pó', 100, 'g'),
(513, 'Fermento em pó, químico', 100, 'g'),
(514, 'Fermento, biológico, levedura, tablete', 100, 'g'),
(515, 'Gelatina, sabores variados, pó', 100, 'g'),
(516, 'Sal, dietético', 100, 'g'),
(517, 'Sal, grosso', 100, 'g'),
(518, 'Shoyu', 100, 'g'),
(519, 'Tempero a base de sal', 100, 'g'),
(520, 'Azeitona, preta, conserva', 100, 'g'),
(521, 'Azeitona, verde, conserva', 100, 'g'),
(522, 'Chantilly, spray, com gordura vegetal', 100, 'g'),
(523, 'Leite, de coco', 100, 'g'),
(524, 'Maionese, tradicional com ovos', 100, 'g'),
(525, 'Acarajé', 100, 'g'),
(526, 'Arroz carreteiro', 100, 'g'),
(527, 'Baião de dois, arroz e feijão-de-corda', 100, 'g'),
(528, 'Barreado', 100, 'g'),
(529, 'Bife à cavalo, com contra filé', 100, 'g'),
(530, 'Bolinho de arroz', 100, 'g'),
(531, 'Camarão à baiana', 100, 'g'),
(532, 'Charuto, de repolho', 100, 'g'),
(533, 'Cuscuz, de milho, cozido com sal', 100, 'g'),
(534, 'Cuscuz, paulista', 100, 'g'),
(535, 'Cuxá, molho', 100, 'g'),
(536, 'Dobradinha', 100, 'g'),
(537, 'Estrogonofe de carne', 100, 'g'),
(538, 'Estrogonofe de frango', 100, 'g'),
(539, 'Feijão tropeiro mineiro', 100, 'g'),
(540, 'Feijoada', 100, 'g'),
(541, 'Frango, com açafrão', 100, 'g'),
(542, 'Macarrão, molho bolognesa', 100, 'g'),
(543, 'Maniçoba', 100, 'g'),
(544, 'Quibebe', 100, 'g'),
(545, 'Salada, de legumes, com maionese', 100, 'g'),
(546, 'Salada, de legumes, cozida no vapor', 100, 'g'),
(547, 'Salpicão, de frango', 100, 'g'),
(548, 'Sarapatel', 100, 'g'),
(549, 'Tabule', 100, 'g'),
(550, 'Tacacá', 100, 'g'),
(551, 'Tapioca, com manteiga', 100, 'g'),
(552, 'Tucupi, com pimenta-de-cheiro', 100, 'g'),
(553, 'Vaca atolada', 100, 'g'),
(554, 'Vatapá', 100, 'g'),
(555, 'Virado à paulista', 100, 'g'),
(556, 'Yakisoba', 100, 'g'),
(557, 'Amendoim, grão, cru', 100, 'g'),
(558, 'Amendoim, torrado, salgado', 100, 'g'),
(559, 'Ervilha, em vagem', 100, 'g'),
(560, 'Ervilha, enlatada, drenada', 100, 'g'),
(561, 'Feijão, carioca, cozido', 100, 'g'),
(562, 'Feijão, carioca, cru', 100, 'g'),
(563, 'Feijão, fradinho, cozido', 100, 'g'),
(564, 'Feijão, fradinho, cru', 100, 'g'),
(565, 'Feijão, jalo, cozido', 100, 'g'),
(566, 'Feijão, jalo, cru', 100, 'g'),
(567, 'Feijão, preto, cozido', 100, 'g'),
(568, 'Feijão, preto, cru', 100, 'g'),
(569, 'Feijão, rajado, cozido', 100, 'g'),
(570, 'Feijão, rajado, cru', 100, 'g'),
(571, 'Feijão, rosinha, cozido', 100, 'g'),
(572, 'Feijão, rosinha, cru', 100, 'g'),
(573, 'Feijão, roxo, cozido', 100, 'g'),
(574, 'Feijão, roxo, cru', 100, 'g'),
(575, 'Grão-de-bico, cru', 100, 'g'),
(576, 'Guandu, cru', 100, 'g'),
(577, 'Lentilha, cozida', 100, 'g'),
(578, 'Lentilha, crua', 100, 'g'),
(579, 'Paçoca, amendoim', 100, 'g'),
(580, 'Pé-de-moleque, amendoim', 100, 'g'),
(581, 'Soja, farinha', 100, 'g'),
(582, 'Soja, extrato solúvel, natural, fluido', 100, 'g'),
(583, 'Soja, extrato solúvel, pó', 100, 'g'),
(584, 'Soja, queijo (tofu)', 100, 'g'),
(585, 'Tremoço, cru', 100, 'g'),
(586, 'Tremoço, em conserva', 100, 'g'),
(587, 'Amêndoa, torrada, salgada', 100, 'g'),
(588, 'Castanha-de-caju, torrada, salgada', 100, 'g'),
(589, 'Castanha-do-Brasil, crua', 100, 'g'),
(590, 'Coco, cru', 100, 'g'),
(591, 'Coco, verde, cru', 100, 'g'),
(592, 'Farinha, de mesocarpo de babaçu, crua', 100, 'g'),
(593, 'Gergelim, semente', 100, 'g'),
(594, 'Linhaça, semente', 100, 'g'),
(595, 'Pinhão, cozido', 100, 'g'),
(596, 'Pupunha, cozida', 100, 'g'),
(597, 'Noz, crua', 100, 'g');

-- --------------------------------------------------------

--
-- Estrutura da tabela `ingrediente_categorias`
--

DROP TABLE IF EXISTS `ingrediente_categorias`;
CREATE TABLE `ingrediente_categorias` (
  `ingrediente_categorias_id` int(11) NOT NULL,
  `ingredientes_id` int(11) NOT NULL,
  `categoria_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Extraindo dados da tabela `ingrediente_categorias`
--

INSERT INTO `ingrediente_categorias` (`ingrediente_categorias_id`, `ingredientes_id`, `categoria_id`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1),
(6, 6, 1),
(7, 7, 1),
(8, 8, 1),
(9, 9, 1),
(10, 10, 1),
(11, 11, 1),
(12, 12, 1),
(13, 13, 1),
(14, 14, 1),
(15, 15, 1),
(16, 16, 1),
(17, 17, 1),
(18, 18, 1),
(19, 19, 1),
(20, 20, 1),
(21, 21, 1),
(22, 22, 1),
(23, 23, 1),
(24, 24, 1),
(25, 25, 1),
(26, 26, 1),
(27, 27, 1),
(28, 28, 1),
(29, 29, 1),
(30, 30, 1),
(31, 31, 1),
(32, 32, 1),
(33, 33, 1),
(34, 34, 1),
(35, 35, 1),
(36, 36, 1),
(37, 37, 1),
(38, 38, 1),
(39, 39, 1),
(40, 40, 1),
(41, 41, 1),
(42, 42, 1),
(43, 43, 1),
(44, 44, 1),
(45, 45, 1),
(46, 46, 1),
(47, 47, 1),
(48, 48, 1),
(49, 49, 1),
(50, 50, 1),
(51, 51, 1),
(52, 52, 1),
(53, 53, 1),
(54, 54, 1),
(55, 55, 1),
(56, 56, 1),
(57, 57, 1),
(58, 58, 1),
(59, 59, 1),
(60, 60, 1),
(61, 61, 1),
(62, 62, 1),
(63, 63, 1),
(64, 64, 2),
(65, 65, 2),
(66, 66, 2),
(67, 67, 2),
(68, 68, 2),
(69, 69, 2),
(70, 70, 2),
(71, 71, 2),
(72, 72, 2),
(73, 73, 2),
(74, 74, 2),
(75, 75, 2),
(76, 76, 2),
(77, 77, 2),
(78, 78, 2),
(79, 79, 2),
(80, 80, 2),
(81, 81, 2),
(82, 82, 2),
(83, 83, 2),
(84, 84, 2),
(85, 85, 2),
(86, 86, 2),
(87, 87, 2),
(88, 88, 2),
(89, 89, 2),
(90, 90, 2),
(91, 91, 2),
(92, 92, 2),
(93, 93, 2),
(94, 94, 2),
(95, 95, 2),
(96, 96, 2),
(97, 97, 2),
(98, 98, 2),
(99, 99, 2),
(100, 100, 2),
(101, 101, 2),
(102, 102, 2),
(103, 103, 2),
(104, 104, 2),
(105, 105, 2),
(106, 106, 2),
(107, 107, 2),
(108, 108, 2),
(109, 109, 2),
(110, 110, 2),
(111, 111, 2),
(112, 112, 2),
(113, 113, 2),
(114, 114, 2),
(115, 115, 2),
(116, 116, 2),
(117, 117, 2),
(118, 118, 2),
(119, 119, 2),
(120, 120, 2),
(121, 121, 2),
(122, 122, 2),
(123, 123, 2),
(124, 124, 2),
(125, 125, 2),
(126, 126, 2),
(127, 127, 2),
(128, 128, 2),
(129, 129, 2),
(130, 130, 2),
(131, 131, 2),
(132, 132, 2),
(133, 133, 2),
(134, 134, 2),
(135, 135, 2),
(136, 136, 2),
(137, 137, 2),
(138, 138, 2),
(139, 139, 2),
(140, 140, 2),
(141, 141, 2),
(142, 142, 2),
(143, 143, 2),
(144, 144, 2),
(145, 145, 2),
(146, 146, 2),
(147, 147, 2),
(148, 148, 2),
(149, 149, 2),
(150, 150, 2),
(151, 151, 2),
(152, 152, 2),
(153, 153, 2),
(154, 154, 2),
(155, 155, 2),
(156, 156, 2),
(157, 157, 2),
(158, 158, 2),
(159, 159, 2),
(160, 160, 2),
(161, 161, 2),
(162, 162, 2),
(163, 163, 3),
(164, 164, 3),
(165, 165, 3),
(166, 166, 3),
(167, 167, 3),
(168, 168, 3),
(169, 169, 3),
(170, 170, 3),
(171, 171, 3),
(172, 172, 3),
(173, 173, 3),
(174, 174, 3),
(175, 175, 3),
(176, 176, 3),
(177, 177, 3),
(178, 178, 3),
(179, 179, 3),
(180, 180, 3),
(181, 181, 3),
(182, 182, 3),
(183, 183, 3),
(184, 184, 3),
(185, 185, 3),
(186, 186, 3),
(187, 187, 3),
(188, 188, 3),
(189, 189, 3),
(190, 190, 3),
(191, 191, 3),
(192, 192, 3),
(193, 193, 3),
(194, 194, 3),
(195, 195, 3),
(196, 196, 3),
(197, 197, 3),
(198, 198, 3),
(199, 199, 3),
(200, 200, 3),
(201, 201, 3),
(202, 202, 3),
(203, 203, 3),
(204, 204, 3),
(205, 205, 3),
(206, 206, 3),
(207, 207, 3),
(208, 208, 3),
(209, 209, 3),
(210, 210, 3),
(211, 211, 3),
(212, 212, 3),
(213, 213, 3),
(214, 214, 3),
(215, 215, 3),
(216, 216, 3),
(217, 217, 3),
(218, 218, 3),
(219, 219, 3),
(220, 220, 3),
(221, 221, 3),
(222, 222, 3),
(223, 223, 3),
(224, 224, 3),
(225, 225, 3),
(226, 226, 3),
(227, 227, 3),
(228, 228, 3),
(229, 229, 3),
(230, 230, 3),
(231, 231, 3),
(232, 232, 3),
(233, 233, 3),
(234, 234, 3),
(235, 235, 3),
(236, 236, 3),
(237, 237, 3),
(238, 238, 3),
(239, 239, 3),
(240, 240, 3),
(241, 241, 3),
(242, 242, 3),
(243, 243, 3),
(244, 244, 3),
(245, 245, 3),
(246, 246, 3),
(247, 247, 3),
(248, 248, 3),
(249, 249, 3),
(250, 250, 3),
(251, 251, 3),
(252, 252, 3),
(253, 253, 3),
(254, 254, 3),
(255, 255, 3),
(256, 256, 3),
(257, 257, 3),
(258, 258, 3),
(259, 259, 4),
(260, 260, 4),
(261, 261, 4),
(262, 262, 4),
(263, 263, 4),
(264, 264, 4),
(265, 265, 4),
(266, 266, 4),
(267, 267, 4),
(268, 268, 4),
(269, 269, 4),
(270, 270, 4),
(271, 271, 4),
(272, 272, 4),
(273, 273, 5),
(274, 274, 5),
(275, 275, 5),
(276, 276, 5),
(277, 277, 5),
(278, 278, 5),
(279, 279, 5),
(280, 280, 5),
(281, 281, 5),
(282, 282, 5),
(283, 283, 5),
(284, 284, 5),
(285, 285, 5),
(286, 286, 5),
(287, 287, 5),
(288, 288, 5),
(289, 289, 5),
(290, 290, 5),
(291, 291, 5),
(292, 292, 5),
(293, 293, 5),
(294, 294, 5),
(295, 295, 5),
(296, 296, 5),
(297, 297, 5),
(298, 298, 5),
(299, 299, 5),
(300, 300, 5),
(301, 301, 5),
(302, 302, 5),
(303, 303, 5),
(304, 304, 5),
(305, 305, 5),
(306, 306, 5),
(307, 307, 5),
(308, 308, 5),
(309, 309, 5),
(310, 310, 5),
(311, 311, 5),
(312, 312, 5),
(313, 313, 5),
(314, 314, 5),
(315, 315, 5),
(316, 316, 5),
(317, 317, 5),
(318, 318, 5),
(319, 319, 5),
(320, 320, 5),
(321, 321, 5),
(322, 322, 5),
(323, 323, 6),
(324, 324, 6),
(325, 325, 6),
(326, 326, 6),
(327, 327, 6),
(328, 328, 6),
(329, 329, 6),
(330, 330, 6),
(331, 331, 6),
(332, 332, 6),
(333, 333, 6),
(334, 334, 6),
(335, 335, 6),
(336, 336, 6),
(337, 337, 6),
(338, 338, 6),
(339, 339, 6),
(340, 340, 6),
(341, 341, 6),
(342, 342, 6),
(343, 343, 6),
(344, 344, 6),
(345, 345, 6),
(346, 346, 6),
(347, 347, 6),
(348, 348, 6),
(349, 349, 6),
(350, 350, 6),
(351, 351, 6),
(352, 352, 6),
(353, 353, 6),
(354, 354, 6),
(355, 355, 6),
(356, 356, 6),
(357, 357, 6),
(358, 358, 6),
(359, 359, 6),
(360, 360, 6),
(361, 361, 6),
(362, 362, 6),
(363, 363, 6),
(364, 364, 6),
(365, 365, 6),
(366, 366, 6),
(367, 367, 6),
(368, 368, 6),
(369, 369, 6),
(370, 370, 6),
(371, 371, 6),
(372, 372, 6),
(373, 373, 6),
(374, 374, 6),
(375, 375, 6),
(376, 376, 6),
(377, 377, 6),
(378, 378, 6),
(379, 379, 6),
(380, 380, 6),
(381, 381, 6),
(382, 382, 6),
(383, 383, 6),
(384, 384, 6),
(385, 385, 6),
(386, 386, 6),
(387, 387, 6),
(388, 388, 6),
(389, 389, 6),
(390, 390, 6),
(391, 391, 6),
(392, 392, 6),
(393, 393, 6),
(394, 394, 6),
(395, 395, 6),
(396, 396, 6),
(397, 397, 6),
(398, 398, 6),
(399, 399, 6),
(400, 400, 6),
(401, 401, 6),
(402, 402, 6),
(403, 403, 6),
(404, 404, 6),
(405, 405, 6),
(406, 406, 6),
(407, 407, 6),
(408, 408, 6),
(409, 409, 6),
(410, 410, 6),
(411, 411, 6),
(412, 412, 6),
(413, 413, 6),
(414, 414, 6),
(415, 415, 6),
(416, 416, 6),
(417, 417, 6),
(418, 418, 6),
(419, 419, 6),
(420, 420, 6),
(421, 421, 6),
(422, 422, 6),
(423, 423, 6),
(424, 424, 6),
(425, 425, 6),
(426, 426, 6),
(427, 427, 6),
(428, 428, 6),
(429, 429, 6),
(430, 430, 6),
(431, 431, 6),
(432, 432, 6),
(433, 433, 6),
(434, 434, 6),
(435, 435, 6),
(436, 436, 6),
(437, 437, 6),
(438, 438, 6),
(439, 439, 6),
(440, 440, 6),
(441, 441, 6),
(442, 442, 6),
(443, 443, 6),
(444, 444, 6),
(445, 445, 6),
(446, 446, 7),
(447, 447, 7),
(448, 448, 7),
(449, 449, 7),
(450, 450, 7),
(451, 451, 7),
(452, 452, 7),
(453, 453, 7),
(454, 454, 7),
(455, 455, 7),
(456, 456, 7),
(457, 457, 7),
(458, 458, 7),
(459, 459, 7),
(460, 460, 7),
(461, 461, 7),
(462, 462, 7),
(463, 463, 7),
(464, 464, 7),
(465, 465, 7),
(466, 466, 7),
(467, 467, 7),
(468, 468, 7),
(469, 469, 7),
(470, 470, 8),
(471, 471, 8),
(472, 472, 8),
(473, 473, 8),
(474, 474, 8),
(475, 475, 8),
(476, 476, 8),
(477, 477, 8),
(478, 478, 8),
(479, 479, 8),
(480, 480, 8),
(481, 481, 8),
(482, 482, 8),
(483, 483, 8),
(484, 484, 9),
(485, 485, 9),
(486, 486, 9),
(487, 487, 9),
(488, 488, 9),
(489, 489, 9),
(490, 490, 9),
(491, 491, 10),
(492, 492, 10),
(493, 493, 10),
(494, 494, 10),
(495, 495, 10),
(496, 496, 10),
(497, 497, 10),
(498, 498, 10),
(499, 499, 10),
(500, 500, 10),
(501, 501, 10),
(502, 502, 10),
(503, 503, 10),
(504, 504, 10),
(505, 505, 10),
(506, 506, 10),
(507, 507, 10),
(508, 508, 10),
(509, 509, 10),
(510, 510, 10),
(511, 511, 11),
(512, 512, 11),
(513, 513, 11),
(514, 514, 11),
(515, 515, 11),
(516, 516, 11),
(517, 517, 11),
(518, 518, 11),
(519, 519, 11),
(520, 520, 12),
(521, 521, 12),
(522, 522, 12),
(523, 523, 12),
(524, 524, 12),
(525, 525, 13),
(526, 526, 13),
(527, 527, 13),
(528, 528, 13),
(529, 529, 13),
(530, 530, 13),
(531, 531, 13),
(532, 532, 13),
(533, 533, 13),
(534, 534, 13),
(535, 535, 13),
(536, 536, 13),
(537, 537, 13),
(538, 538, 13),
(539, 539, 13),
(540, 540, 13),
(541, 541, 13),
(542, 542, 13),
(543, 543, 13),
(544, 544, 13),
(545, 545, 13),
(546, 546, 13),
(547, 547, 13),
(548, 548, 13),
(549, 549, 13),
(550, 550, 13),
(551, 551, 13),
(552, 552, 13),
(553, 553, 13),
(554, 554, 13),
(555, 555, 13),
(556, 556, 13),
(557, 557, 14),
(558, 558, 14),
(559, 559, 14),
(560, 560, 14),
(561, 561, 14),
(562, 562, 14),
(563, 563, 14),
(564, 564, 14),
(565, 565, 14),
(566, 566, 14),
(567, 567, 14),
(568, 568, 14),
(569, 569, 14),
(570, 570, 14),
(571, 571, 14),
(572, 572, 14),
(573, 573, 14),
(574, 574, 14),
(575, 575, 14),
(576, 576, 14),
(577, 577, 14),
(578, 578, 14),
(579, 579, 14),
(580, 580, 14),
(581, 581, 14),
(582, 582, 14),
(583, 583, 14),
(584, 584, 14),
(585, 585, 14),
(586, 586, 14),
(587, 587, 15),
(588, 588, 15),
(589, 589, 15),
(590, 590, 15),
(591, 591, 15),
(592, 592, 15),
(593, 593, 15),
(594, 594, 15),
(595, 595, 15),
(596, 596, 15),
(597, 597, 15);

-- --------------------------------------------------------

--
-- Estrutura da tabela `ingrediente_val_nutricional`
--

DROP TABLE IF EXISTS `ingrediente_val_nutricional`;
CREATE TABLE `ingrediente_val_nutricional` (
  `ingrediente_val_nutricional_id` int(11) NOT NULL,
  `ingrediente_id` int(11) NOT NULL,
  `humidity_qtd` float DEFAULT NULL,
  `humidity_unit` varchar(45) COLLATE utf8_bin DEFAULT NULL,
  `protein_qtd` float DEFAULT NULL,
  `protein_unit` varchar(45) COLLATE utf8_bin DEFAULT NULL,
  `lipid_qtd` float DEFAULT NULL,
  `lipid_unit` varchar(45) COLLATE utf8_bin DEFAULT NULL,
  `carbohydrate_qtd` float DEFAULT NULL,
  `carbohydrate_unit` varchar(45) COLLATE utf8_bin DEFAULT NULL,
  `fiber_qtd` float DEFAULT NULL,
  `fiber_unit` varchar(45) COLLATE utf8_bin DEFAULT NULL,
  `energy_kcal` float DEFAULT NULL,
  `energy_kj` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Extraindo dados da tabela `ingrediente_val_nutricional`
--

INSERT INTO `ingrediente_val_nutricional` (`ingrediente_val_nutricional_id`, `ingrediente_id`, `humidity_qtd`, `humidity_unit`, `protein_qtd`, `protein_unit`, `lipid_qtd`, `lipid_unit`, `carbohydrate_qtd`, `carbohydrate_unit`, `fiber_qtd`, `fiber_unit`, `energy_kcal`, `energy_kj`) VALUES
(1, 1, 70.139, 'percents', 2.588, 'g', 1, 'g', 25.81, 'g', 2.749, 'g', 123.535, 516.87),
(2, 2, 12.18, 'percents', 7.323, 'g', 1.865, 'g', 77.451, 'g', 4.819, 'g', 359.678, 1504.89),
(3, 3, 69.114, 'percents', 2.521, 'g', 0.227, 'g', 28.06, 'g', 1.561, 'g', 128.258, 536.634),
(4, 4, 13.225, 'percents', 7.159, 'g', 0.335, 'g', 78.76, 'g', 1.639, 'g', 357.789, 1496.99),
(5, 5, 68.728, 'percents', 2.568, 'g', 0.362, 'g', 28.193, 'g', 1.07, 'g', 130.12, 544.421),
(6, 6, 13.165, 'percents', 7.242, 'g', 0.276, 'g', 78.881, 'g', 1.72, 'g', 358.117, 1498.36),
(7, 7, 9.133, 'percents', 13.921, 'g', 8.497, 'g', 66.636, 'g', 9.13, 'g', 393.823, 1647.75),
(8, 8, 3.217, 'percents', 8.073, 'g', 11.967, 'g', 75.234, 'g', 2.1, 'g', 442.819, 1852.76),
(9, 9, 2.183, 'percents', 6.397, 'g', 19.583, 'g', 70.549, 'g', 2.957, 'g', 471.825, 1974.11),
(10, 10, 2.733, 'percents', 5.72, 'g', 19.573, 'g', 71.014, 'g', 1.533, 'g', 471.175, 1971.4),
(11, 11, 1.17, 'percents', 5.565, 'g', 24.673, 'g', 67.535, 'g', 1.803, 'g', 502.457, 2102.28),
(12, 12, 1.173, 'percents', 4.517, 'g', 26.4, 'g', 67.353, 'g', 0.82, 'g', 513.446, 2148.26),
(13, 13, 4.057, 'percents', 10.055, 'g', 14.437, 'g', 68.732, 'g', 2.51, 'g', 431.732, 1806.37),
(14, 14, 1, 'percents', 6.159, 'g', 6.127, 'g', 84.714, 'g', 1.703, 'g', 418.633, 1751.56),
(15, 15, 34.134, 'percents', 4.417, 'g', 12.748, 'g', 47.864, 'g', 0.691, 'g', 323.852, 1354.99),
(16, 16, 19.276, 'percents', 6.223, 'g', 18.472, 'g', 54.718, 'g', 1.43, 'g', 410.014, 1715.5),
(17, 17, 29.32, 'percents', 5.667, 'g', 11.296, 'g', 52.276, 'g', 1.055, 'g', 333.438, 1395.1),
(18, 18, 36.688, 'percents', 4.804, 'g', 12.415, 'g', 45.109, 'g', 0.71, 'g', 311.387, 1302.84),
(19, 19, 13.557, 'percents', 7.2, 'g', 0.971, 'g', 78.061, 'g', 5.499, 'g', 357.603, 1496.21),
(20, 20, 72.494, 'percents', 2.361, 'g', 1.244, 'g', 23.628, 'g', 1.217, 'g', 112.457, 470.519),
(21, 21, 9.293, 'percents', 7.292, 'g', 1.603, 'g', 80.835, 'g', 5.293, 'g', 369.6, 1546.41),
(22, 22, 11.223, 'percents', 6.875, 'g', 1.183, 'g', 80.448, 'g', 1.837, 'g', 363.338, 1520.21),
(23, 23, 4.703, 'percents', 6.431, 'g', 1.093, 'g', 87.266, 'g', 3.213, 'g', 394.428, 1650.29),
(24, 24, 4.367, 'percents', 8.896, 'g', 2.12, 'g', 81.618, 'g', 4.983, 'g', 381.133, 1594.66),
(25, 25, 5.527, 'percents', 7.156, 'g', 0.957, 'g', 83.824, 'g', 4.117, 'g', 365.354, 1528.64),
(26, 26, 4.267, 'percents', 4.743, 'g', 0.667, 'g', 88.841, 'g', 2.107, 'g', 376.555, 1575.51),
(27, 27, 7.333, 'percents', 7.027, 'g', 1.226, 'g', 83.869, 'g', 1.071, 'g', 386.001, 1615.03),
(28, 28, 5.652, 'percents', 4.821, 'g', 1.639, 'g', 86.149, 'g', 3.722, 'g', 333.034, 1393.42),
(29, 29, 81.565, 'percents', 2.361, 'g', 1.637, 'g', 13.944, 'g', 0.457, 'g', 78.434, 328.167),
(30, 30, 3.916, 'percents', 2.223, 'g', 13.371, 'g', 79.816, 'g', 2.523, 'g', 402.287, 1683.17),
(31, 31, 12.693, 'percents', 1.269, 'g', 0.3, 'g', 85.504, 'g', 0.58, 'g', 363.056, 1519.03),
(32, 32, 10.777, 'percents', 12.515, 'g', 1.753, 'g', 73.298, 'g', 15.48, 'g', 335.778, 1404.89),
(33, 33, 11.773, 'percents', 7.188, 'g', 1.467, 'g', 79.079, 'g', 5.49, 'g', 350.587, 1466.86),
(34, 34, 9.807, 'percents', 11.381, 'g', 1.463, 'g', 75.786, 'g', 4.823, 'g', 370.578, 1550.5),
(35, 35, 12.98, 'percents', 9.791, 'g', 1.367, 'g', 75.093, 'g', 2.347, 'g', 360.473, 1508.22),
(36, 36, 2.697, 'percents', 11.879, 'g', 5.79, 'g', 77.771, 'g', 1.94, 'g', 414.851, 1735.73),
(37, 37, 59.646, 'percents', 5.813, 'g', 1.158, 'g', 32.522, 'g', 1.636, 'g', 163.764, 685.187),
(38, 38, 44.986, 'percents', 7.008, 'g', 1.338, 'g', 45.058, 'g', 1.606, 'g', 220.306, 921.759),
(39, 39, 5.973, 'percents', 8.792, 'g', 17.237, 'g', 62.432, 'g', 5.61, 'g', 435.865, 1823.66),
(40, 40, 10.243, 'percents', 9.996, 'g', 1.303, 'g', 77.944, 'g', 2.927, 'g', 371.123, 1552.78),
(41, 41, 10.563, 'percents', 10.321, 'g', 1.97, 'g', 76.623, 'g', 2.297, 'g', 370.567, 1550.45),
(42, 42, 12.183, 'percents', 0.598, 'g', 0, 'g', 87.149, 'g', 0.743, 'g', 361.367, 1511.96),
(43, 43, 11.453, 'percents', 7.214, 'g', 1.903, 'g', 78.873, 'g', 4.713, 'g', 353.482, 1478.97),
(44, 44, 63.538, 'percents', 6.59, 'g', 0.609, 'g', 28.556, 'g', 3.918, 'g', 138.167, 578.089),
(45, 45, 76.223, 'percents', 3.228, 'g', 2.353, 'g', 17.135, 'g', 4.643, 'g', 97.565, 408.212),
(46, 46, 8.143, 'percents', 0.583, 'g', 0.37, 'g', 89.337, 'g', 0.88, 'g', 373.421, 1562.4),
(47, 47, 61.307, 'percents', 2.552, 'g', 4.85, 'g', 30.685, 'g', 2.371, 'g', 171.219, 716.381),
(48, 48, 19.917, 'percents', 12.35, 'g', 5.693, 'g', 59.567, 'g', 5.98, 'g', 343.085, 1435.47),
(49, 49, 26.033, 'percents', 11.343, 'g', 3.58, 'g', 56.51, 'g', 5.707, 'g', 308.726, 1291.71),
(50, 50, 40.673, 'percents', 11.951, 'g', 2.727, 'g', 44.119, 'g', 2.48, 'g', 252.994, 1058.53),
(51, 51, 30.417, 'percents', 8.303, 'g', 3.11, 'g', 56.397, 'g', 4.297, 'g', 292.013, 1221.78),
(52, 52, 34.723, 'percents', 9.425, 'g', 3.653, 'g', 49.942, 'g', 6.883, 'g', 253.194, 1059.36),
(53, 53, 28.483, 'percents', 7.954, 'g', 3.103, 'g', 58.646, 'g', 2.307, 'g', 299.81, 1254.41),
(54, 54, 25.763, 'percents', 8.398, 'g', 2.84, 'g', 61.452, 'g', 2.433, 'g', 310.965, 1301.08),
(55, 55, 34.398, 'percents', 10.741, 'g', 8.793, 'g', 42.017, 'g', 1.04, 'g', 288.702, 1207.93),
(56, 56, 22.923, 'percents', 10.104, 'g', 20.137, 'g', 43.768, 'g', 0.987, 'g', 388.375, 1624.96),
(57, 57, 31.283, 'percents', 9.853, 'g', 9.635, 'g', 45.948, 'g', 1.107, 'g', 308.474, 1290.66),
(58, 58, 17.541, 'percents', 8.71, 'g', 22.67, 'g', 48.133, 'g', 0.943, 'g', 422.112, 1766.12),
(59, 59, 27.066, 'percents', 6.903, 'g', 5.477, 'g', 57.38, 'g', 1.413, 'g', 310.203, 1297.89),
(60, 60, 0.969, 'percents', 6.019, 'g', 40.86, 'g', 49.343, 'g', 1.309, 'g', 569.672, 2383.51),
(61, 61, 2.819, 'percents', 9.927, 'g', 15.941, 'g', 70.313, 'g', 14.337, 'g', 448.334, 1875.83),
(62, 62, 72.74, 'percents', 2.292, 'g', 0.303, 'g', 23.312, 'g', 2.403, 'g', 102.741, 429.869),
(63, 63, 9.047, 'percents', 10.524, 'g', 3.301, 'g', 74.556, 'g', 3.395, 'g', 377.422, 1579.14),
(64, 64, 86.354, 'percents', 1.444, 'g', 0.729, 'g', 10.761, 'g', 2.463, 'g', 48.044, 201.015),
(65, 65, 88.52, 'percents', 1.746, 'g', 0.537, 'g', 8.36, 'g', 2.167, 'g', 38.599, 161.499),
(66, 66, 95.69, 'percents', 0.609, 'g', 0, 'g', 3.301, 'g', 1.17, 'g', 13.606, 56.926),
(67, 67, 95.87, 'percents', 0.96, 'g', 0.06, 'g', 2.667, 'g', 1.703, 'g', 12.364, 51.733),
(68, 68, 92.457, 'percents', 0.394, 'g', 0.799, 'g', 5.982, 'g', 1.547, 'g', 29.004, 121.352),
(69, 69, 92.493, 'percents', 0.671, 'g', 0.116, 'g', 6.123, 'g', 2.3, 'g', 24.466, 102.367),
(70, 70, 95.282, 'percents', 1.125, 'g', 0.199, 'g', 2.977, 'g', 1.588, 'g', 15.039, 62.921),
(71, 71, 93.863, 'percents', 1.141, 'g', 0.14, 'g', 4.292, 'g', 1.353, 'g', 19.279, 80.664),
(72, 72, 93.492, 'percents', 1.069, 'g', 0.821, 'g', 4.187, 'g', 1.38, 'g', 24.43, 102.213),
(73, 73, 90.851, 'percents', 0.64, 'g', 0.139, 'g', 7.867, 'g', 2.605, 'g', 30.811, 128.912),
(74, 74, 93.186, 'percents', 1.444, 'g', 0.106, 'g', 4.631, 'g', 1.122, 'g', 20.942, 87.623),
(75, 75, 93.943, 'percents', 2.688, 'g', 0.237, 'g', 2.252, 'g', 2.137, 'g', 16.579, 69.366),
(76, 76, 93.828, 'percents', 0.758, 'g', 0.069, 'g', 4.272, 'g', 0.957, 'g', 19.091, 79.879),
(77, 77, 97.169, 'percents', 0.608, 'g', 0.129, 'g', 1.745, 'g', 1.022, 'g', 8.795, 36.798),
(78, 78, 96.093, 'percents', 1.348, 'g', 0.16, 'g', 1.696, 'g', 1.827, 'g', 10.681, 44.689),
(79, 79, 95, 'percents', 1.688, 'g', 0.123, 'g', 2.428, 'g', 2.33, 'g', 13.821, 57.827),
(80, 80, 95.728, 'percents', 0.906, 'g', 0.192, 'g', 2.493, 'g', 2.013, 'g', 12.717, 53.208),
(81, 81, 90.208, 'percents', 2.658, 'g', 0.476, 'g', 5.241, 'g', 4.14, 'g', 29.184, 122.104),
(82, 82, 67.547, 'percents', 7.011, 'g', 0.22, 'g', 23.906, 'g', 4.323, 'g', 113.13, 473.335),
(83, 83, 90.952, 'percents', 1.413, 'g', 0.14, 'g', 6.878, 'g', 2.507, 'g', 31.508, 131.829),
(84, 84, 93.67, 'percents', 1.768, 'g', 0.217, 'g', 3.335, 'g', 2.587, 'g', 18.034, 75.456),
(85, 85, 86.545, 'percents', 1.704, 'g', 4.847, 'g', 5.701, 'g', 3.428, 'g', 65.082, 272.303),
(86, 86, 79.261, 'percents', 0.852, 'g', 0.166, 'g', 18.948, 'g', 1.758, 'g', 80.12, 335.221),
(87, 87, 73.69, 'percents', 1.047, 'g', 0.17, 'g', 23.983, 'g', 2.063, 'g', 100.985, 422.521),
(88, 88, 80.425, 'percents', 0.642, 'g', 0.088, 'g', 18.422, 'g', 2.212, 'g', 76.76, 321.162),
(89, 89, 69.513, 'percents', 1.257, 'g', 0.133, 'g', 28.196, 'g', 2.573, 'g', 118.241, 494.722),
(90, 90, 2.697, 'percents', 5.583, 'g', 36.615, 'g', 51.222, 'g', 2.456, 'g', 542.735, 2270.8),
(91, 91, 86.36, 'percents', 1.165, 'g', 0, 'g', 11.944, 'g', 1.343, 'g', 51.588, 215.846),
(92, 92, 82.87, 'percents', 1.772, 'g', 0, 'g', 14.688, 'g', 1.163, 'g', 64.37, 269.325),
(93, 93, 44.121, 'percents', 4.967, 'g', 13.109, 'g', 35.64, 'g', 8.059, 'g', 267.157, 1117.79),
(94, 94, 83.091, 'percents', 1.292, 'g', 0.896, 'g', 14.093, 'g', 1.377, 'g', 67.888, 284.043),
(95, 95, 94.432, 'percents', 0.677, 'g', 0.148, 'g', 4.468, 'g', 2.524, 'g', 18.845, 78.849),
(96, 96, 93.803, 'percents', 1.221, 'g', 0.1, 'g', 4.429, 'g', 2.873, 'g', 19.628, 82.123),
(97, 97, 90.573, 'percents', 1.294, 'g', 0.093, 'g', 7.235, 'g', 1.879, 'g', 32.154, 134.534),
(98, 98, 85.983, 'percents', 1.946, 'g', 0.09, 'g', 11.111, 'g', 3.373, 'g', 48.829, 204.298),
(99, 99, 5.437, 'percents', 1.292, 'g', 12.249, 'g', 80.535, 'g', 1.159, 'g', 437.549, 1830.7),
(100, 100, 92.617, 'percents', 2.133, 'g', 0.459, 'g', 4.367, 'g', 3.417, 'g', 24.636, 103.078),
(101, 101, 91.22, 'percents', 3.645, 'g', 0.267, 'g', 4.025, 'g', 2.88, 'g', 25.495, 106.672),
(102, 102, 78.885, 'percents', 1.529, 'g', 0.112, 'g', 18.853, 'g', 2.635, 'g', 77.585, 324.615),
(103, 103, 73.693, 'percents', 2.283, 'g', 0.137, 'g', 22.954, 'g', 7.273, 'g', 95.633, 400.129),
(104, 104, 87.618, 'percents', 3.2, 'g', 0.585, 'g', 5.974, 'g', 4.469, 'g', 34.032, 142.388),
(105, 105, 91.763, 'percents', 1.869, 'g', 0.282, 'g', 4.752, 'g', 2.048, 'g', 23.888, 99.949),
(106, 106, 87.433, 'percents', 1.95, 'g', 4.806, 'g', 4.809, 'g', 3.65, 'g', 63.449, 265.472),
(107, 107, 88.92, 'percents', 1.71, 'g', 0.08, 'g', 8.853, 'g', 2.187, 'g', 39.42, 164.933),
(108, 108, 93.88, 'percents', 1.866, 'g', 0.35, 'g', 3.371, 'g', 3.55, 'g', 19.516, 81.654),
(109, 109, 91.663, 'percents', 0.848, 'g', 0.218, 'g', 6.687, 'g', 2.629, 'g', 29.862, 124.942),
(110, 110, 90.083, 'percents', 1.322, 'g', 0.173, 'g', 7.66, 'g', 3.183, 'g', 34.135, 142.822),
(111, 111, 95.137, 'percents', 1.138, 'g', 0.143, 'g', 2.853, 'g', 2.2, 'g', 13.837, 57.895),
(112, 112, 94.562, 'percents', 0.415, 'g', 0, 'g', 4.793, 'g', 1.04, 'g', 18.54, 77.57),
(113, 113, 94.837, 'percents', 0.699, 'g', 0.06, 'g', 4.137, 'g', 1.28, 'g', 16.979, 71.04),
(114, 114, 10.63, 'percents', 20.875, 'g', 10.387, 'g', 47.955, 'g', 37.29, 'g', 309.071, 1293.15),
(115, 115, 90.9, 'percents', 2.873, 'g', 0.547, 'g', 4.333, 'g', 3.12, 'g', 27.057, 113.205),
(116, 116, 81.527, 'percents', 1.667, 'g', 6.594, 'g', 8.708, 'g', 5.736, 'g', 90.345, 378.003),
(117, 117, 92.77, 'percents', 1.906, 'g', 0.213, 'g', 4.518, 'g', 2.35, 'g', 22.563, 94.405),
(118, 118, 94.338, 'percents', 1.24, 'g', 0.269, 'g', 3.875, 'g', 2.13, 'g', 19.114, 79.974),
(119, 119, 94.03, 'percents', 1.996, 'g', 0.243, 'g', 2.574, 'g', 2.1, 'g', 16.096, 67.344),
(120, 120, 86.573, 'percents', 2.719, 'g', 5.435, 'g', 4.239, 'g', 2.518, 'g', 67.254, 281.389),
(121, 121, 9.387, 'percents', 1.554, 'g', 0.277, 'g', 87.899, 'g', 6.39, 'g', 360.87, 1509.88),
(122, 122, 8.34, 'percents', 1.229, 'g', 0.287, 'g', 89.194, 'g', 6.54, 'g', 365.269, 1528.29),
(123, 123, 9.801, 'percents', 1.617, 'g', 0.469, 'g', 87.285, 'g', 4.24, 'g', 360.18, 1506.99),
(124, 124, 17.767, 'percents', 0.521, 'g', 0.283, 'g', 81.149, 'g', 0.647, 'g', 330.851, 1384.28),
(125, 125, 87.481, 'percents', 4.167, 'g', 0.103, 'g', 7.758, 'g', 1.966, 'g', 38.723, 162.018),
(126, 126, 73.313, 'percents', 2.051, 'g', 0.213, 'g', 23.233, 'g', 1.653, 'g', 96.7, 404.592),
(127, 127, 91.63, 'percents', 1.402, 'g', 0.22, 'g', 6.191, 'g', 4.827, 'g', 27.365, 114.496),
(128, 128, 66.635, 'percents', 4.413, 'g', 3.91, 'g', 23.059, 'g', 23.921, 'g', 125.812, 526.396),
(129, 129, 68.687, 'percents', 0.575, 'g', 0.298, 'g', 30.09, 'g', 1.557, 'g', 125.358, 524.499),
(130, 130, 61.843, 'percents', 1.13, 'g', 0.3, 'g', 36.17, 'g', 1.877, 'g', 151.417, 633.529),
(131, 131, 6.42, 'percents', 2.063, 'g', 9.12, 'g', 80.304, 'g', 7.817, 'g', 405.694, 1697.42),
(132, 132, 36.566, 'percents', 1.381, 'g', 11.195, 'g', 50.251, 'g', 1.87, 'g', 300.055, 1255.43),
(133, 133, 92.957, 'percents', 1.986, 'g', 0.393, 'g', 3.644, 'g', 3.307, 'g', 21.148, 88.482),
(134, 134, 95.06, 'percents', 1.391, 'g', 0.073, 'g', 2.729, 'g', 2.193, 'g', 13.747, 57.518),
(135, 135, 93.43, 'percents', 2.11, 'g', 0.168, 'g', 3.237, 'g', 1.891, 'g', 18.107, 75.761),
(136, 136, 54.954, 'percents', 5.858, 'g', 1.943, 'g', 36.78, 'g', 1.78, 'g', 180.775, 756.364),
(137, 137, 93.843, 'percents', 1.203, 'g', 0.053, 'g', 4.147, 'g', 2.643, 'g', 18.187, 76.093),
(138, 138, 91.367, 'percents', 1.792, 'g', 0.403, 'g', 4.328, 'g', 3.15, 'g', 23.2, 97.068),
(139, 139, 89.444, 'percents', 2.458, 'g', 0.45, 'g', 5.509, 'g', 2.55, 'g', 29.432, 123.143),
(140, 140, 33.736, 'percents', 5.121, 'g', 24.567, 'g', 34.242, 'g', 0.558, 'g', 363.078, 1519.12),
(141, 141, 41.837, 'percents', 3.648, 'g', 13.989, 'g', 38.512, 'g', 0.976, 'g', 294.538, 1232.35),
(142, 142, 96.787, 'percents', 0.87, 'g', 0, 'g', 2.037, 'g', 1.12, 'g', 9.534, 39.889),
(143, 143, 91.877, 'percents', 1.225, 'g', 0.437, 'g', 5.962, 'g', 1.92, 'g', 27.927, 116.848),
(144, 144, 93.52, 'percents', 1.051, 'g', 0.15, 'g', 4.893, 'g', 2.563, 'g', 21.286, 89.06),
(145, 145, 92.903, 'percents', 1.04, 'g', 0.147, 'g', 5.467, 'g', 1.593, 'g', 23.281, 97.409),
(146, 146, 12.583, 'percents', 0.43, 'g', 0, 'g', 86.773, 'g', 0.237, 'g', 351.227, 1469.53),
(147, 147, 90.575, 'percents', 1.919, 'g', 0.299, 'g', 6.374, 'g', 4.553, 'g', 29.939, 125.266),
(148, 148, 95.063, 'percents', 1.391, 'g', 0.073, 'g', 2.725, 'g', 2.193, 'g', 13.738, 57.48),
(149, 149, 94.72, 'percents', 0.877, 'g', 0.143, 'g', 3.86, 'g', 1.89, 'g', 17.119, 71.625),
(150, 150, 90.084, 'percents', 1.908, 'g', 0.064, 'g', 7.204, 'g', 1.973, 'g', 30.908, 129.317),
(151, 151, 88.699, 'percents', 1.802, 'g', 1.24, 'g', 7.562, 'g', 1.75, 'g', 41.774, 174.78),
(152, 152, 94.816, 'percents', 1.767, 'g', 0.107, 'g', 2.22, 'g', 1.74, 'g', 13.133, 54.95),
(153, 153, 88.65, 'percents', 3.257, 'g', 0.61, 'g', 5.706, 'g', 1.85, 'g', 33.424, 139.846),
(154, 154, 82.147, 'percents', 3.42, 'g', 0.353, 'g', 12.67, 'g', 3.09, 'g', 56.534, 236.537),
(155, 155, 90.248, 'percents', 2.673, 'g', 0.743, 'g', 4.947, 'g', 3.519, 'g', 30.398, 127.185),
(156, 156, 89.243, 'percents', 2.896, 'g', 0.927, 'g', 5.43, 'g', 4.454, 'g', 34.209, 143.13),
(157, 157, 95.127, 'percents', 1.098, 'g', 0.173, 'g', 3.139, 'g', 1.173, 'g', 15.335, 64.162),
(158, 158, 79.663, 'percents', 2.435, 'g', 0.19, 'g', 14.959, 'g', 2.803, 'g', 60.933, 254.945),
(159, 159, 88.137, 'percents', 1.375, 'g', 0.903, 'g', 7.712, 'g', 3.117, 'g', 38.447, 160.86),
(160, 160, 90.793, 'percents', 1.362, 'g', 0, 'g', 6.894, 'g', 1.027, 'g', 27.937, 116.888),
(161, 161, 93.632, 'percents', 0.81, 'g', 0, 'g', 5.118, 'g', 2.268, 'g', 20.547, 85.968),
(162, 162, 92.167, 'percents', 1.786, 'g', 0.173, 'g', 5.347, 'g', 2.383, 'g', 24.898, 104.175),
(163, 163, 83.787, 'percents', 1.239, 'g', 8.397, 'g', 6.031, 'g', 6.313, 'g', 96.155, 402.311),
(164, 164, 86.317, 'percents', 0.859, 'g', 0.123, 'g', 12.335, 'g', 0.987, 'g', 48.322, 202.18),
(165, 165, 91.295, 'percents', 0.467, 'g', 0.113, 'g', 7.799, 'g', 0.327, 'g', 30.592, 127.996),
(166, 166, 83.144, 'percents', 0.833, 'g', 0.703, 'g', 14.927, 'g', 1.696, 'g', 62.424, 261.182),
(167, 167, 73.879, 'percents', 0.721, 'g', 3.66, 'g', 21.455, 'g', 1.723, 'g', 110.298, 461.485),
(168, 168, 88.7, 'percents', 0.798, 'g', 3.944, 'g', 6.208, 'g', 2.553, 'g', 58.045, 242.862),
(169, 169, 90.531, 'percents', 0.906, 'g', 0.208, 'g', 7.966, 'g', 1.511, 'g', 33.462, 140.006),
(170, 170, 93.61, 'percents', 0.592, 'g', 0, 'g', 5.541, 'g', 0.703, 'g', 21.937, 91.784),
(171, 171, 52.174, 'percents', 0.408, 'g', 0, 'g', 46.893, 'g', 0.517, 'g', 182.847, 765.03),
(172, 172, 84.77, 'percents', 0.772, 'g', 0, 'g', 13.852, 'g', 2.433, 'g', 52.542, 219.838),
(173, 173, 50.339, 'percents', 1.025, 'g', 0.28, 'g', 47.658, 'g', 4.547, 'g', 177.359, 742.071),
(174, 174, 72.736, 'percents', 0.971, 'g', 0.3, 'g', 25.332, 'g', 2.135, 'g', 96.972, 405.729),
(175, 175, 63.877, 'percents', 1.435, 'g', 0.24, 'g', 33.665, 'g', 1.527, 'g', 128.024, 535.654),
(176, 176, 21.126, 'percents', 2.169, 'g', 0.05, 'g', 75.667, 'g', 3.833, 'g', 280.105, 1171.96),
(177, 177, 70.074, 'percents', 1.131, 'g', 0.142, 'g', 27.804, 'g', 2.8, 'g', 105.083, 439.666),
(178, 178, 75.23, 'percents', 1.754, 'g', 0.06, 'g', 22.336, 'g', 2.593, 'g', 86.805, 363.194),
(179, 179, 73.797, 'percents', 1.399, 'g', 0.117, 'g', 23.848, 'g', 1.947, 'g', 91.529, 382.957),
(180, 180, 68.177, 'percents', 1.482, 'g', 0.21, 'g', 29.341, 'g', 1.953, 'g', 112.366, 470.14),
(181, 181, 77.711, 'percents', 1.227, 'g', 0.079, 'g', 20.313, 'g', 2.03, 'g', 77.91, 325.973),
(182, 182, 71.863, 'percents', 1.268, 'g', 0.065, 'g', 25.957, 'g', 2.043, 'g', 98.25, 411.077),
(183, 183, 79.209, 'percents', 0.954, 'g', 0.144, 'g', 19.411, 'g', 2.189, 'g', 74.291, 310.836),
(184, 184, 86.894, 'percents', 1.279, 'g', 0, 'g', 11.434, 'g', 2.575, 'g', 45.581, 190.711),
(185, 185, 92.444, 'percents', 0.59, 'g', 0.168, 'g', 6.374, 'g', 1.36, 'g', 26.332, 110.174),
(186, 186, 88.113, 'percents', 0.971, 'g', 0.33, 'g', 10.289, 'g', 1.68, 'g', 43.065, 180.184),
(187, 187, 89.817, 'percents', 0.481, 'g', 0.154, 'g', 9.351, 'g', 0.815, 'g', 36.569, 153.003),
(188, 188, 88.369, 'percents', 0.404, 'g', 0.2, 'g', 10.734, 'g', 0.626, 'g', 45.109, 188.734),
(189, 189, 79.724, 'percents', 0.356, 'g', 0.069, 'g', 19.326, 'g', 6.518, 'g', 71.35, 298.528),
(190, 190, 87.096, 'percents', 0.871, 'g', 0.177, 'g', 11.482, 'g', 2.031, 'g', 45.741, 191.38),
(191, 191, 78.685, 'percents', 1.398, 'g', 0.36, 'g', 18.857, 'g', 3.902, 'g', 75.594, 316.286),
(192, 192, 86.231, 'percents', 1.16, 'g', 0.951, 'g', 10.434, 'g', 3.116, 'g', 49.423, 206.784),
(193, 193, 86.553, 'percents', 0.844, 'g', 0.594, 'g', 11.387, 'g', 1.591, 'g', 48.797, 204.166),
(194, 194, 88.187, 'percents', 0.967, 'g', 0.157, 'g', 10.246, 'g', 1.793, 'g', 41.447, 173.415),
(195, 195, 48.77, 'percents', 0.562, 'g', 0.15, 'g', 50.338, 'g', 1.977, 'g', 184.361, 771.365),
(196, 196, 80.869, 'percents', 1.081, 'g', 0.189, 'g', 17.174, 'g', 5.545, 'g', 67.046, 280.519),
(197, 197, 85.69, 'percents', 0.899, 'g', 0.487, 'g', 12.401, 'g', 6.33, 'g', 51.738, 216.471),
(198, 198, 24.78, 'percents', 0.58, 'g', 0, 'g', 74.124, 'g', 3.733, 'g', 268.96, 1125.33),
(199, 199, 20.261, 'percents', 0.415, 'g', 0.103, 'g', 78.703, 'g', 4.367, 'g', 285.588, 1194.9),
(200, 200, 84.98, 'percents', 1.087, 'g', 0.44, 'g', 13.01, 'g', 6.223, 'g', 54.17, 226.647),
(201, 201, 82.153, 'percents', 0.846, 'g', 0.21, 'g', 15.84, 'g', 1.909, 'g', 61.622, 257.826),
(202, 202, 89.163, 'percents', 0.567, 'g', 0.138, 'g', 9.783, 'g', 1.188, 'g', 38.274, 160.138),
(203, 203, 83.647, 'percents', 0.613, 'g', 0.128, 'g', 15.256, 'g', 2.299, 'g', 58.053, 242.894),
(204, 204, 75.074, 'percents', 1.402, 'g', 0.265, 'g', 22.498, 'g', 2.386, 'g', 87.92, 367.859),
(205, 205, 92.101, 'percents', 0.885, 'g', 0.067, 'g', 6.494, 'g', 5.074, 'g', 26.912, 112.601),
(206, 206, 87.674, 'percents', 0.546, 'g', 0.11, 'g', 10.627, 'g', 1.777, 'g', 41.01, 171.585),
(207, 207, 85.877, 'percents', 1.337, 'g', 0.627, 'g', 11.5, 'g', 2.653, 'g', 51.136, 213.954),
(208, 208, 87.08, 'percents', 0.978, 'g', 0.103, 'g', 11.468, 'g', 1.123, 'g', 45.438, 190.113),
(209, 209, 90.247, 'percents', 0.652, 'g', 0, 'g', 8.698, 'g', 0, 'g', 36.649, 153.341),
(210, 210, 85.379, 'percents', 1.077, 'g', 0.186, 'g', 12.861, 'g', 3.977, 'g', 51.471, 215.355),
(211, 211, 89.22, 'percents', 0.667, 'g', 0.142, 'g', 9.573, 'g', 1.031, 'g', 40.956, 171.36),
(212, 212, 86.974, 'percents', 1.056, 'g', 0.075, 'g', 11.534, 'g', 1.782, 'g', 45.701, 191.213),
(213, 213, 89.681, 'percents', 0.715, 'g', 0.119, 'g', 9.167, 'g', 0.424, 'g', 39.336, 164.582),
(214, 214, 89.55, 'percents', 1.043, 'g', 0.127, 'g', 8.947, 'g', 0.767, 'g', 36.774, 153.861),
(215, 215, 91.293, 'percents', 0.739, 'g', 0.073, 'g', 7.554, 'g', 0, 'g', 32.71, 136.858),
(216, 216, 86.941, 'percents', 0.767, 'g', 0.159, 'g', 11.723, 'g', 1.728, 'g', 46.11, 192.923),
(217, 217, 90.53, 'percents', 0.483, 'g', 0.124, 'g', 8.554, 'g', 0.422, 'g', 36.196, 151.446),
(218, 218, 94.189, 'percents', 0.325, 'g', 0, 'g', 5.247, 'g', 0, 'g', 14.104, 59.01),
(219, 219, 91.797, 'percents', 0.565, 'g', 0.067, 'g', 7.321, 'g', 0, 'g', 22.225, 92.99),
(220, 220, 87.427, 'percents', 0.94, 'g', 0.14, 'g', 11.084, 'g', 1.182, 'g', 31.818, 133.127),
(221, 221, 82.649, 'percents', 0.225, 'g', 0.246, 'g', 16.588, 'g', 2.026, 'g', 62.532, 261.633),
(222, 222, 84.337, 'percents', 0.287, 'g', 0, 'g', 15.153, 'g', 1.347, 'g', 55.515, 232.276),
(223, 223, 41.527, 'percents', 2.083, 'g', 40.657, 'g', 13.945, 'g', 13.444, 'g', 404.282, 1691.52),
(224, 224, 45.529, 'percents', 0.194, 'g', 0.067, 'g', 54.004, 'g', 1.313, 'g', 195.627, 818.505),
(225, 225, 86.927, 'percents', 0.815, 'g', 0.12, 'g', 11.555, 'g', 1.813, 'g', 45.341, 189.706),
(226, 226, 88.583, 'percents', 0.456, 'g', 0.124, 'g', 10.44, 'g', 1.043, 'g', 40.157, 168.016),
(227, 227, 41.881, 'percents', 0.317, 'g', 0.098, 'g', 57.637, 'g', 1.233, 'g', 209.376, 876.03),
(228, 228, 82.288, 'percents', 0.408, 'g', 0.256, 'g', 16.663, 'g', 1.582, 'g', 63.5, 265.685),
(229, 229, 79.736, 'percents', 0.41, 'g', 0.172, 'g', 19.352, 'g', 1.633, 'g', 72.487, 303.285),
(230, 230, 86.498, 'percents', 0.381, 'g', 0.234, 'g', 12.518, 'g', 1.07, 'g', 48.306, 202.112),
(231, 231, 85.813, 'percents', 0.855, 'g', 0.22, 'g', 12.772, 'g', 2.067, 'g', 50.692, 212.096),
(232, 232, 82.853, 'percents', 1.989, 'g', 2.103, 'g', 12.264, 'g', 1.137, 'g', 68.44, 286.351),
(233, 233, 88.895, 'percents', 0.813, 'g', 0.177, 'g', 9.597, 'g', 0.506, 'g', 38.76, 162.171),
(234, 234, 88.942, 'percents', 0.767, 'g', 0.193, 'g', 9.636, 'g', 0.354, 'g', 41.967, 175.591),
(235, 235, 90.667, 'percents', 0.884, 'g', 0, 'g', 8.139, 'g', 0.123, 'g', 32.607, 136.426),
(236, 236, 91.28, 'percents', 0.678, 'g', 0, 'g', 7.526, 'g', 0.25, 'g', 29.369, 122.882),
(237, 237, 83.652, 'percents', 0.883, 'g', 0.134, 'g', 14.862, 'g', 3.073, 'g', 57.593, 240.968),
(238, 238, 89.569, 'percents', 0.65, 'g', 0.128, 'g', 9.337, 'g', 2.732, 'g', 36.871, 154.27),
(239, 239, 91.527, 'percents', 0.895, 'g', 0.31, 'g', 6.818, 'g', 1.723, 'g', 30.148, 126.139),
(240, 240, 87.764, 'percents', 0.308, 'g', 0, 'g', 11.529, 'g', 2.958, 'g', 42.539, 177.984),
(241, 241, 65.889, 'percents', 2.335, 'g', 17.971, 'g', 12.973, 'g', 19.041, 'g', 204.967, 857.581),
(242, 242, 83.186, 'percents', 0.235, 'g', 0.23, 'g', 16.075, 'g', 2.983, 'g', 60.589, 253.503),
(243, 243, 85.033, 'percents', 0.565, 'g', 0.11, 'g', 14.025, 'g', 3.013, 'g', 53.309, 223.045),
(244, 244, 89.321, 'percents', 0.825, 'g', 0, 'g', 9.321, 'g', 1.422, 'g', 36.328, 151.995),
(245, 245, 82.187, 'percents', 0.707, 'g', 0, 'g', 16.88, 'g', 1.017, 'g', 63.142, 264.188),
(246, 246, 75.05, 'percents', 1.485, 'g', 0.319, 'g', 22.448, 'g', 3.356, 'g', 88.474, 370.173),
(247, 247, 88.293, 'percents', 0.929, 'g', 0.169, 'g', 10.244, 'g', 3.237, 'g', 41.416, 173.283),
(248, 248, 94.572, 'percents', 0.285, 'g', 0.121, 'g', 4.759, 'g', 0.737, 'g', 19.105, 79.937),
(249, 249, 83.987, 'percents', 0.404, 'g', 0, 'g', 15.106, 'g', 0.439, 'g', 55.739, 233.212),
(250, 250, 21.95, 'percents', 3.206, 'g', 0.455, 'g', 72.532, 'g', 6.447, 'g', 275.696, 1153.51),
(251, 251, 89.223, 'percents', 0.848, 'g', 0.073, 'g', 9.61, 'g', 0.94, 'g', 37.831, 158.215),
(252, 252, 90.44, 'percents', 0.522, 'g', 0, 'g', 8.8, 'g', 0, 'g', 36.109, 150.981),
(253, 253, 51.26, 'percents', 2.094, 'g', 19.077, 'g', 26.475, 'g', 12.653, 'g', 262.015, 1096.27),
(254, 254, 89.25, 'percents', 0.842, 'g', 0, 'g', 9.395, 'g', 1.982, 'g', 37.017, 154.878),
(255, 255, 90.185, 'percents', 0.513, 'g', 0.07, 'g', 8.787, 'g', 1.336, 'g', 33.943, 142.019),
(256, 256, 84.967, 'percents', 0.746, 'g', 0.203, 'g', 13.573, 'g', 0.92, 'g', 52.873, 221.161),
(257, 257, 86.084, 'percents', 0.608, 'g', 0.157, 'g', 12.695, 'g', 0.934, 'g', 49.061, 205.272),
(258, 258, 85.13, 'percents', 0, 'g', 0, 'g', 14.708, 'g', 0.233, 'g', 57.655, 241.23),
(259, 259, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(260, 260, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(261, 261, 15.787, 'percents', 0.415, 'g', 82.361, 'g', 0.063, 'g', 0, 'g', 725.969, 3037.45),
(262, 262, 13.627, 'percents', 0.396, 'g', 86.039, 'g', 0, 'g', 0, 'g', 757.54, 3169.55),
(263, 263, 32.231, 'percents', 0, 'g', 67.434, 'g', 0, 'g', 0, 'g', 596.12, 2494.16),
(264, 264, 19.586, 'percents', 0, 'g', 81.734, 'g', 0, 'g', 0, 'g', 722.526, 3023.05),
(265, 265, 31.969, 'percents', 0, 'g', 67.246, 'g', 0, 'g', 0, 'g', 594.452, 2487.19),
(266, 266, 33.37, 'percents', 0, 'g', 67.097, 'g', 0, 'g', 0, 'g', 593.137, 2481.69),
(267, 267, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(268, 268, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(269, 269, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(270, 270, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(271, 271, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(272, 272, 0, 'percents', 0, 'g', 100, 'g', 0, 'g', 0, 'g', 884, 3698.66),
(273, 273, 74.322, 'percents', 23.525, 'g', 1.238, 'g', 0, 'g', 0, 'g', 111.616, 466.999),
(274, 274, 79.734, 'percents', 19.346, 'g', 0.942, 'g', 0, 'g', 0, 'g', 91.104, 381.177),
(275, 275, 86.417, 'percents', 13.083, 'g', 0.36, 'g', 0, 'g', 0, 'g', 59.113, 247.329),
(276, 276, 70.957, 'percents', 27.61, 'g', 1.302, 'g', 0, 'g', 0, 'g', 129.644, 542.429),
(277, 277, 64.5, 'percents', 26.188, 'g', 5.997, 'g', 0, 'g', 0, 'g', 165.911, 694.17),
(278, 278, 73.053, 'percents', 25.68, 'g', 0.87, 'g', 0, 'g', 0, 'g', 117.501, 491.624),
(279, 279, 47.887, 'percents', 29.037, 'g', 1.32, 'g', 0, 'g', 0, 'g', 135.893, 568.576),
(280, 280, 65.909, 'percents', 23.979, 'g', 3.607, 'g', 1.224, 'g', 0, 'g', 139.661, 584.34),
(281, 281, 60.623, 'percents', 24.952, 'g', 9.954, 'g', 3.101, 'g', 0.537, 'g', 208.333, 871.664),
(282, 282, 75.928, 'percents', 25.59, 'g', 0.748, 'g', 0, 'g', 0, 'g', 116.014, 485.405),
(283, 283, 81.377, 'percents', 17.854, 'g', 0.787, 'g', 0, 'g', 0, 'g', 83.333, 348.665),
(284, 284, 78.707, 'percents', 18.967, 'g', 1.001, 'g', 0, 'g', 0, 'g', 90.014, 376.617),
(285, 285, 89.134, 'percents', 9.992, 'g', 0.501, 'g', 0, 'g', 0, 'g', 47.183, 197.415),
(286, 286, 61.039, 'percents', 18.388, 'g', 15.62, 'g', 2.88, 'g', 0, 'g', 231.246, 967.534),
(287, 287, 76.997, 'percents', 18.479, 'g', 0.423, 'g', 0, 'g', 0, 'g', 82.722, 346.107),
(288, 288, 75.643, 'percents', 17.367, 'g', 5.987, 'g', 0, 'g', 0, 'g', 128.155, 536.202),
(289, 289, 59.927, 'percents', 19.898, 'g', 19.566, 'g', 0, 'g', 0, 'g', 261.452, 1093.92),
(290, 290, 64.562, 'percents', 20.131, 'g', 16.933, 'g', 0, 'g', 0, 'g', 238.696, 998.705),
(291, 291, 79.247, 'percents', 18.917, 'g', 2.243, 'g', 0, 'g', 0, 'g', 101.009, 422.622),
(292, 292, 79.353, 'percents', 18.57, 'g', 1.583, 'g', 0, 'g', 0, 'g', 94, 391.52),
(293, 293, 69.026, 'percents', 26.767, 'g', 3.574, 'g', 0, 'g', 0, 'g', 146.528, 613.074),
(294, 294, 73.609, 'percents', 23.438, 'g', 2.563, 'g', 0, 'g', 0, 'g', 100.078, 418.727),
(295, 295, 76.16, 'percents', 18.81, 'g', 5.642, 'g', 0, 'g', 0, 'g', 131.208, 548.976),
(296, 296, 71.887, 'percents', 16.813, 'g', 6.547, 'g', 0, 'g', 0, 'g', 130.84, 547.436),
(297, 297, 40.138, 'percents', 28.425, 'g', 22.782, 'g', 0, 'g', 0, 'g', 326.868, 1367.62),
(298, 298, 72.166, 'percents', 15.652, 'g', 9.397, 'g', 0, 'g', 0, 'g', 151.598, 634.287),
(299, 299, 41.305, 'percents', 23.45, 'g', 22.593, 'g', 10.24, 'g', 0.363, 'g', 343.55, 1437.42),
(300, 300, 40.681, 'percents', 30.14, 'g', 24.46, 'g', 0, 'g', 0, 'g', 349.325, 1461.58),
(301, 301, 70.727, 'percents', 26.604, 'g', 0.921, 'g', 0, 'g', 0, 'g', 121.91, 510.072),
(302, 302, 82.073, 'percents', 16.607, 'g', 2.02, 'g', 0, 'g', 0, 'g', 89.131, 372.924),
(303, 303, 63.462, 'percents', 26.929, 'g', 8.497, 'g', 0, 'g', 0, 'g', 191.627, 801.769),
(304, 304, 79.57, 'percents', 16.263, 'g', 4.593, 'g', 0, 'g', 0, 'g', 110.876, 463.906),
(305, 305, 57.003, 'percents', 27.356, 'g', 11.777, 'g', 0, 'g', 0, 'g', 223.04, 933.198),
(306, 306, 53.202, 'percents', 21.435, 'g', 19.115, 'g', 5.033, 'g', 0, 'g', 283.425, 1185.85),
(307, 307, 79.52, 'percents', 16.65, 'g', 4.003, 'g', 0, 'g', 0, 'g', 107.206, 448.548),
(308, 308, 66.804, 'percents', 28.588, 'g', 3.57, 'g', 0, 'g', 0, 'g', 154.27, 645.466),
(309, 309, 74.532, 'percents', 11.75, 'g', 8.024, 'g', 5.015, 'g', 0.78, 'g', 141.958, 593.954),
(310, 310, 80.623, 'percents', 15.479, 'g', 1.143, 'g', 0, 'g', 0, 'g', 76.409, 319.695),
(311, 311, 56.98, 'percents', 36.45, 'g', 3.982, 'g', 0, 'g', 0, 'g', 191.559, 801.483),
(312, 312, 80.27, 'percents', 18.557, 'g', 1.313, 'g', 0, 'g', 0, 'g', 91.083, 381.092),
(313, 313, 65.494, 'percents', 30.796, 'g', 2.294, 'g', 0, 'g', 0, 'g', 152.19, 636.763),
(314, 314, 79.167, 'percents', 20.49, 'g', 0.613, 'g', 0, 'g', 0, 'g', 93.025, 389.215),
(315, 315, 60.927, 'percents', 23.919, 'g', 14.035, 'g', 0, 'g', 0, 'g', 228.732, 957.014),
(316, 316, 68.984, 'percents', 19.252, 'g', 9.709, 'g', 0, 'g', 0, 'g', 169.782, 710.366),
(317, 317, 58.128, 'percents', 26.142, 'g', 14.532, 'g', 0, 'g', 0, 'g', 242.707, 1015.48),
(318, 318, 60.08, 'percents', 32.179, 'g', 2.987, 'g', 0, 'g', 0, 'g', 164.351, 687.644),
(319, 319, 55.143, 'percents', 15.94, 'g', 24.049, 'g', 0, 'g', 0, 'g', 284.981, 1192.36),
(320, 320, 48.489, 'percents', 33.383, 'g', 12.693, 'g', 0, 'g', 0, 'g', 257.041, 1075.46),
(321, 321, 76.64, 'percents', 21.077, 'g', 2.65, 'g', 0, 'g', 0, 'g', 113.9, 476.559),
(322, 322, 79.883, 'percents', 17.958, 'g', 1.22, 'g', 0, 'g', 0, 'g', 87.686, 366.88),
(323, 323, 73.72, 'percents', 13.45, 'g', 6.691, 'g', 2.862, 'g', 0, 'g', 128.857, 539.139),
(324, 324, 2.93, 'percents', 7.82, 'g', 16.57, 'g', 15.053, 'g', 0.577, 'g', 240.623, 1006.77),
(325, 325, 3.383, 'percents', 6.279, 'g', 20.416, 'g', 10.646, 'g', 11.811, 'g', 251.446, 1052.05),
(326, 326, 61.62, 'percents', 26.687, 'g', 10.917, 'g', 0, 'g', 0, 'g', 212.42, 888.767),
(327, 327, 72.703, 'percents', 19.42, 'g', 5.947, 'g', 0, 'g', 0, 'g', 136.562, 571.377),
(328, 328, 60.383, 'percents', 27.27, 'g', 10.883, 'g', 0, 'g', 0, 'g', 214.611, 897.931),
(329, 329, 71.517, 'percents', 20.817, 'g', 6.113, 'g', 0, 'g', 0, 'g', 144.029, 602.619),
(330, 330, 64.283, 'percents', 12.313, 'g', 11.203, 'g', 9.794, 'g', 0, 'g', 189.257, 791.85),
(331, 331, 48.088, 'percents', 18.156, 'g', 15.782, 'g', 14.287, 'g', 0, 'g', 271.813, 1137.27),
(332, 332, 74.123, 'percents', 21.64, 'g', 4.503, 'g', 0, 'g', 0, 'g', 133.023, 556.568),
(333, 333, 74.967, 'percents', 20.53, 'g', 5.503, 'g', 0, 'g', 0, 'g', 137.303, 574.476),
(334, 334, 64.773, 'percents', 19.197, 'g', 14.96, 'g', 0, 'g', 0, 'g', 216.909, 907.547),
(335, 335, 47.88, 'percents', 30.687, 'g', 20.03, 'g', 0, 'g', 0, 'g', 311.703, 1304.16),
(336, 336, 72.987, 'percents', 21.54, 'g', 4.333, 'g', 0, 'g', 0, 'g', 131.062, 548.365),
(337, 337, 53.743, 'percents', 35.063, 'g', 9.95, 'g', 0, 'g', 0, 'g', 239.444, 1001.83),
(338, 338, 45.789, 'percents', 36.365, 'g', 11.918, 'g', 0, 'g', 0, 'g', 262.78, 1099.47),
(339, 339, 44.466, 'percents', 22.715, 'g', 16.837, 'g', 0, 'g', 0, 'g', 248.861, 1041.23),
(340, 340, 42.165, 'percents', 20.613, 'g', 23.998, 'g', 12.175, 'g', 0.37, 'g', 351.593, 1471.06),
(341, 341, 66.38, 'percents', 19.8, 'g', 13.07, 'g', 0, 'g', 0, 'g', 202.437, 846.998),
(342, 342, 52.193, 'percents', 29.88, 'g', 16.333, 'g', 0, 'g', 0, 'g', 274.914, 1150.24),
(343, 343, 65.747, 'percents', 21.15, 'g', 12.81, 'g', 0, 'g', 0, 'g', 205.857, 861.304),
(344, 344, 51.707, 'percents', 32.397, 'g', 15.49, 'g', 0, 'g', 0, 'g', 278.054, 1163.38),
(345, 345, 69.143, 'percents', 23.997, 'g', 6.003, 'g', 0, 'g', 0, 'g', 156.616, 655.281),
(346, 346, 57.533, 'percents', 35.883, 'g', 4.487, 'g', 0, 'g', 0, 'g', 193.692, 810.406),
(347, 347, 43.187, 'percents', 28.807, 'g', 27.72, 'g', 0, 'g', 0, 'g', 373.039, 1560.8),
(348, 348, 52.73, 'percents', 16.707, 'g', 31.75, 'g', 0, 'g', 0, 'g', 357.722, 1496.71),
(349, 349, 58.533, 'percents', 31.88, 'g', 8.923, 'g', 0, 'g', 0, 'g', 216.616, 906.322),
(350, 350, 69.803, 'percents', 21.513, 'g', 6.22, 'g', 0, 'g', 0, 'g', 147.966, 619.091),
(351, 351, 58.043, 'percents', 32.383, 'g', 8.913, 'g', 0, 'g', 0, 'g', 218.675, 914.937),
(352, 352, 68.597, 'percents', 21.23, 'g', 8.693, 'g', 0, 'g', 0, 'g', 169.066, 707.372),
(353, 353, 48.417, 'percents', 28.631, 'g', 23.043, 'g', 0, 'g', 0, 'g', 330.1, 1381.14),
(354, 354, 64.83, 'percents', 19.537, 'g', 15.297, 'g', 0, 'g', 0, 'g', 221.398, 926.327),
(355, 355, 71.33, 'percents', 20.713, 'g', 5.357, 'g', 1.107, 'g', 0, 'g', 141.046, 590.136),
(356, 356, 54.97, 'percents', 29.86, 'g', 9.01, 'g', 4.2, 'g', 0, 'g', 225.026, 941.51),
(357, 357, 71.89, 'percents', 21.6, 'g', 5.613, 'g', 0, 'g', 0, 'g', 142.864, 597.744),
(358, 358, 56.997, 'percents', 32.8, 'g', 8.83, 'g', 0, 'g', 0, 'g', 219.703, 919.236),
(359, 359, 61.983, 'percents', 29.377, 'g', 7.77, 'g', 0, 'g', 0, 'g', 195.575, 818.287),
(360, 360, 72.07, 'percents', 19.997, 'g', 6.217, 'g', 0, 'g', 0, 'g', 141.46, 591.869),
(361, 361, 49.723, 'percents', 24.24, 'g', 26.047, 'g', 0, 'g', 0, 'g', 338.446, 1416.06),
(362, 362, 65.443, 'percents', 17.583, 'g', 16.147, 'g', 0, 'g', 0, 'g', 220.724, 923.508),
(363, 363, 57.63, 'percents', 32.863, 'g', 9.107, 'g', 0, 'g', 0, 'g', 222.469, 930.808),
(364, 364, 70.973, 'percents', 20.543, 'g', 5.227, 'g', 0, 'g', 0, 'g', 134.865, 564.273),
(365, 365, 53.413, 'percents', 21.367, 'g', 24.797, 'g', 0, 'g', 0, 'g', 314.902, 1317.55),
(366, 366, 65.017, 'percents', 17.09, 'g', 15.773, 'g', 0, 'g', 0, 'g', 215.25, 900.605),
(367, 367, 69.99, 'percents', 20.933, 'g', 7.027, 'g', 0, 'g', 0, 'g', 152.766, 639.172),
(368, 368, 65.28, 'percents', 30.735, 'g', 2.422, 'g', 0, 'g', 0, 'g', 153.09, 640.527),
(369, 369, 69.493, 'percents', 21.61, 'g', 7.827, 'g', 0, 'g', 0, 'g', 162.871, 681.453),
(370, 370, 52.43, 'percents', 31.93, 'g', 11.643, 'g', 0, 'g', 0, 'g', 241.364, 1009.87),
(371, 371, 62.82, 'percents', 31.233, 'g', 6.7, 'g', 0, 'g', 0, 'g', 193.8, 810.861),
(372, 372, 72.353, 'percents', 21.56, 'g', 5.49, 'g', 0, 'g', 0, 'g', 141.581, 592.375),
(373, 373, 70.62, 'percents', 21.41, 'g', 7.46, 'g', 0, 'g', 0, 'g', 158.71, 664.042),
(374, 374, 62.943, 'percents', 29.72, 'g', 7.4, 'g', 0, 'g', 0, 'g', 193.652, 810.242),
(375, 375, 72.083, 'percents', 21.03, 'g', 5.67, 'g', 0, 'g', 0, 'g', 140.942, 589.699),
(376, 376, 72.907, 'percents', 21.723, 'g', 4.513, 'g', 0, 'g', 0, 'g', 133.469, 558.434),
(377, 377, 55.15, 'percents', 35.9, 'g', 7.313, 'g', 0, 'g', 0, 'g', 219.259, 917.381),
(378, 378, 51.177, 'percents', 22.247, 'g', 26.993, 'g', 0, 'g', 0, 'g', 338.473, 1416.17),
(379, 379, 61.487, 'percents', 17.557, 'g', 20.433, 'g', 0, 'g', 0, 'g', 259.276, 1084.81),
(380, 380, 65.64, 'percents', 18.823, 'g', 14.69, 'g', 0, 'g', 0, 'g', 212.879, 890.688),
(381, 381, 53.387, 'percents', 26.421, 'g', 19.507, 'g', 0, 'g', 0, 'g', 288.767, 1208.2),
(382, 382, 72.423, 'percents', 21.25, 'g', 4.743, 'g', 0, 'g', 0, 'g', 133.522, 558.658),
(383, 383, 54.633, 'percents', 31.907, 'g', 11.333, 'g', 0, 'g', 0, 'g', 238.468, 997.751),
(384, 384, 47.19, 'percents', 26.931, 'g', 21.929, 'g', 0, 'g', 0, 'g', 312.799, 1308.75),
(385, 385, 39.236, 'percents', 19.658, 'g', 25.367, 'g', 0, 'g', 0, 'g', 312.748, 1308.54),
(386, 386, 42.211, 'percents', 9.61, 'g', 11.836, 'g', 34.521, 'g', 4.97, 'g', 283.048, 1184.27),
(387, 387, 55.956, 'percents', 12.044, 'g', 15.561, 'g', 13.95, 'g', 0, 'g', 245.772, 1028.31),
(388, 388, 39.235, 'percents', 16.863, 'g', 22.673, 'g', 18.146, 'g', 0, 'g', 346.742, 1450.77),
(389, 389, 28.192, 'percents', 6.944, 'g', 15.605, 'g', 47.493, 'g', 2.164, 'g', 358.192, 1498.67),
(390, 390, 32.031, 'percents', 7.344, 'g', 22.888, 'g', 35.529, 'g', 2.22, 'g', 377.48, 1579.38),
(391, 391, 67.47, 'percents', 18.1, 'g', 15.067, 'g', 0, 'g', 0, 'g', 213.188, 891.98),
(392, 392, 59.686, 'percents', 23.883, 'g', 15.616, 'g', 0, 'g', 0, 'g', 242.889, 1016.25),
(393, 393, 61.415, 'percents', 29.575, 'g', 7.702, 'g', 0, 'g', 0, 'g', 195.76, 819.061),
(394, 394, 69.05, 'percents', 12.583, 'g', 18.6, 'g', 0, 'g', 0, 'g', 221.503, 926.768),
(395, 395, 63.512, 'percents', 22.44, 'g', 12.096, 'g', 0.607, 'g', 0, 'g', 207.274, 867.233),
(396, 396, 59.793, 'percents', 28.492, 'g', 10.361, 'g', 0.058, 'g', 0, 'g', 215.119, 900.056),
(397, 397, 72.85, 'percents', 17.093, 'g', 9.81, 'g', 0, 'g', 0, 'g', 161.475, 675.61),
(398, 398, 66.658, 'percents', 26.858, 'g', 5.847, 'g', 0, 'g', 0, 'g', 167.428, 700.519),
(399, 399, 76.417, 'percents', 17.813, 'g', 4.857, 'g', 0.02, 'g', 0, 'g', 119.947, 501.86),
(400, 400, 77.75, 'percents', 17.587, 'g', 3.49, 'g', 0, 'g', 0, 'g', 106.485, 445.531),
(401, 401, 54.89, 'percents', 28.46, 'g', 7.791, 'g', 7.513, 'g', 1.13, 'g', 220.873, 924.132),
(402, 402, 66.54, 'percents', 16.443, 'g', 17.307, 'g', 0, 'g', 0, 'g', 226.319, 946.919),
(403, 403, 63.197, 'percents', 28.025, 'g', 7.502, 'g', 0, 'g', 0, 'g', 187.338, 783.821),
(404, 404, 67.453, 'percents', 24.985, 'g', 7.062, 'g', 0, 'g', 0, 'g', 170.39, 712.912),
(405, 405, 74.857, 'percents', 20.587, 'g', 4.567, 'g', 0, 'g', 0, 'g', 129.096, 540.139),
(406, 406, 58.537, 'percents', 33.417, 'g', 7.649, 'g', 0, 'g', 0, 'g', 211.683, 885.682),
(407, 407, 71.943, 'percents', 20.78, 'g', 6.733, 'g', 0, 'g', 0, 'g', 149.465, 625.363),
(408, 408, 65.569, 'percents', 31.469, 'g', 3.16, 'g', 0, 'g', 0, 'g', 162.875, 681.468),
(409, 409, 74.793, 'percents', 21.527, 'g', 3.02, 'g', 0, 'g', 0, 'g', 119.159, 498.562),
(410, 410, 63.809, 'percents', 32.033, 'g', 2.484, 'g', 0, 'g', 0, 'g', 159.185, 666.03),
(411, 411, 55.004, 'percents', 28.702, 'g', 15.194, 'g', 0, 'g', 0, 'g', 259.605, 1086.19),
(412, 412, 63.58, 'percents', 15.46, 'g', 20.9, 'g', 0, 'g', 0, 'g', 254.532, 1064.96),
(413, 413, 55.63, 'percents', 29.175, 'g', 12.007, 'g', 0, 'g', 0, 'g', 232.883, 974.384),
(414, 414, 72.707, 'percents', 17.57, 'g', 9.62, 'g', 0, 'g', 0, 'g', 161.796, 676.956),
(415, 415, 63.605, 'percents', 13.156, 'g', 16.177, 'g', 4.154, 'g', 0, 'g', 214.836, 898.874),
(416, 416, 52.457, 'percents', 19.973, 'g', 17.012, 'g', 6.32, 'g', 0, 'g', 258.283, 1080.66),
(417, 417, 59.228, 'percents', 13.156, 'g', 12.43, 'g', 11.333, 'g', 0, 'g', 209.832, 877.936),
(418, 418, 64.761, 'percents', 14.24, 'g', 17.44, 'g', 0, 'g', 0, 'g', 218.109, 912.567),
(419, 419, 59.571, 'percents', 18.317, 'g', 18.542, 'g', 0, 'g', 0, 'g', 245.461, 1027.01),
(420, 420, 58.583, 'percents', 18.19, 'g', 18.402, 'g', 0, 'g', 0, 'g', 243.659, 1019.47),
(421, 421, 62.483, 'percents', 16.065, 'g', 17.584, 'g', 0, 'g', 0, 'g', 227.203, 950.619),
(422, 422, 54.609, 'percents', 20.452, 'g', 21.31, 'g', 0, 'g', 0, 'g', 279.544, 1169.61),
(423, 423, 50.479, 'percents', 23.169, 'g', 21.902, 'g', 0, 'g', 0, 'g', 296.49, 1240.51),
(424, 424, 56.439, 'percents', 11.952, 'g', 21.649, 'g', 5.816, 'g', 0, 'g', 268.82, 1124.74),
(425, 425, 65.323, 'percents', 26.202, 'g', 5.675, 'g', 0, 'g', 0, 'g', 163.071, 682.291),
(426, 426, 78.177, 'percents', 18.083, 'g', 1.83, 'g', 0, 'g', 0, 'g', 93.722, 392.135),
(427, 427, 67.703, 'percents', 21.5, 'g', 8.017, 'g', 0, 'g', 0, 'g', 164.115, 686.659),
(428, 428, 47.327, 'percents', 33.748, 'g', 18.522, 'g', 0, 'g', 0, 'g', 311.169, 1301.93),
(429, 429, 51.844, 'percents', 28.89, 'g', 17.375, 'g', 0, 'g', 0, 'g', 280.084, 1171.87),
(430, 430, 36.92, 'percents', 30.223, 'g', 30.279, 'g', 0, 'g', 0, 'g', 402.168, 1682.67),
(431, 431, 61.21, 'percents', 18, 'g', 19.817, 'g', 0, 'g', 0, 'g', 255.606, 1069.46),
(432, 432, 56.561, 'percents', 35.725, 'g', 6.396, 'g', 0, 'g', 0, 'g', 210.235, 879.622),
(433, 433, 67.733, 'percents', 22.604, 'g', 8.77, 'g', 0, 'g', 0, 'g', 175.625, 734.816),
(434, 434, 59.667, 'percents', 18.521, 'g', 19.89, 'g', 0, 'g', 0, 'g', 258.492, 1081.53),
(435, 435, 49.256, 'percents', 32.133, 'g', 13.864, 'g', 0, 'g', 0, 'g', 262.26, 1097.29),
(436, 436, 67.08, 'percents', 20.125, 'g', 11.1, 'g', 0, 'g', 0, 'g', 186.056, 778.457),
(437, 437, 43.79, 'percents', 15.581, 'g', 34.466, 'g', 0, 'g', 0, 'g', 377.415, 1579.1),
(438, 438, 73.946, 'percents', 14.371, 'g', 6.771, 'g', 1.398, 'g', 0, 'g', 127.849, 534.921),
(439, 439, 77.181, 'percents', 14.292, 'g', 2.707, 'g', 2.146, 'g', 0, 'g', 93.743, 392.222),
(440, 440, 69.018, 'percents', 14.594, 'g', 2.676, 'g', 12.861, 'g', 1.897, 'g', 136.229, 569.982),
(441, 441, 74.509, 'percents', 12.354, 'g', 1.668, 'g', 10.774, 'g', 1.647, 'g', 109.491, 458.109),
(442, 442, 53.964, 'percents', 14.89, 'g', 15.799, 'g', 12.337, 'g', 0, 'g', 253.831, 1062.03),
(443, 443, 34.703, 'percents', 25.81, 'g', 30.641, 'g', 2.906, 'g', 0, 'g', 397.843, 1664.57),
(444, 444, 27.607, 'percents', 11.479, 'g', 60.257, 'g', 0, 'g', 0, 'g', 592.531, 2479.15),
(445, 445, 6.325, 'percents', 27.283, 'g', 64.309, 'g', 0, 'g', 0, 'g', 696.564, 2914.42),
(446, 446, 87.693, 'percents', 2.133, 'g', 1.907, 'g', 7.57, 'g', 0.293, 'g', 55.165, 230.81),
(447, 447, 70.893, 'percents', 1.508, 'g', 22.479, 'g', 4.51, 'g', 0, 'g', 221.484, 926.687),
(448, 448, 90.04, 'percents', 4.063, 'g', 3.04, 'g', 1.917, 'g', 0, 'g', 51.49, 215.432),
(449, 449, 89.216, 'percents', 3.834, 'g', 0.316, 'g', 5.774, 'g', 0, 'g', 41.493, 173.606),
(450, 450, 0, 'percents', 0, 'g', 0, 'g', 0, 'g', 0, 'g', 0, 0),
(451, 451, 84.633, 'percents', 2.71, 'g', 2.33, 'g', 9.693, 'g', 0.217, 'g', 69.566, 291.062),
(452, 452, 85.057, 'percents', 2.53, 'g', 2.337, 'g', 9.433, 'g', 0.717, 'g', 67.849, 283.882),
(453, 453, 26.96, 'percents', 7.67, 'g', 6.74, 'g', 56.997, 'g', 0, 'g', 312.573, 1307.8),
(454, 454, 87.071, 'percents', 3.071, 'g', 3.754, 'g', 5.246, 'g', 0, 'g', 66.416, 277.883),
(455, 455, 80.894, 'percents', 2.099, 'g', 2.169, 'g', 14.158, 'g', 0.646, 'g', 82.821, 346.523),
(456, 456, 3.1, 'percents', 34.69, 'g', 0.933, 'g', 53.043, 'g', 0, 'g', 361.608, 1512.97),
(457, 457, 0, 'percents', 0, 'g', 0, 'g', 0, 'g', 0, 'g', 0, 0),
(458, 458, 0, 'percents', 0, 'g', 0, 'g', 0, 'g', 0, 'g', 0, 0),
(459, 459, 2.7, 'percents', 25.42, 'g', 26.903, 'g', 39.18, 'g', 0, 'g', 496.65, 2077.99),
(460, 460, 81.879, 'percents', 1.895, 'g', 0.099, 'g', 15.674, 'g', 0, 'g', 69.621, 291.296),
(461, 461, 56.125, 'percents', 17.411, 'g', 20.181, 'g', 3.24, 'g', 0, 'g', 264.273, 1105.72),
(462, 462, 47.118, 'percents', 21.211, 'g', 24.61, 'g', 3.573, 'g', 0, 'g', 320.722, 1341.9),
(463, 463, 45.338, 'percents', 22.649, 'g', 25.183, 'g', 3.049, 'g', 0, 'g', 329.871, 1380.18),
(464, 464, 21.247, 'percents', 35.554, 'g', 33.529, 'g', 1.661, 'g', 0, 'g', 452.964, 1895.2),
(465, 465, 54.421, 'percents', 9.357, 'g', 27.435, 'g', 5.676, 'g', 0, 'g', 303.08, 1268.09),
(466, 466, 72.215, 'percents', 5.787, 'g', 2.838, 'g', 18.462, 'g', 0, 'g', 121.106, 506.707),
(467, 467, 42.444, 'percents', 22.662, 'g', 29.106, 'g', 1.879, 'g', 0, 'g', 359.88, 1505.74),
(468, 468, 62.466, 'percents', 9.63, 'g', 23.441, 'g', 2.432, 'g', 0, 'g', 256.578, 1073.52),
(469, 469, 73.571, 'percents', 12.601, 'g', 8.109, 'g', 3.786, 'g', 0, 'g', 139.732, 584.638),
(470, 470, 93.507, 'percents', 0, 'g', 0, 'g', 6.403, 'g', 0, 'g', 25.613, 107.166),
(471, 471, 97.372, 'percents', 0.713, 'g', 0.069, 'g', 1.479, 'g', 0, 'g', 9.071, 37.953),
(472, 472, 0, 'percents', 0, 'g', 0, 'g', 0, 'g', 0, 'g', 215.662, 902.328),
(473, 473, 81.728, 'percents', 0, 'g', 0, 'g', 18.151, 'g', 0.136, 'g', 65.344, 273.398),
(474, 474, 92.38, 'percents', 0.563, 'g', 0, 'g', 3.318, 'g', 0, 'g', 40.72, 170.373),
(475, 475, 99.609, 'percents', 0, 'g', 0, 'g', 0.391, 'g', 0, 'g', 1.397, 5.845),
(476, 476, 99.305, 'percents', 0, 'g', 0.052, 'g', 0.643, 'g', 0, 'g', 2.731, 11.425),
(477, 477, 99.37, 'percents', 0, 'g', 0, 'g', 0.63, 'g', 0, 'g', 2.248, 9.405),
(478, 478, 94.252, 'percents', 0, 'g', 0, 'g', 5.285, 'g', 0.13, 'g', 21.509, 89.992),
(479, 479, 92.007, 'percents', 0, 'g', 0, 'g', 7.953, 'g', 0, 'g', 30.779, 128.781),
(480, 480, 91.277, 'percents', 0, 'g', 0, 'g', 8.66, 'g', 0, 'g', 33.514, 140.223),
(481, 481, 89.957, 'percents', 0, 'g', 0, 'g', 10, 'g', 0, 'g', 38.7, 161.921),
(482, 482, 88.173, 'percents', 0, 'g', 0, 'g', 11.79, 'g', 0, 'g', 45.627, 190.905),
(483, 483, 89.69, 'percents', 0, 'g', 0, 'g', 10.263, 'g', 0, 'g', 39.719, 166.185),
(484, 484, 60.492, 'percents', 15.571, 'g', 22.008, 'g', 0.437, 'g', 0, 'g', 268.007, 1121.34),
(485, 485, 71.67, 'percents', 13.688, 'g', 12.68, 'g', 0.772, 'g', 0, 'g', 176.894, 740.124),
(486, 486, 85.228, 'percents', 13.448, 'g', 0.089, 'g', 0, 'g', 0, 'g', 59.436, 248.679),
(487, 487, 50.023, 'percents', 15.9, 'g', 30.777, 'g', 1.56, 'g', 0, 'g', 352.673, 1475.58),
(488, 488, 75.766, 'percents', 13.294, 'g', 9.476, 'g', 0.615, 'g', 0, 'g', 145.7, 609.61),
(489, 489, 75.6, 'percents', 13.03, 'g', 8.9, 'g', 1.637, 'g', 0, 'g', 143.112, 598.779),
(490, 490, 63.497, 'percents', 15.617, 'g', 18.593, 'g', 1.194, 'g', 0, 'g', 240.187, 1004.94),
(491, 491, 1.103, 'percents', 4.203, 'g', 2.167, 'g', 91.177, 'g', 3.89, 'g', 401.02, 1677.87),
(492, 492, 0.05, 'percents', 0.32, 'g', 0, 'g', 99.61, 'g', 0, 'g', 386.846, 1619.21),
(493, 493, 3.324, 'percents', 0.758, 'g', 0.092, 'g', 94.45, 'g', 0, 'g', 368.555, 1542.03),
(494, 494, 0.12, 'percents', 0.32, 'g', 0, 'g', 99.54, 'g', 0, 'g', 386.575, 1617.43),
(495, 495, 1.257, 'percents', 7.22, 'g', 30.267, 'g', 59.577, 'g', 2.17, 'g', 539.587, 2257.63),
(496, 496, 1.214, 'percents', 7.413, 'g', 34.191, 'g', 55.377, 'g', 2.458, 'g', 558.876, 2338.34),
(497, 497, 1.732, 'percents', 6.898, 'g', 33.771, 'g', 56.323, 'g', 2.847, 'g', 556.824, 2329.75),
(498, 498, 1.022, 'percents', 4.862, 'g', 29.857, 'g', 62.423, 'g', 4.944, 'g', 474.918, 1987.06),
(499, 499, 3.424, 'percents', 1.122, 'g', 13.587, 'g', 81.383, 'g', 3.569, 'g', 448.845, 1877.97),
(500, 500, 43.88, 'percents', 0.917, 'g', 0.207, 'g', 54.613, 'g', 2.28, 'g', 198.936, 832.348),
(501, 501, 27.5, 'percents', 5.478, 'g', 5.993, 'g', 59.493, 'g', 0, 'g', 306.31, 1281.6),
(502, 502, 73.48, 'percents', 2.125, 'g', 0.073, 'g', 24.232, 'g', 0, 'g', 106.087, 443.867),
(503, 503, 20.413, 'percents', 0, 'g', 0, 'g', 79.38, 'g', 0, 'g', 292.118, 1222.22),
(504, 504, 21.572, 'percents', 3.813, 'g', 0.19, 'g', 73.553, 'g', 0.667, 'g', 301.236, 1260.37),
(505, 505, 20.732, 'percents', 3.935, 'g', 0.089, 'g', 75.059, 'g', 0.637, 'g', 306.632, 1282.95),
(506, 506, 28.499, 'percents', 0.4, 'g', 0.137, 'g', 70.763, 'g', 4.07, 'g', 257.241, 1076.3),
(507, 507, 15.823, 'percents', 0, 'g', 0, 'g', 84.033, 'g', 0, 'g', 309.243, 1293.87),
(508, 508, 22.087, 'percents', 0, 'g', 0, 'g', 76.617, 'g', 0, 'g', 296.506, 1240.58),
(509, 509, 23.93, 'percents', 4.738, 'g', 24.425, 'g', 46.299, 'g', 3.223, 'g', 411.349, 1721.08),
(510, 510, 7.095, 'percents', 0.99, 'g', 0.071, 'g', 90.792, 'g', 0, 'g', 351.958, 1472.59),
(511, 511, 2.93, 'percents', 14.7, 'g', 11.947, 'g', 65.753, 'g', 51.227, 'g', 418.619, 1751.5),
(512, 512, 2.603, 'percents', 11.313, 'g', 8.633, 'g', 73.614, 'g', 2.443, 'g', 417.407, 1746.43),
(513, 513, 7.077, 'percents', 0.475, 'g', 0.073, 'g', 43.911, 'g', 0, 'g', 89.722, 375.397),
(514, 514, 71.901, 'percents', 16.957, 'g', 1.518, 'g', 7.699, 'g', 4.166, 'g', 89.795, 375.702),
(515, 515, 1.243, 'percents', 8.887, 'g', 0, 'g', 89.223, 'g', 0, 'g', 380.223, 1590.85),
(516, 516, 0.597, 'percents', 0, 'g', 0, 'g', 0, 'g', 0, 'g', 0, 0),
(517, 517, 0.413, 'percents', 0, 'g', 0, 'g', 0, 'g', 0, 'g', 0, 0),
(518, 518, 70.627, 'percents', 3.313, 'g', 0.327, 'g', 11.648, 'g', 0, 'g', 60.928, 254.922),
(519, 519, 7.65, 'percents', 2.667, 'g', 0.263, 'g', 2.073, 'g', 0.557, 'g', 21.33, 89.245),
(520, 520, 68.464, 'percents', 1.163, 'g', 20.345, 'g', 5.545, 'g', 4.555, 'g', 194.154, 812.34),
(521, 521, 76.259, 'percents', 0.948, 'g', 14.216, 'g', 4.102, 'g', 3.846, 'g', 136.936, 572.942),
(522, 522, 55.143, 'percents', 0.525, 'g', 27.271, 'g', 16.855, 'g', 0, 'g', 314.956, 1317.78),
(523, 523, 77.984, 'percents', 1.014, 'g', 18.364, 'g', 2.195, 'g', 0.684, 'g', 166.16, 695.215),
(524, 524, 58.424, 'percents', 0.581, 'g', 30.498, 'g', 7.9, 'g', 0, 'g', 302.153, 1264.21),
(525, 525, 50.464, 'percents', 8.346, 'g', 19.93, 'g', 19.114, 'g', 9.358, 'g', 289.212, 1210.06),
(526, 526, 68.036, 'percents', 10.829, 'g', 7.124, 'g', 11.585, 'g', 1.502, 'g', 153.772, 643.382),
(527, 527, 69.051, 'percents', 6.24, 'g', 3.228, 'g', 20.418, 'g', 5.069, 'g', 135.681, 567.691),
(528, 528, 71.167, 'percents', 18.269, 'g', 9.534, 'g', 0.236, 'g', 0.147, 'g', 164.975, 690.256),
(529, 529, 54.212, 'percents', 23.66, 'g', 21.147, 'g', 0, 'g', 0, 'g', 291.23, 1218.5),
(530, 530, 41.5, 'percents', 8.04, 'g', 8.292, 'g', 41.683, 'g', 2.737, 'g', 273.514, 1144.38),
(531, 531, 81.989, 'percents', 7.942, 'g', 5.968, 'g', 3.174, 'g', 0.387, 'g', 100.783, 421.676),
(532, 532, 81.549, 'percents', 6.779, 'g', 1.117, 'g', 10.133, 'g', 1.46, 'g', 78.235, 327.334),
(533, 533, 71.137, 'percents', 2.156, 'g', 0.68, 'g', 25.281, 'g', 2.053, 'g', 113.459, 474.714),
(534, 534, 68.937, 'percents', 2.558, 'g', 4.648, 'g', 22.514, 'g', 2.433, 'g', 142.123, 594.643),
(535, 535, 80.994, 'percents', 5.644, 'g', 3.593, 'g', 5.739, 'g', 3.017, 'g', 80.092, 335.103),
(536, 536, 75.267, 'percents', 19.773, 'g', 4.442, 'g', 0, 'g', 0, 'g', 124.5, 520.909),
(537, 537, 70.128, 'percents', 15.031, 'g', 10.803, 'g', 2.975, 'g', 0, 'g', 173.141, 724.423),
(538, 538, 70.892, 'percents', 17.552, 'g', 7.962, 'g', 2.594, 'g', 0, 'g', 156.806, 656.077),
(539, 539, 61.668, 'percents', 10.171, 'g', 6.791, 'g', 19.582, 'g', 3.573, 'g', 151.562, 634.135),
(540, 540, 71.801, 'percents', 8.671, 'g', 6.477, 'g', 11.642, 'g', 5.09, 'g', 116.933, 489.25),
(541, 541, 79.525, 'percents', 9.698, 'g', 6.17, 'g', 4.062, 'g', 0.223, 'g', 112.784, 471.887),
(542, 542, 71.412, 'percents', 4.934, 'g', 0.89, 'g', 22.522, 'g', 0.777, 'g', 119.532, 500.121),
(543, 543, 76.395, 'percents', 9.958, 'g', 8.699, 'g', 3.419, 'g', 2.16, 'g', 134.223, 561.589),
(544, 544, 81.106, 'percents', 8.556, 'g', 2.672, 'g', 6.644, 'g', 1.667, 'g', 86.349, 361.285),
(545, 545, 82.037, 'percents', 1.05, 'g', 7.039, 'g', 8.924, 'g', 2.217, 'g', 96.104, 402.097);
INSERT INTO `ingrediente_val_nutricional` (`ingrediente_val_nutricional_id`, `ingrediente_id`, `humidity_qtd`, `humidity_unit`, `protein_qtd`, `protein_unit`, `lipid_qtd`, `lipid_unit`, `carbohydrate_qtd`, `carbohydrate_unit`, `fiber_qtd`, `fiber_unit`, `energy_kcal`, `energy_kj`) VALUES
(546, 546, 89.979, 'percents', 2.006, 'g', 0.312, 'g', 7.089, 'g', 2.513, 'g', 35.408, 148.148),
(547, 547, 72.528, 'percents', 13.925, 'g', 7.841, 'g', 4.569, 'g', 0.41, 'g', 147.865, 618.665),
(548, 548, 74.951, 'percents', 18.473, 'g', 4.42, 'g', 1.094, 'g', 0, 'g', 122.982, 514.556),
(549, 549, 85.77, 'percents', 2.046, 'g', 1.208, 'g', 10.581, 'g', 2.083, 'g', 57.453, 240.385),
(550, 550, 85.193, 'percents', 6.958, 'g', 0.36, 'g', 3.39, 'g', 0.213, 'g', 46.889, 196.184),
(551, 551, 24.902, 'percents', 0.09, 'g', 10.908, 'g', 63.592, 'g', 0, 'g', 347.827, 1455.31),
(552, 552, 91.884, 'percents', 2.056, 'g', 0.284, 'g', 4.738, 'g', 0.227, 'g', 27.184, 113.737),
(553, 553, 74.951, 'percents', 5.123, 'g', 9.322, 'g', 10.061, 'g', 2.343, 'g', 144.897, 606.249),
(554, 554, 58.362, 'percents', 5.998, 'g', 23.226, 'g', 9.748, 'g', 1.697, 'g', 254.893, 1066.47),
(555, 555, 48.59, 'percents', 10.181, 'g', 25.591, 'g', 14.109, 'g', 2.163, 'g', 306.947, 1284.27),
(556, 556, 69.377, 'percents', 7.517, 'g', 2.607, 'g', 18.251, 'g', 1.057, 'g', 112.802, 471.964),
(557, 557, 6.427, 'percents', 27.191, 'g', 43.85, 'g', 20.314, 'g', 8.036, 'g', 544.053, 2276.32),
(558, 558, 1.687, 'percents', 22.475, 'g', 53.963, 'g', 18.702, 'g', 7.763, 'g', 605.781, 2534.59),
(559, 559, 76.841, 'percents', 7.452, 'g', 0.471, 'g', 14.228, 'g', 9.721, 'g', 88.094, 366.967),
(560, 560, 80.143, 'percents', 4.598, 'g', 0.38, 'g', 13.442, 'g', 5.08, 'g', 73.845, 308.966),
(561, 561, 80.351, 'percents', 4.775, 'g', 0.542, 'g', 13.591, 'g', 8.51, 'g', 76.424, 319.758),
(562, 562, 13.997, 'percents', 19.982, 'g', 1.257, 'g', 61.221, 'g', 18.42, 'g', 329.027, 1376.65),
(563, 563, 80.009, 'percents', 5.094, 'g', 0.644, 'g', 13.5, 'g', 7.472, 'g', 78.009, 326.389),
(564, 564, 12.697, 'percents', 20.208, 'g', 2.365, 'g', 61.24, 'g', 23.593, 'g', 339.165, 1419.06),
(565, 565, 75.842, 'percents', 6.144, 'g', 0.512, 'g', 16.495, 'g', 13.866, 'g', 92.74, 388.024),
(566, 566, 13.533, 'percents', 20.104, 'g', 0.947, 'g', 61.479, 'g', 30.32, 'g', 327.905, 1371.96),
(567, 567, 80.218, 'percents', 4.479, 'g', 0.536, 'g', 14.005, 'g', 8.402, 'g', 77.027, 322.282),
(568, 568, 14.877, 'percents', 21.344, 'g', 1.24, 'g', 58.752, 'g', 21.833, 'g', 323.566, 1353.8),
(569, 569, 77.864, 'percents', 5.538, 'g', 0.4, 'g', 15.268, 'g', 9.318, 'g', 84.702, 354.393),
(570, 570, 14.963, 'percents', 17.271, 'g', 1.17, 'g', 62.929, 'g', 24.007, 'g', 325.844, 1363.33),
(571, 571, 82.581, 'percents', 4.54, 'g', 0.477, 'g', 11.823, 'g', 4.76, 'g', 67.866, 283.952),
(572, 572, 11.953, 'percents', 20.917, 'g', 1.33, 'g', 62.223, 'g', 20.627, 'g', 336.962, 1409.85),
(573, 573, 79.986, 'percents', 5.721, 'g', 0.538, 'g', 12.908, 'g', 11.514, 'g', 76.893, 321.722),
(574, 574, 12.637, 'percents', 22.167, 'g', 1.237, 'g', 59.987, 'g', 33.843, 'g', 331.415, 1386.64),
(575, 575, 12.29, 'percents', 21.229, 'g', 5.43, 'g', 57.884, 'g', 12.357, 'g', 354.703, 1484.08),
(576, 576, 11.449, 'percents', 18.965, 'g', 2.132, 'g', 64, 'g', 21.314, 'g', 344.134, 1439.85),
(577, 577, 76.251, 'percents', 6.31, 'g', 0.525, 'g', 16.302, 'g', 7.862, 'g', 92.639, 387.601),
(578, 578, 11.467, 'percents', 23.152, 'g', 0.77, 'g', 62.004, 'g', 16.937, 'g', 339.141, 1418.97),
(579, 579, 1.801, 'percents', 15.996, 'g', 26.075, 'g', 52.376, 'g', 7.319, 'g', 486.927, 2037.3),
(580, 580, 2.91, 'percents', 13.162, 'g', 28.048, 'g', 54.73, 'g', 3.393, 'g', 503.19, 2105.35),
(581, 581, 5.75, 'percents', 36.03, 'g', 14.633, 'g', 38.44, 'g', 20.18, 'g', 403.956, 1690.15),
(582, 582, 91.284, 'percents', 2.381, 'g', 1.606, 'g', 4.275, 'g', 0.366, 'g', 39.105, 163.615),
(583, 583, 4.468, 'percents', 35.688, 'g', 26.181, 'g', 28.483, 'g', 7.313, 'g', 458.896, 1920.02),
(584, 584, 86.646, 'percents', 6.553, 'g', 3.953, 'g', 2.127, 'g', 0.753, 'g', 64.485, 269.806),
(585, 585, 9.692, 'percents', 33.575, 'g', 10.342, 'g', 43.786, 'g', 32.307, 'g', 381.278, 1595.27),
(586, 586, 67.684, 'percents', 11.108, 'g', 3.784, 'g', 12.389, 'g', 14.44, 'g', 120.643, 504.769),
(587, 587, 3.106, 'percents', 18.555, 'g', 47.324, 'g', 29.547, 'g', 11.64, 'g', 580.747, 2429.84),
(588, 588, 3.464, 'percents', 18.509, 'g', 46.28, 'g', 29.135, 'g', 3.663, 'g', 570.168, 2385.58),
(589, 589, 3.524, 'percents', 14.536, 'g', 63.459, 'g', 15.079, 'g', 7.931, 'g', 642.963, 2690.16),
(590, 590, 42.961, 'percents', 3.692, 'g', 41.976, 'g', 10.402, 'g', 5.378, 'g', 406.487, 1700.74),
(591, 591, 0, 'percents', 0, 'g', 0, 'g', 0, 'g', 0, 'g', 0, 0),
(592, 592, 15.823, 'percents', 1.406, 'g', 0.198, 'g', 79.173, 'g', 17.86, 'g', 328.771, 1375.58),
(593, 593, 3.859, 'percents', 21.165, 'g', 50.433, 'g', 21.618, 'g', 11.868, 'g', 583.547, 2441.56),
(594, 594, 6.683, 'percents', 14.084, 'g', 32.253, 'g', 43.312, 'g', 33.503, 'g', 495.096, 2071.53),
(595, 595, 50.513, 'percents', 2.98, 'g', 0.747, 'g', 43.918, 'g', 15.603, 'g', 174.37, 729.564),
(596, 596, 54.46, 'percents', 2.523, 'g', 12.762, 'g', 29.569, 'g', 4.253, 'g', 218.534, 914.346),
(597, 597, 6.245, 'percents', 13.971, 'g', 59.36, 'g', 18.364, 'g', 7.25, 'g', 620.06, 2594.33);

-- --------------------------------------------------------

--
-- Estrutura da tabela `momento`
--

DROP TABLE IF EXISTS `momento`;
CREATE TABLE `momento` (
  `momento_id` int(11) NOT NULL,
  `momento_desc` varchar(45) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Extraindo dados da tabela `momento`
--

INSERT INTO `momento` (`momento_id`, `momento_desc`) VALUES
(1, 'Café da Manhã'),
(2, 'Lanche da Manhã'),
(3, 'Almoço'),
(4, 'Lanche da Tarde'),
(5, 'Jantar'),
(6, 'Lanche da Noite');

-- --------------------------------------------------------

--
-- Estrutura da tabela `paciente_profissional`
--

DROP TABLE IF EXISTS `paciente_profissional`;
CREATE TABLE `paciente_profissional` (
  `paciente_profissional_id` int(11) NOT NULL,
  `paciente_id` int(11) NOT NULL,
  `profissional_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita`
--

DROP TABLE IF EXISTS `receita`;
CREATE TABLE `receita` (
  `receita_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `nivel_receita_id` int(11) NOT NULL,
  `receita_tempo_preparo` time DEFAULT NULL,
  `receita_porcoes` int(11) DEFAULT NULL,
  `receita_nome` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `receita_desc` text COLLATE utf8_bin DEFAULT NULL,
  `recita_modo` tinyint(4) DEFAULT NULL,
  `receita_status` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_aval`
--

DROP TABLE IF EXISTS `receita_aval`;
CREATE TABLE `receita_aval` (
  `receita_aval_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `ra_nota` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_categorias`
--

DROP TABLE IF EXISTS `receita_categorias`;
CREATE TABLE `receita_categorias` (
  `receita_categorias_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL,
  `categoria_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_imagens`
--

DROP TABLE IF EXISTS `receita_imagens`;
CREATE TABLE `receita_imagens` (
  `receita_imagens_id` int(11) NOT NULL,
  `receita_receita_id` int(11) NOT NULL,
  `receita_imagens_path` varchar(150) COLLATE utf8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_ingredientes`
--

DROP TABLE IF EXISTS `receita_ingredientes`;
CREATE TABLE `receita_ingredientes` (
  `receita_ingredientes_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL,
  `ingredientes_id` int(11) NOT NULL,
  `receita_ingredientes_qtd` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_momentos`
--

DROP TABLE IF EXISTS `receita_momentos`;
CREATE TABLE `receita_momentos` (
  `receita_momentos_id` int(11) NOT NULL,
  `momento_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_nivel`
--

DROP TABLE IF EXISTS `receita_nivel`;
CREATE TABLE `receita_nivel` (
  `receita_nivel_id` int(11) NOT NULL,
  `rn_nivel` varchar(45) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_passos`
--

DROP TABLE IF EXISTS `receita_passos`;
CREATE TABLE `receita_passos` (
  `receita_passos_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL,
  `rp_numero` int(11) NOT NULL,
  `rp_desc` mediumtext COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `receita_val_nutricional`
--

DROP TABLE IF EXISTS `receita_val_nutricional`;
CREATE TABLE `receita_val_nutricional` (
  `receita_val_nutricional_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL,
  `humidity_qtd` float NOT NULL,
  `humidity_unit` varchar(45) COLLATE utf8_bin NOT NULL,
  `protein_qtd` float NOT NULL,
  `protein_unit` varchar(45) COLLATE utf8_bin NOT NULL,
  `lipid_qtd` float NOT NULL,
  `lipid_unit` varchar(45) COLLATE utf8_bin NOT NULL,
  `carbohydrate_qtd` float NOT NULL,
  `carbohydrate_unit` varchar(45) COLLATE utf8_bin NOT NULL,
  `fiber_qtd` float NOT NULL,
  `fiber_unit` varchar(45) COLLATE utf8_bin NOT NULL,
  `energy_kcal` float NOT NULL,
  `energy_kj` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `udm_receita`
--

DROP TABLE IF EXISTS `udm_receita`;
CREATE TABLE `udm_receita` (
  `udm_receita_id` int(11) NOT NULL,
  `user_dia_momento_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL,
  `udm_porcoes` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_book`
--

DROP TABLE IF EXISTS `user_book`;
CREATE TABLE `user_book` (
  `user_book_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `user_book_desc` varchar(45) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_book_rec`
--

DROP TABLE IF EXISTS `user_book_rec`;
CREATE TABLE `user_book_rec` (
  `user_book_rec_id` int(11) NOT NULL,
  `ub_id` int(11) NOT NULL,
  `receita_receita_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_dia`
--

DROP TABLE IF EXISTS `user_dia`;
CREATE TABLE `user_dia` (
  `user_dia_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `user_dia_data` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_dia_macros`
--

DROP TABLE IF EXISTS `user_dia_macros`;
CREATE TABLE `user_dia_macros` (
  `user_dia_macros_id` int(11) NOT NULL,
  `user_dia_id` int(11) NOT NULL,
  `udm_kcal` float NOT NULL DEFAULT 0,
  `udm_prot` float NOT NULL DEFAULT 0,
  `udm_carb` float NOT NULL DEFAULT 0,
  `udm_gord` float NOT NULL DEFAULT 0,
  `udm_fibra` float NOT NULL DEFAULT 0,
  `udc_kcal` float NOT NULL,
  `udc_prot` float NOT NULL,
  `udc_carb` float NOT NULL,
  `udc_gord` float NOT NULL,
  `udc_fibra` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='								';

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_dia_momento`
--

DROP TABLE IF EXISTS `user_dia_momento`;
CREATE TABLE `user_dia_momento` (
  `user_dia_momento_id` int(11) NOT NULL,
  `user_dia_id` int(11) NOT NULL,
  `momento_id` int(11) NOT NULL,
  `momento_kcal` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_dia_mood`
--

DROP TABLE IF EXISTS `user_dia_mood`;
CREATE TABLE `user_dia_mood` (
  `user_dia_mood_id` int(11) NOT NULL,
  `user_dia_id` int(11) NOT NULL,
  `emocoes_feliz` tinyint(4) DEFAULT NULL,
  `emocoes_sensivel` tinyint(4) DEFAULT NULL,
  `emocoes_triste` tinyint(4) DEFAULT NULL,
  `emocoes_raiva` tinyint(4) DEFAULT NULL,
  `sono_0a3` tinyint(4) DEFAULT NULL,
  `sono_3a6` tinyint(4) DEFAULT NULL,
  `sono_6a9` tinyint(4) DEFAULT NULL,
  `sono_9oumais` tinyint(4) DEFAULT NULL,
  `vitalidade_ativo` tinyint(4) DEFAULT NULL,
  `vitalidade_alta` tinyint(4) DEFAULT NULL,
  `vitalidade_baixa` tinyint(4) DEFAULT NULL,
  `vitalidade_exaustao` tinyint(4) DEFAULT NULL,
  `banheiro_otimo` tinyint(4) DEFAULT NULL,
  `banheiro_normal` tinyint(4) DEFAULT NULL,
  `banheiro_prisaoventre` tinyint(4) DEFAULT NULL,
  `banheiro_diarreia` tinyint(4) DEFAULT NULL,
  `desejo_doce` tinyint(4) DEFAULT NULL,
  `desejo_salgado` tinyint(4) DEFAULT NULL,
  `desejo_carboidratos` tinyint(4) DEFAULT NULL,
  `digestao_otimo` tinyint(4) DEFAULT NULL,
  `digestao_inchaco` tinyint(4) DEFAULT NULL,
  `digestao_enjoo` tinyint(4) DEFAULT NULL,
  `digestao_comgases` tinyint(4) DEFAULT NULL,
  `pele_boa` tinyint(4) DEFAULT NULL,
  `pele_oleosa` tinyint(4) DEFAULT NULL,
  `pele_seca` tinyint(4) DEFAULT NULL,
  `pele_acne` tinyint(4) DEFAULT NULL,
  `mental_focado` tinyint(4) DEFAULT NULL,
  `mental_tranquilidade` tinyint(4) DEFAULT NULL,
  `mental_distracao` tinyint(4) DEFAULT NULL,
  `mental_estresse` tinyint(4) DEFAULT NULL,
  `motivacao_motivado` tinyint(4) DEFAULT NULL,
  `motivacao_desanimado` tinyint(4) DEFAULT NULL,
  `motivacao_produtivo` tinyint(4) DEFAULT NULL,
  `motivacao_preguica` tinyint(4) DEFAULT NULL,
  `peso_kg` float DEFAULT NULL,
  `exercicio_corrida` tinyint(4) DEFAULT NULL,
  `exercicio_academia` tinyint(4) DEFAULT NULL,
  `exercicio_bicicleta` tinyint(4) DEFAULT NULL,
  `exercicio_natacao` tinyint(4) DEFAULT NULL,
  `festa_bebidas` tinyint(4) DEFAULT NULL,
  `festa_fumo` tinyint(4) DEFAULT NULL,
  `festa_ressaca` tinyint(4) DEFAULT NULL,
  `festa_outrassubs` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_peso_historico`
--

DROP TABLE IF EXISTS `user_peso_historico`;
CREATE TABLE `user_peso_historico` (
  `user_peso_historico_id` int(11) NOT NULL,
  `usuario_usuario_id` int(11) NOT NULL,
  `uph_data` date NOT NULL,
  `uph_peso` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `user_rec_fav`
--

DROP TABLE IF EXISTS `user_rec_fav`;
CREATE TABLE `user_rec_fav` (
  `urf_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `receita_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE `usuario` (
  `usuario_id` int(11) NOT NULL,
  `usuario_email` varchar(45) COLLATE utf8_bin NOT NULL,
  `usuario_senha` varchar(45) COLLATE utf8_bin NOT NULL,
  `usuario_nome` varchar(45) COLLATE utf8_bin NOT NULL,
  `usuario_sobrenome` varchar(45) COLLATE utf8_bin NOT NULL,
  `usuario_tipo` int(11) NOT NULL,
  `usuario_token` varchar(12) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuario_configs_macros`
--

DROP TABLE IF EXISTS `usuario_configs_macros`;
CREATE TABLE `usuario_configs_macros` (
  `usuario_configs_macros_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `ucm_kcal` float NOT NULL,
  `ucm_carb` float NOT NULL,
  `ucm_prot` float NOT NULL,
  `ucm_gord` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuario_configs_mood`
--

DROP TABLE IF EXISTS `usuario_configs_mood`;
CREATE TABLE `usuario_configs_mood` (
  `usuario_configs_mood_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `um_emocoes` tinyint(4) NOT NULL DEFAULT 1,
  `um_sono` tinyint(4) NOT NULL DEFAULT 1,
  `um_vitalidade` tinyint(4) NOT NULL DEFAULT 1,
  `um_banheiro` tinyint(4) NOT NULL DEFAULT 1,
  `um_desejo` tinyint(4) NOT NULL DEFAULT 1,
  `um_digestao` tinyint(4) NOT NULL DEFAULT 1,
  `um_pele` tinyint(4) NOT NULL DEFAULT 1,
  `um_mental` tinyint(4) NOT NULL DEFAULT 1,
  `um_motivacao` tinyint(4) NOT NULL DEFAULT 1,
  `um_medicacao` tinyint(4) NOT NULL DEFAULT 1,
  `um_peso` tinyint(4) NOT NULL DEFAULT 1,
  `um_exercicio` tinyint(4) NOT NULL DEFAULT 1,
  `um_festa` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuario_configs_ref`
--

DROP TABLE IF EXISTS `usuario_configs_ref`;
CREATE TABLE `usuario_configs_ref` (
  `usuario_configs_geral_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `ucr_datanasc` date NOT NULL,
  `ucr_peso` float NOT NULL,
  `ucr_sexo` char(1) COLLATE utf8_bin NOT NULL,
  `ucr_is_active` char(1) COLLATE utf8_bin NOT NULL,
  `ucr_altura` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `view_receita`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `view_receita`;
CREATE TABLE `view_receita` (
`receita_id` int(11)
,`receita_nome` varchar(100)
,`receita_desc` text
,`receita_porcoes` int(11)
,`receita_tempo_preparo` time
,`rn_nivel` varchar(45)
,`momento` mediumtext
,`humidity_qtd` float
,`humidity_unit` varchar(45)
,`protein_qtd` float
,`protein_unit` varchar(45)
,`lipid_qtd` float
,`lipid_unit` varchar(45)
,`carbohydrate_qtd` float
,`carbohydrate_unit` varchar(45)
,`fiber_qtd` float
,`fiber_unit` varchar(45)
,`energy_kcal` float
,`energy_kj` float
,`receita_status` tinyint(4)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_ingredientes`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `v_ingredientes`;
CREATE TABLE `v_ingredientes` (
`ingredientes_id` int(11)
,`ingredientes_desc` varchar(100)
,`ingredientes_base_qtd` float
,`ingredientes_base_unity` varchar(45)
,`humidity_qtd` float
,`humidity_unit` varchar(45)
,`protein_qtd` float
,`protein_unit` varchar(45)
,`lipid_qtd` float
,`lipid_unit` varchar(45)
,`carbohydrate_qtd` float
,`carbohydrate_unit` varchar(45)
,`fiber_qtd` float
,`fiber_unit` varchar(45)
,`energy_kcal` float
,`energy_kj` float
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_receita_ingredientes`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `v_receita_ingredientes`;
CREATE TABLE `v_receita_ingredientes` (
`receita_id` int(11)
,`ingredientes_id` int(11)
,`ingredientes_desc` varchar(100)
,`receita_ingredientes_qtd` float
,`ingredientes_base_qtd` float
,`ingredientes_base_unity` varchar(45)
,`humidity_qtd` float
,`humidity_unit` varchar(45)
,`protein_qtd` float
,`protein_unit` varchar(45)
,`lipid_qtd` float
,`lipid_unit` varchar(45)
,`carbohydrate_qtd` float
,`carbohydrate_unit` varchar(45)
,`fiber_qtd` float
,`fiber_unit` varchar(45)
,`energy_kcal` float
,`energy_kj` float
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_userdia`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `v_userdia`;
CREATE TABLE `v_userdia` (
`usuario_id` int(11)
,`user_dia_data` date
,`udm_kcal` float
,`udm_carb` float
,`udm_prot` float
,`udm_fibra` float
,`udm_gord` float
,`udc_kcal` float
,`udc_carb` float
,`udc_prot` float
,`udc_fibra` float
,`udc_gord` float
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_userdiameal`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `v_userdiameal`;
CREATE TABLE `v_userdiameal` (
`user_dia_id` int(11)
,`usuario_id` int(11)
,`udm_receita_id` int(11)
,`user_dia_data` date
,`momento_id` int(11)
,`momento_desc` varchar(45)
,`receita_id` int(11)
,`receita_nome` varchar(100)
,`receita_kcal` float
,`momento_kcal` float
,`categorias_receita` mediumtext
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_userdiamood`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `v_userdiamood`;
CREATE TABLE `v_userdiamood` (
`user_dia_id` int(11)
,`usuario_id` int(11)
,`user_dia_data` date
,`emocoes_feliz` tinyint(4)
,`emocoes_sensivel` tinyint(4)
,`emocoes_triste` tinyint(4)
,`emocoes_raiva` tinyint(4)
,`sono_0a3` tinyint(4)
,`sono_3a6` tinyint(4)
,`sono_6a9` tinyint(4)
,`sono_9oumais` tinyint(4)
,`vitalidade_ativo` tinyint(4)
,`vitalidade_alta` tinyint(4)
,`vitalidade_baixa` tinyint(4)
,`vitalidade_exaustao` tinyint(4)
,`banheiro_otimo` tinyint(4)
,`banheiro_normal` tinyint(4)
,`banheiro_prisaoventre` tinyint(4)
,`banheiro_diarreia` tinyint(4)
,`desejo_doce` tinyint(4)
,`desejo_salgado` tinyint(4)
,`desejo_carboidratos` tinyint(4)
,`digestao_otimo` tinyint(4)
,`digestao_inchaco` tinyint(4)
,`digestao_enjoo` tinyint(4)
,`digestao_comgases` tinyint(4)
,`pele_boa` tinyint(4)
,`pele_oleosa` tinyint(4)
,`pele_seca` tinyint(4)
,`pele_acne` tinyint(4)
,`mental_focado` tinyint(4)
,`mental_tranquilidade` tinyint(4)
,`mental_distracao` tinyint(4)
,`mental_estresse` tinyint(4)
,`motivacao_motivado` tinyint(4)
,`motivacao_desanimado` tinyint(4)
,`motivacao_produtivo` tinyint(4)
,`motivacao_preguica` tinyint(4)
,`peso_kg` float
,`exercicio_corrida` tinyint(4)
,`exercicio_academia` tinyint(4)
,`exercicio_bicicleta` tinyint(4)
,`exercicio_natacao` tinyint(4)
,`festa_bebidas` tinyint(4)
,`festa_fumo` tinyint(4)
,`festa_ressaca` tinyint(4)
,`festa_outrassubs` tinyint(4)
);

-- --------------------------------------------------------

--
-- Estrutura para vista `view_receita`
--
DROP TABLE IF EXISTS `view_receita`;

DROP VIEW IF EXISTS `view_receita`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_receita`  AS SELECT `r`.`receita_id` AS `receita_id`, `r`.`receita_nome` AS `receita_nome`, `r`.`receita_desc` AS `receita_desc`, `r`.`receita_porcoes` AS `receita_porcoes`, `r`.`receita_tempo_preparo` AS `receita_tempo_preparo`, `rn`.`rn_nivel` AS `rn_nivel`, group_concat(`m`.`momento_desc` separator ' , ') AS `momento`, `rvn`.`humidity_qtd` AS `humidity_qtd`, `rvn`.`humidity_unit` AS `humidity_unit`, `rvn`.`protein_qtd` AS `protein_qtd`, `rvn`.`protein_unit` AS `protein_unit`, `rvn`.`lipid_qtd` AS `lipid_qtd`, `rvn`.`lipid_unit` AS `lipid_unit`, `rvn`.`carbohydrate_qtd` AS `carbohydrate_qtd`, `rvn`.`carbohydrate_unit` AS `carbohydrate_unit`, `rvn`.`fiber_qtd` AS `fiber_qtd`, `rvn`.`fiber_unit` AS `fiber_unit`, `rvn`.`energy_kcal` AS `energy_kcal`, `rvn`.`energy_kj` AS `energy_kj`, `r`.`receita_status` AS `receita_status` FROM ((((`receita` `r` join `receita_nivel` `rn` on(`rn`.`receita_nivel_id` = `r`.`nivel_receita_id`)) join `receita_val_nutricional` `rvn` on(`rvn`.`receita_id` = `r`.`receita_id`)) join `receita_momentos` `rm` on(`rm`.`receita_id` = `r`.`receita_id`)) join `momento` `m` on(`rm`.`momento_id` = `m`.`momento_id`)) GROUP BY `r`.`receita_id` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v_ingredientes`
--
DROP TABLE IF EXISTS `v_ingredientes`;

DROP VIEW IF EXISTS `v_ingredientes`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_ingredientes`  AS SELECT `i`.`ingredientes_id` AS `ingredientes_id`, `i`.`ingredientes_desc` AS `ingredientes_desc`, `i`.`ingredientes_base_qtd` AS `ingredientes_base_qtd`, `i`.`ingredientes_base_unity` AS `ingredientes_base_unity`, `ivn`.`humidity_qtd` AS `humidity_qtd`, `ivn`.`humidity_unit` AS `humidity_unit`, `ivn`.`protein_qtd` AS `protein_qtd`, `ivn`.`protein_unit` AS `protein_unit`, `ivn`.`lipid_qtd` AS `lipid_qtd`, `ivn`.`lipid_unit` AS `lipid_unit`, `ivn`.`carbohydrate_qtd` AS `carbohydrate_qtd`, `ivn`.`carbohydrate_unit` AS `carbohydrate_unit`, `ivn`.`fiber_qtd` AS `fiber_qtd`, `ivn`.`fiber_unit` AS `fiber_unit`, `ivn`.`energy_kcal` AS `energy_kcal`, `ivn`.`energy_kj` AS `energy_kj` FROM (`ingredientes` `i` join `ingrediente_val_nutricional` `ivn`) WHERE `ivn`.`ingrediente_id` = `i`.`ingredientes_id` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v_receita_ingredientes`
--
DROP TABLE IF EXISTS `v_receita_ingredientes`;

DROP VIEW IF EXISTS `v_receita_ingredientes`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_receita_ingredientes`  AS SELECT `ri`.`receita_id` AS `receita_id`, `ri`.`ingredientes_id` AS `ingredientes_id`, `i`.`ingredientes_desc` AS `ingredientes_desc`, `ri`.`receita_ingredientes_qtd` AS `receita_ingredientes_qtd`, `i`.`ingredientes_base_qtd` AS `ingredientes_base_qtd`, `i`.`ingredientes_base_unity` AS `ingredientes_base_unity`, `ivn`.`humidity_qtd` AS `humidity_qtd`, `ivn`.`humidity_unit` AS `humidity_unit`, `ivn`.`protein_qtd` AS `protein_qtd`, `ivn`.`protein_unit` AS `protein_unit`, `ivn`.`lipid_qtd` AS `lipid_qtd`, `ivn`.`lipid_unit` AS `lipid_unit`, `ivn`.`carbohydrate_qtd` AS `carbohydrate_qtd`, `ivn`.`carbohydrate_unit` AS `carbohydrate_unit`, `ivn`.`fiber_qtd` AS `fiber_qtd`, `ivn`.`fiber_unit` AS `fiber_unit`, `ivn`.`energy_kcal` AS `energy_kcal`, `ivn`.`energy_kj` AS `energy_kj` FROM ((`receita_ingredientes` `ri` join `ingredientes` `i`) join `ingrediente_val_nutricional` `ivn`) WHERE `ri`.`ingredientes_id` = `i`.`ingredientes_id` AND `ivn`.`ingrediente_id` = `i`.`ingredientes_id` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v_userdia`
--
DROP TABLE IF EXISTS `v_userdia`;

DROP VIEW IF EXISTS `v_userdia`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_userdia`  AS SELECT `ud`.`usuario_id` AS `usuario_id`, `ud`.`user_dia_data` AS `user_dia_data`, `udm`.`udm_kcal` AS `udm_kcal`, `udm`.`udm_carb` AS `udm_carb`, `udm`.`udm_prot` AS `udm_prot`, `udm`.`udm_fibra` AS `udm_fibra`, `udm`.`udm_gord` AS `udm_gord`, `udm`.`udc_kcal` AS `udc_kcal`, `udm`.`udc_carb` AS `udc_carb`, `udm`.`udc_prot` AS `udc_prot`, `udm`.`udc_fibra` AS `udc_fibra`, `udm`.`udc_gord` AS `udc_gord` FROM (`user_dia` `ud` join `user_dia_macros` `udm` on(`ud`.`user_dia_id` = `udm`.`user_dia_id`)) ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v_userdiameal`
--
DROP TABLE IF EXISTS `v_userdiameal`;

DROP VIEW IF EXISTS `v_userdiameal`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_userdiameal`  AS SELECT `ud`.`user_dia_id` AS `user_dia_id`, `ud`.`usuario_id` AS `usuario_id`, `udr`.`udm_receita_id` AS `udm_receita_id`, `ud`.`user_dia_data` AS `user_dia_data`, `m`.`momento_id` AS `momento_id`, `m`.`momento_desc` AS `momento_desc`, `r`.`receita_id` AS `receita_id`, `r`.`receita_nome` AS `receita_nome`, `rv`.`energy_kcal` AS `receita_kcal`, `udm`.`momento_kcal` AS `momento_kcal`, group_concat(`cr`.`categoria_r_nome` separator ', ') AS `categorias_receita` FROM (((((((`user_dia` `ud` join `user_dia_momento` `udm` on(`udm`.`user_dia_id` = `ud`.`user_dia_id`)) join `momento` `m` on(`m`.`momento_id` = `udm`.`momento_id`)) join `udm_receita` `udr` on(`udr`.`user_dia_momento_id` = `udm`.`user_dia_momento_id`)) join `receita` `r` on(`r`.`receita_id` = `udr`.`receita_id`)) join `receita_val_nutricional` `rv` on(`rv`.`receita_id` = `r`.`receita_id`)) join `receita_categorias` `c` on(`c`.`receita_id` = `r`.`receita_id`)) join `categoria_r` `cr` on(`cr`.`categoria_r_id` = `c`.`categoria_id`)) GROUP BY `udr`.`udm_receita_id` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v_userdiamood`
--
DROP TABLE IF EXISTS `v_userdiamood`;

DROP VIEW IF EXISTS `v_userdiamood`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_userdiamood`  AS SELECT `ud`.`user_dia_id` AS `user_dia_id`, `ud`.`usuario_id` AS `usuario_id`, `ud`.`user_dia_data` AS `user_dia_data`, `udm`.`emocoes_feliz` AS `emocoes_feliz`, `udm`.`emocoes_sensivel` AS `emocoes_sensivel`, `udm`.`emocoes_triste` AS `emocoes_triste`, `udm`.`emocoes_raiva` AS `emocoes_raiva`, `udm`.`sono_0a3` AS `sono_0a3`, `udm`.`sono_3a6` AS `sono_3a6`, `udm`.`sono_6a9` AS `sono_6a9`, `udm`.`sono_9oumais` AS `sono_9oumais`, `udm`.`vitalidade_ativo` AS `vitalidade_ativo`, `udm`.`vitalidade_alta` AS `vitalidade_alta`, `udm`.`vitalidade_baixa` AS `vitalidade_baixa`, `udm`.`vitalidade_exaustao` AS `vitalidade_exaustao`, `udm`.`banheiro_otimo` AS `banheiro_otimo`, `udm`.`banheiro_normal` AS `banheiro_normal`, `udm`.`banheiro_prisaoventre` AS `banheiro_prisaoventre`, `udm`.`banheiro_diarreia` AS `banheiro_diarreia`, `udm`.`desejo_doce` AS `desejo_doce`, `udm`.`desejo_salgado` AS `desejo_salgado`, `udm`.`desejo_carboidratos` AS `desejo_carboidratos`, `udm`.`digestao_otimo` AS `digestao_otimo`, `udm`.`digestao_inchaco` AS `digestao_inchaco`, `udm`.`digestao_enjoo` AS `digestao_enjoo`, `udm`.`digestao_comgases` AS `digestao_comgases`, `udm`.`pele_boa` AS `pele_boa`, `udm`.`pele_oleosa` AS `pele_oleosa`, `udm`.`pele_seca` AS `pele_seca`, `udm`.`pele_acne` AS `pele_acne`, `udm`.`mental_focado` AS `mental_focado`, `udm`.`mental_tranquilidade` AS `mental_tranquilidade`, `udm`.`mental_distracao` AS `mental_distracao`, `udm`.`mental_estresse` AS `mental_estresse`, `udm`.`motivacao_motivado` AS `motivacao_motivado`, `udm`.`motivacao_desanimado` AS `motivacao_desanimado`, `udm`.`motivacao_produtivo` AS `motivacao_produtivo`, `udm`.`motivacao_preguica` AS `motivacao_preguica`, `udm`.`peso_kg` AS `peso_kg`, `udm`.`exercicio_corrida` AS `exercicio_corrida`, `udm`.`exercicio_academia` AS `exercicio_academia`, `udm`.`exercicio_bicicleta` AS `exercicio_bicicleta`, `udm`.`exercicio_natacao` AS `exercicio_natacao`, `udm`.`festa_bebidas` AS `festa_bebidas`, `udm`.`festa_fumo` AS `festa_fumo`, `udm`.`festa_ressaca` AS `festa_ressaca`, `udm`.`festa_outrassubs` AS `festa_outrassubs` FROM (`user_dia_mood` `udm` join `user_dia` `ud` on(`ud`.`user_dia_id` = `udm`.`user_dia_id`)) ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `categoria_i`
--
ALTER TABLE `categoria_i`
  ADD PRIMARY KEY (`categoria_i_id`);

--
-- Índices para tabela `categoria_r`
--
ALTER TABLE `categoria_r`
  ADD PRIMARY KEY (`categoria_r_id`);

--
-- Índices para tabela `ingredientes`
--
ALTER TABLE `ingredientes`
  ADD PRIMARY KEY (`ingredientes_id`);

--
-- Índices para tabela `ingrediente_categorias`
--
ALTER TABLE `ingrediente_categorias`
  ADD PRIMARY KEY (`ingrediente_categorias_id`),
  ADD KEY `fk_ingrediente_categorias_ingredientes1_idx` (`ingredientes_id`),
  ADD KEY `fk_ingrediente_categorias_categoria_i1_idx` (`categoria_id`);

--
-- Índices para tabela `ingrediente_val_nutricional`
--
ALTER TABLE `ingrediente_val_nutricional`
  ADD PRIMARY KEY (`ingrediente_val_nutricional_id`),
  ADD KEY `fk_ingrediente_val_nutricional_ingredientes1_idx` (`ingrediente_id`);

--
-- Índices para tabela `momento`
--
ALTER TABLE `momento`
  ADD PRIMARY KEY (`momento_id`);

--
-- Índices para tabela `paciente_profissional`
--
ALTER TABLE `paciente_profissional`
  ADD PRIMARY KEY (`paciente_profissional_id`),
  ADD KEY `paciente_id_idx` (`paciente_id`),
  ADD KEY `profissional_id_idx` (`profissional_id`);

--
-- Índices para tabela `receita`
--
ALTER TABLE `receita`
  ADD PRIMARY KEY (`receita_id`),
  ADD KEY `fk_receita_usuario1_idx` (`usuario_id`),
  ADD KEY `fk_receita_receita_nivel1_idx` (`nivel_receita_id`);

--
-- Índices para tabela `receita_aval`
--
ALTER TABLE `receita_aval`
  ADD PRIMARY KEY (`receita_aval_id`),
  ADD KEY `fk_receita_aval_receita1_idx` (`receita_id`),
  ADD KEY `fk_receita_aval_usuario1_idx` (`usuario_id`);

--
-- Índices para tabela `receita_categorias`
--
ALTER TABLE `receita_categorias`
  ADD PRIMARY KEY (`receita_categorias_id`),
  ADD KEY `fk_receita_categorias_receita1_idx` (`receita_id`),
  ADD KEY `fk_receita_categorias_categoria_r1_idx` (`categoria_id`);

--
-- Índices para tabela `receita_imagens`
--
ALTER TABLE `receita_imagens`
  ADD PRIMARY KEY (`receita_imagens_id`),
  ADD KEY `fk_receita_imagens_receita1_idx` (`receita_receita_id`);

--
-- Índices para tabela `receita_ingredientes`
--
ALTER TABLE `receita_ingredientes`
  ADD PRIMARY KEY (`receita_ingredientes_id`),
  ADD KEY `fk_receita_ingredientes_receita1_idx` (`receita_id`),
  ADD KEY `fk_receita_ingredientes_ingredientes1_idx` (`ingredientes_id`);

--
-- Índices para tabela `receita_momentos`
--
ALTER TABLE `receita_momentos`
  ADD PRIMARY KEY (`receita_momentos_id`),
  ADD KEY `fk_receita_momentos_momento1_idx` (`momento_id`),
  ADD KEY `fk_receita_momentos_receita1_idx` (`receita_id`);

--
-- Índices para tabela `receita_nivel`
--
ALTER TABLE `receita_nivel`
  ADD PRIMARY KEY (`receita_nivel_id`);

--
-- Índices para tabela `receita_passos`
--
ALTER TABLE `receita_passos`
  ADD PRIMARY KEY (`receita_passos_id`),
  ADD KEY `fk_receita_passos_receita1_idx` (`receita_id`);

--
-- Índices para tabela `receita_val_nutricional`
--
ALTER TABLE `receita_val_nutricional`
  ADD PRIMARY KEY (`receita_val_nutricional_id`),
  ADD KEY `fk_receita_val_nutricional_receita1_idx` (`receita_id`);

--
-- Índices para tabela `udm_receita`
--
ALTER TABLE `udm_receita`
  ADD PRIMARY KEY (`udm_receita_id`),
  ADD KEY `fk_udm_receita_user_dia_momento1_idx` (`user_dia_momento_id`),
  ADD KEY `fk_udm_receita_receita1_idx` (`receita_id`);

--
-- Índices para tabela `user_book`
--
ALTER TABLE `user_book`
  ADD PRIMARY KEY (`user_book_id`),
  ADD KEY `fk_user_book_rec_usuario1_idx` (`usuario_id`);

--
-- Índices para tabela `user_book_rec`
--
ALTER TABLE `user_book_rec`
  ADD PRIMARY KEY (`user_book_rec_id`),
  ADD KEY `fk_user_book_rec_user_book1_idx` (`ub_id`),
  ADD KEY `fk_user_book_rec_receita1_idx` (`receita_receita_id`);

--
-- Índices para tabela `user_dia`
--
ALTER TABLE `user_dia`
  ADD PRIMARY KEY (`user_dia_id`),
  ADD KEY `fk_user_dia_usuario1_idx` (`usuario_id`);

--
-- Índices para tabela `user_dia_macros`
--
ALTER TABLE `user_dia_macros`
  ADD PRIMARY KEY (`user_dia_macros_id`),
  ADD KEY `fk_user_dia_macros_user_dia1_idx` (`user_dia_id`);

--
-- Índices para tabela `user_dia_momento`
--
ALTER TABLE `user_dia_momento`
  ADD PRIMARY KEY (`user_dia_momento_id`),
  ADD KEY `fk_user_dia_momento_momento1_idx` (`momento_id`),
  ADD KEY `fk_user_dia_momento_user_dia1_idx` (`user_dia_id`);

--
-- Índices para tabela `user_dia_mood`
--
ALTER TABLE `user_dia_mood`
  ADD PRIMARY KEY (`user_dia_mood_id`),
  ADD KEY `fk_user_dia_mood_user_dia1_idx` (`user_dia_id`);

--
-- Índices para tabela `user_peso_historico`
--
ALTER TABLE `user_peso_historico`
  ADD PRIMARY KEY (`user_peso_historico_id`),
  ADD KEY `fk_user_peso_historico_usuario1_idx` (`usuario_usuario_id`);

--
-- Índices para tabela `user_rec_fav`
--
ALTER TABLE `user_rec_fav`
  ADD PRIMARY KEY (`urf_id`),
  ADD KEY `fk_user_receitas_favoritas_usuario1_idx` (`usuario_id`),
  ADD KEY `fk_user_receitas_favoritas_receita1_idx` (`receita_id`);

--
-- Índices para tabela `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`usuario_id`),
  ADD UNIQUE KEY `usuario_token_UNIQUE` (`usuario_token`);

--
-- Índices para tabela `usuario_configs_macros`
--
ALTER TABLE `usuario_configs_macros`
  ADD PRIMARY KEY (`usuario_configs_macros_id`),
  ADD KEY `fk_usuario_configs_macros_usuario1_idx` (`usuario_id`);

--
-- Índices para tabela `usuario_configs_mood`
--
ALTER TABLE `usuario_configs_mood`
  ADD PRIMARY KEY (`usuario_configs_mood_id`),
  ADD KEY `fk_usuario_configs_mood_usuario1_idx` (`usuario_id`);

--
-- Índices para tabela `usuario_configs_ref`
--
ALTER TABLE `usuario_configs_ref`
  ADD PRIMARY KEY (`usuario_configs_geral_id`),
  ADD KEY `fk_usuario_configs_geral_usuario1_idx` (`usuario_id`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `categoria_i`
--
ALTER TABLE `categoria_i`
  MODIFY `categoria_i_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de tabela `categoria_r`
--
ALTER TABLE `categoria_r`
  MODIFY `categoria_r_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `ingredientes`
--
ALTER TABLE `ingredientes`
  MODIFY `ingredientes_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=598;

--
-- AUTO_INCREMENT de tabela `ingrediente_categorias`
--
ALTER TABLE `ingrediente_categorias`
  MODIFY `ingrediente_categorias_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=598;

--
-- AUTO_INCREMENT de tabela `ingrediente_val_nutricional`
--
ALTER TABLE `ingrediente_val_nutricional`
  MODIFY `ingrediente_val_nutricional_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=598;

--
-- AUTO_INCREMENT de tabela `momento`
--
ALTER TABLE `momento`
  MODIFY `momento_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `paciente_profissional`
--
ALTER TABLE `paciente_profissional`
  MODIFY `paciente_profissional_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita`
--
ALTER TABLE `receita`
  MODIFY `receita_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_aval`
--
ALTER TABLE `receita_aval`
  MODIFY `receita_aval_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_categorias`
--
ALTER TABLE `receita_categorias`
  MODIFY `receita_categorias_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_imagens`
--
ALTER TABLE `receita_imagens`
  MODIFY `receita_imagens_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_ingredientes`
--
ALTER TABLE `receita_ingredientes`
  MODIFY `receita_ingredientes_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_momentos`
--
ALTER TABLE `receita_momentos`
  MODIFY `receita_momentos_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_nivel`
--
ALTER TABLE `receita_nivel`
  MODIFY `receita_nivel_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_passos`
--
ALTER TABLE `receita_passos`
  MODIFY `receita_passos_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `receita_val_nutricional`
--
ALTER TABLE `receita_val_nutricional`
  MODIFY `receita_val_nutricional_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `udm_receita`
--
ALTER TABLE `udm_receita`
  MODIFY `udm_receita_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_book`
--
ALTER TABLE `user_book`
  MODIFY `user_book_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_book_rec`
--
ALTER TABLE `user_book_rec`
  MODIFY `user_book_rec_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_dia`
--
ALTER TABLE `user_dia`
  MODIFY `user_dia_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_dia_macros`
--
ALTER TABLE `user_dia_macros`
  MODIFY `user_dia_macros_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_dia_momento`
--
ALTER TABLE `user_dia_momento`
  MODIFY `user_dia_momento_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_dia_mood`
--
ALTER TABLE `user_dia_mood`
  MODIFY `user_dia_mood_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_peso_historico`
--
ALTER TABLE `user_peso_historico`
  MODIFY `user_peso_historico_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `user_rec_fav`
--
ALTER TABLE `user_rec_fav`
  MODIFY `urf_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `usuario`
--
ALTER TABLE `usuario`
  MODIFY `usuario_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `usuario_configs_macros`
--
ALTER TABLE `usuario_configs_macros`
  MODIFY `usuario_configs_macros_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `usuario_configs_mood`
--
ALTER TABLE `usuario_configs_mood`
  MODIFY `usuario_configs_mood_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `usuario_configs_ref`
--
ALTER TABLE `usuario_configs_ref`
  MODIFY `usuario_configs_geral_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `ingrediente_categorias`
--
ALTER TABLE `ingrediente_categorias`
  ADD CONSTRAINT `fk_ingrediente_categorias_categoria_i1` FOREIGN KEY (`categoria_id`) REFERENCES `categoria_i` (`categoria_i_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_ingrediente_categorias_ingredientes1` FOREIGN KEY (`ingredientes_id`) REFERENCES `ingredientes` (`ingredientes_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `ingrediente_val_nutricional`
--
ALTER TABLE `ingrediente_val_nutricional`
  ADD CONSTRAINT `fk_ingrediente_val_nutricional_ingredientes1` FOREIGN KEY (`ingrediente_id`) REFERENCES `ingredientes` (`ingredientes_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `paciente_profissional`
--
ALTER TABLE `paciente_profissional`
  ADD CONSTRAINT `paciente_id` FOREIGN KEY (`paciente_id`) REFERENCES `usuario` (`usuario_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `profissional_id` FOREIGN KEY (`profissional_id`) REFERENCES `usuario` (`usuario_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `receita_aval`
--
ALTER TABLE `receita_aval`
  ADD CONSTRAINT `fk_receita_aval_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_receita_aval_usuario1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`usuario_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `receita_categorias`
--
ALTER TABLE `receita_categorias`
  ADD CONSTRAINT `fk_receita_categorias_categoria_r1` FOREIGN KEY (`categoria_id`) REFERENCES `categoria_r` (`categoria_r_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_receita_categorias_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `receita_imagens`
--
ALTER TABLE `receita_imagens`
  ADD CONSTRAINT `fk_receita_imagens_receita1` FOREIGN KEY (`receita_receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `receita_ingredientes`
--
ALTER TABLE `receita_ingredientes`
  ADD CONSTRAINT `fk_receita_ingredientes_ingredientes1` FOREIGN KEY (`ingredientes_id`) REFERENCES `ingredientes` (`ingredientes_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_receita_ingredientes_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `receita_momentos`
--
ALTER TABLE `receita_momentos`
  ADD CONSTRAINT `fk_receita_momentos_momento1` FOREIGN KEY (`momento_id`) REFERENCES `momento` (`momento_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_receita_momentos_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `receita_passos`
--
ALTER TABLE `receita_passos`
  ADD CONSTRAINT `fk_receita_passos_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `receita_val_nutricional`
--
ALTER TABLE `receita_val_nutricional`
  ADD CONSTRAINT `fk_receita_val_nutricional_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `udm_receita`
--
ALTER TABLE `udm_receita`
  ADD CONSTRAINT `fk_udm_receita_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_udm_receita_user_dia_momento1` FOREIGN KEY (`user_dia_momento_id`) REFERENCES `user_dia_momento` (`user_dia_momento_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `user_book`
--
ALTER TABLE `user_book`
  ADD CONSTRAINT `fk_user_book_rec_usuario1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`usuario_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `user_book_rec`
--
ALTER TABLE `user_book_rec`
  ADD CONSTRAINT `fk_user_book_rec_receita1` FOREIGN KEY (`receita_receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_book_rec_user_book1` FOREIGN KEY (`ub_id`) REFERENCES `user_book` (`user_book_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `user_dia_momento`
--
ALTER TABLE `user_dia_momento`
  ADD CONSTRAINT `fk_user_dia_momento_momento1` FOREIGN KEY (`momento_id`) REFERENCES `momento` (`momento_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_dia_momento_user_dia1` FOREIGN KEY (`user_dia_id`) REFERENCES `user_dia` (`user_dia_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `user_dia_mood`
--
ALTER TABLE `user_dia_mood`
  ADD CONSTRAINT `fk_user_dia_mood_user_dia1` FOREIGN KEY (`user_dia_id`) REFERENCES `user_dia` (`user_dia_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `user_rec_fav`
--
ALTER TABLE `user_rec_fav`
  ADD CONSTRAINT `fk_user_receitas_favoritas_receita1` FOREIGN KEY (`receita_id`) REFERENCES `receita` (`receita_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_receitas_favoritas_usuario1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`usuario_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

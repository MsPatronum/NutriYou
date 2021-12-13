<?php 
//script de configurações básicas do php
define('url','http://localhost/NutriYou/API'); //url raiz do site
define('raiz',$_SERVER['DOCUMENT_ROOT'].'/NutriYou/API');
define('img_raiz', $_SERVER['DOCUMENT_ROOT'].'/NutriYou/images/');
define('conexao',raiz.'/includes/conexao.php');// conexao padrão do site
define('funcoes',raiz.'/includes/funcoes.php'); // arquivo de funcoes
date_default_timezone_set("America/Sao_Paulo");
?>
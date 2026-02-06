<?php
header("Access-Control-Allow-Origin: *"); 
date_default_timezone_set('America/Sao_Paulo');
header("Server: nginx");

function conectar_bd() {
    
	$endereco = "localhost"; // Substitua "localhost" pelo host do seu banco de dados
    $dbusuario = "gruposol_xuikiller2025"; // Substitua "seu_usuario" pelo seu usuário do banco de dados
    $dbsenha = "@XuiKiller2025"; // Substitua "sua_senha" pela sua senha do banco de dados
	$banco = "gruposol_xuikiller2025"; // Substitua "seu_banco_de_dados" pelo nome do seu banco de dados

    try {
        $conexao = new PDO("mysql:host=$endereco;dbname=$banco", $dbusuario, $dbsenha);
        $conexao->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $conexao;
    } catch(PDOException $e) {

        return null;
    }
}
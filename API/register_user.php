<?php
include("config.php");

include(conexao);
include(funcoes);

$keys=array('nome', 'sobrenome', 'email', 'senha', 'tipo', 'peso', 'sexo', 'data_nasc', 'is_active', 'altura');

//
/*for ($i = 0; $i < count($keys); $i++){
	if(!isset($_POST[$keys[$i]]))
	 {
		  $response['error'] = true;
			$response['message'] = 'Required Filed Missed';
			echo json_encode($response);
		  return;
	 }

}

$senha = $_POST['senha'];
$email = $_POST['email'];
$nome = $_POST['nome'];
$sobrenome = $_POST['sobrenome'];
$tipo = $_POST['tipo'];
$peso = $_POST['peso'];
$sexo = $_POST['sexo'];
$data_nasc = $_POST['data_nasc'];
$is_active = $_POST['is_active'];
$altura = $_POST['altura'];
$token = generate_random_string(12)*/

// DADOS PARA TESTE
$senha = '123456';
$email = 'nicoleeguido@hotmail.com';
$nome = 'Nicole';
$sobrenome = 'Guido Medico';
$tipo = '2';
$peso = 78.2;
$sexo = 'F';
$data_nasc = '2000-07-20';
$is_active = 0;
$altura = 1.66;
$token = generate_random_string(12);
//FIM DOS DADOS PARA TESTE

//checking if the user is already exist with this username or email
//as the email and username should be unique for every user
$stmt = $mysqli->prepare("SELECT usuario_id FROM usuario WHERE usuario_email = ? ");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

//if the user already exist in the database
if($stmt->num_rows > 0){
	$response['error'] = true;
	$response['message'] = 'Usuario ja registrado';
	$stmt->close();

}else{

	//if user is new creating an insert query
	$stmt = $mysqli->prepare("CALL create_user(?,?,?,?,?,?,?,?,?,?,?, @resposta)");
	$stmt->bind_param("sssssssssss",  $nome, $sobrenome, $email, $senha, $tipo, $token, $is_active, $peso, $altura, $sexo, $data_nasc);

	//if the user is successfully added to the database
	if($stmt->execute()){

		//fetching the user back
		$stmt = $mysqli->prepare("SELECT * FROM usuario WHERE usuario_email = ?");
		$stmt->bind_param("s",$email);
		$stmt->execute();
		$stmt->bind_result( $id,$email,$senha, $nome,$sobrenome,$tipo, $token );
		$stmt->fetch();

		$user = array(
			'id' => $id,
			'nome' => $nome,
			'sobrenome' => $sobrenome,
			'email' => $email,
			'tipo' => $tipo,
			'token' => $token
		);

		$stmt->close();

		//adding the user data in response
		$response['error'] = false;
		$response['message'] = 'Usuario registrado com sucesso!';
		$response['data'] = $user;

	}else{
		$response['error'] = true;
		$response['message'] = 'Erro na criação do usuario.';
		$stmt->close();
	}

}
echo json_encode($response);


?>
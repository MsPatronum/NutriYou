<?php
include("config.php");

include(conexao);
include(funcoes);

$keys=array('nome', 'sobrenome', 'email', 'password', 'tipo');

//$keys=array('name','mobile','password','type');
/*for ($i = 0; $i < count($keys); $i++){
	if(!isset($_POST[$keys[$i]]))
	 {
		  $response['error'] = true;
			$response['message'] = 'Required Filed Missed';
			echo json_encode($response);
		  return;
	 }

}

$password = $_POST['password'];
$email = $_POST['email'];
$nome = $_POST['nome'];
$sobrenome = $_POST['sobrenome'];
$tipo = $_POST['tipo'];*/

$senha = '123456';
$email = 'nicoleeguido@gmail.com';
$nome = 'Nicole';
$sobrenome = 'Guido';
$tipo = '1';
$token = generate_random_string(12);


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
						$stmt = $mysqli->prepare("INSERT INTO usuario ( usuario_nome, usuario_sobrenome, usuario_email, usuario_senha, usuario_tipo, usuario_token) VALUES (?,?,?,?,?,?)");
						$stmt->bind_param("ssssss",  $nome, $sobrenome, $email, $senha, $tipo, $token);

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
								'senha' => $senha,
								'tipo' => $tipo,
								'token' => $token

							);

							$stmt->close();

							//adding the user data in response
							$response['error'] = false;
							$response['message'] = 'Usuario registrado com sucesso!';
							$response['data'] = $user;

						}

					}
					echo json_encode($response);


?>
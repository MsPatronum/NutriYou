<?php
include("config.php");

include(conexao);


$keys=array('email','senha');

/*for ($i = 0; $i < count($keys); $i++){
	if(!isset($_POST[$keys[$i]]))

	 {
		  $response['error'] = true;
			$response['message'] = 'Required Filed Missed';
			echo json_encode($response);
		  return;
	 }

}
$email=$_POST['email'];
$senha=$_POST['senha'];*/

$email='nicoleeguido@hotmail.com';
$senha='123456';

$stmt = $mysqli->prepare("SELECT * FROM usuario WHERE usuario_email = ? AND usuario_senha = ?");
					$stmt->bind_param("ss", $email, $senha);
					$stmt->execute();
					$stmt->store_result();
					if($stmt->num_rows > 0){

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
							$response['error'] = false;
							$response['message'] = 'Login realizado com sucesso';
							$response['data'] = $user;
					}else
					{
						$response['error'] = true;
						$response['message'] = 'Nome de usuario ou senha invalidos.';
						$stmt->close();

					}
					echo json_encode($response);

?>
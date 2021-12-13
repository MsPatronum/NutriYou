<?php 

    include("../config.php");
    include(conexao);

    $keys=array('receita_id', 'ikvList');
    
    for ($i = 0; $i < count($keys); $i++){
        if(!isset($obj[$keys[$i]]))
         {
              $response['error'] = true;
                $response['message'] = 'Required Filed Missed';
                echo json_encode($response);
              return;
         }
    
    }

    $ikvList = $obj['ikvList'];
    $receita_id = $obj['receita_id'];

    try {
        foreach($ikvList as $imgKeyValues){
            foreach($imgKeyValues as $ikv){
                $fn = $ikv['fn'];
                $decoded = base64_decode($ikv['encoded']);

                $img = "recipepics/".$fn;
                
                $InsertQuery = "INSERT INTO receita_imagens (receita_receita_id, receita_imagens_path) value ($receita_id, '$img')";
                $executa=$mysqli->query($InsertQuery);
                $error=$mysqli->error;

                file_put_contents(img_raiz."/recipepics/".$fn, $decoded);
            }
        }

        $update = "UPDATE receita set receita_status = 1 where receita_id = $receita_id";
        $executa=$mysqli->query($update);
        $error=$mysqli->error;

    } catch(Exception $e) {
        echo $e->getMessage();
    }

?>
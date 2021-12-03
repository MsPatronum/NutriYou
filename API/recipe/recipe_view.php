<?php

    include("../config.php");

    include(conexao);
    include(funcoes);
    
    /*$keys=array('receita_id');
    
    for ($i = 0; $i < count($keys); $i++){
        if(!isset($obj[$keys[$i]]))
         {
              $response['error'] = true;
                $response['message'] = 'Required Filed Missed';
                $response['cod'] = 4;
                echo json_encode($response);
              return;
         }
    
    }
 
    // Populate ID from JSON $obj array and store into $ID variable.
    $receita_id = $obj['receita_id'];*/

    $receita_id = 1;
 
    //Fetching the selected record as per ID.
    $receita_detalhes = $mysqli->prepare("
        SELECT 
            v.receita_id, v.receita_nome, 
            v.receita_desc, v.receita_tempo_preparo, 
            v.rn_nivel, v.momento, 
            v.humidity_qtd, v.humidity_unit,
            v.protein_qtd,v.protein_unit, 
            v.lipid_qtd, v.lipid_unit,
            v.carbohydrate_qtd, v.carbohydrate_unit, 
            v.fiber_qtd, v.fiber_unit,
            v.energy_kcal, v.energy_kj 
        FROM 
            view_receita v 
        WHERE
           v.receita_id = ? ");
    $receita_detalhes->bind_param("s", $receita_id);
    
    //Se executar
    if($receita_detalhes->execute()){
        //guardar resultado
        $receita_detalhes->store_result();
        //verificando o número de linhas
        if($receita_detalhes->num_rows == 1){
            //se o número de linhas for 1, então guardar os resultados em variáveis
            $receita_detalhes->bind_result($receita_id,$receita_nome,$receita_desc,$receita_tempo_preparo,$rn_nivel,$momento,$humidity_qtd,$humidity_unit,$protein_qtd,$protein_unit,
                               $lipid_qtd,$lipid_unit,$carbohydrate_qtd,$carbohydrate_unit,$fiber_qtd,$fiber_unit,$energy_kcal,$energy_kj);
            
            $receita_detalhes->fetch();
            //adicionando as informações da receita em um array
            $info_receita = array(
                'receita_id'=>$receita_id,
                'receita_nome'=>$receita_nome,
                'receita_desc'=>$receita_desc,
                'receita_tempo_preparo'=>$receita_tempo_preparo,
                'rn_nivel'=>$rn_nivel,
                'momento'=>$momento,
                'humidity_qtd'=>$humidity_qtd,
                'humidity_unit'=>$humidity_unit,
                'protein_qtd'=>$protein_qtd,
                'protein_unit'=>$protein_unit,
                'lipid_qtd'=>$lipid_qtd,
                'lipid_unit'=>$lipid_unit,
                'carbohydrate_qtd'=>$carbohydrate_qtd,
                'carbohydrate_unit'=>$carbohydrate_unit,
                'fiber_qtd'=>$fiber_qtd,
                'fiber_unit'=>$fiber_unit,
                'energy_kcal'=>$energy_kcal,
                'energy_kj'=>$energy_kj
            );

            //preparando query dos passos
            $receita_passos = $mysqli->prepare("SELECT p.rp_numero, p.rp_desc from receita_passos p where p.receita_id = ?");
            $receita_passos->bind_param("s", $receita_id);
            //se a query foi executada com sucesso

            if ($receita_passos->execute()) {
                $receita_passos->bind_result($rp_numero, $rp_desc);
                $receita_passos->store_result();
                if($receita_passos->num_rows > 0){
                    //colocando cada linha em um array
                    $receita_passos->execute();
                    $result = $receita_passos->get_result();
                    while ($row = $result->fetch_assoc()) {
                        $passos[] = array(
                            'rp_numero'=>$rp_numero,
                            'rp_desc'=>$rp_desc
                        );
                    }
                    $receita_ingredientes = $mysqli->prepare("
                        SELECT 
                            v.receita_id, 
                            v.ingredientes_id, 
                            v.ingredientes_desc, 
                            v.receita_ingredientes_qtd,
                            v.ingredientes_base_qtd,
                            v.ingredientes_base_unity
                        FROM 
                            v_receita_ingredientes v 
                        where 
                            v.receita_id = ?");
                    $receita_ingredientes->bind_param("s", $receita_id);
                    if ($receita_ingredientes->execute()) {
                        $receita_ingredientes->bind_result(
                            $receita_id, 
                            $ingredientes_id, 
                            $ingredientes_desc, 
                            $receita_ingredientes_qtd, 
                            $ingredientes_base_qtd,
                            $ingredientes_base_unity);

                        $receita_ingredientes->store_result();
                        //verificando o número de linhas
                        if($receita_ingredientes->num_rows >= 1){
                            //colocando cada linha em um array
                            $receita_ingredientes->execute();
                            $result = $receita_ingredientes->get_result();
                            while ($row = $result->fetch_assoc()) {
                                $ingredientes[] = array(
                                    'receita_id' => $receita_id,
                                    'ingredientes_id' => $ingredientes_id,
                                    'ingredientes_desc' => $ingredientes_desc,
                                    'receita_ingredientes_qtd' => $receita_ingredientes_qtd,
                                    'ingredientes_base_qtd' => $ingredientes_base_qtd,
                                    'ingredientes_base_unity' => $ingredientes_base_unity                       
                                );
                            }
                            $receita_ingredientes->close();
                        }
                    }
                }else{
                    $response['error'] = true;
                    $response['cod'] = 3;
                    $response['message'] = 'Erro no retorno dos ingredientes';
                    $receita_passos->close();
                }
            }else{
                $response['error'] = true;
                $response['cod'] = 3;
                $response['message'] = 'Erro no retorno dos passos';
                $receita_passos->close();
            }
            $response['error'] = false;
            $response['cod'] = 1;
            $response['message'] = 'Receitas retornadas com sucesso.';
            //enviando a resposta
            $response['info_receita'] = $info_receita;
            $response['passos'] = $passos;
            $response['ingredientes'] = $ingredientes;
            $receita_detalhes->close();
        }else{
            $response['error'] = false;
            $response['cod'] = 2;
            $response['message'] = 'Nao existe nada registrado aqui.';
            $response['data'] = null;
        }
    }else{
        $response['error'] = true;
        $response['cod'] = 3;
            $response['message'] = 'Erro no retorno da data';
            $receita_detalhes->close();
    }

    echo json_encode($response);

 ?>
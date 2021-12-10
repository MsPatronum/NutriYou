<?php 
$return["error"] = false;
$return["msg"] = "";
//array to return

if(isset($_POST["image"])){
    $base64_string = $_POST["image"];
    $outputfile = "uploads/image.jpg" ;
    //save as image.jpg in uploads/ folder

    $filehandler = fopen($outputfile, 'wb' ); 
    //file open with "w" mode treat as text file
    //file open with "wb" mode treat as binary file
    
    fwrite($filehandler, base64_decode($base64_string));
    // we could add validation here with ensuring count($data)>1

    // clean up the file resource
    fclose($filehandler); 
}else{
    $return["error"] = true;
    $return["msg"] =  "No image is submited.";
}

header('Content-Type: application/json');
// tell browser that its a json data
echo json_encode($return);
//converting array to JSON string
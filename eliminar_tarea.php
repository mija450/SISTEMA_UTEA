<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

if (isset($_GET['id'])) {
    $id = intval($_GET['id']);
    // Ajusta el campo 'idTarea' según tu tabla
    $sql = "DELETE FROM tareas WHERE idTarea = $id";
    
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "error" => $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "error" => "ID no especificado"]);
}

$conn->close();
?>

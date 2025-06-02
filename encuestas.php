<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Consultar las encuestas
$sql = "SELECT id, titulo, descripcion, fecha FROM encuestas";
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    // Retornar respuesta exitosa con las encuestas
    echo json_encode(array("success" => true, "data" => $data));
} else {
    // Retornar respuesta si no hay encuestas disponibles
    echo json_encode(array("success" => false, "message" => "No hay encuestas disponibles"));
}

// Cerrar la conexión
$conn->close();
?>
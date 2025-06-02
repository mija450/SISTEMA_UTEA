<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Consultar los recursos
$sql = "SELECT id, nombre, descripcion, categoria, enlace AS link, fecha_actualizacion, notas FROM recursos";
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    // Retornar respuesta exitosa con los recursos
    echo json_encode(array("success" => true, "data" => $data));
} else {
    // Retornar respuesta si no hay recursos disponibles
    echo json_encode(array("success" => false, "message" => "No hay recursos disponibles"));
}

// Cerrar la conexión
$conn->close();
?>
<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php'; // Asegúrate de que este archivo tenga la conexión correcta a la base de datos

// Consultar las categorías
$sql = "SELECT id, nombre, descripcion FROM categoria_biblioteca";
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    // Retornar respuesta exitosa con las categorías
    echo json_encode(array("success" => true, "data" => $data));
} else {
    // Retornar respuesta si no hay categorías disponibles
    echo json_encode(array("success" => false, "message" => "No hay categorías disponibles"));
}

// Cerrar la conexión
$conn->close();
?>
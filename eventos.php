<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Consulta para obtener todos los eventos
$sql = "SELECT id, titulo, descripcion, fecha, hora, lugar FROM Eventos";
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(array("success" => true, "data" => $data));
} else {
    echo json_encode(array("success" => false, "message" => "No hay eventos disponibles"));
}

$conn->close();
?>
<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Ajusta si quieres más o menos campos
$sql = "SELECT id, titulo, subtitulo FROM aprendizaje";
$result = $conn->query($sql);

$data = array();
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(["success" => true, "data" => $data], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode(["success" => false, "message" => "No hay datos disponibles"], JSON_UNESCAPED_UNICODE);
}

$conn->close();
?>

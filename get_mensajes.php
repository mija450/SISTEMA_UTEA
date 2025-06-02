<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Verifica que se use el método GET antes de incluir la conexión
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405); // Método no permitido
    echo json_encode(array("success" => false, "message" => "Método no soportado"));
    exit;
}

include 'connection.php';

// Preparar la consulta SQL para obtener los mensajes
$stmt = $conn->prepare("SELECT m.idMensaje, m.contenido, m.fechaEnvio, m.remitente, u.nombre AS remitente_nombre 
                         FROM Mensaje m 
                         LEFT JOIN Usuario u ON m.remitente = u.idUsuario 
                         ORDER BY m.fechaEnvio DESC");

if (!$stmt) {
    http_response_code(500); // Error interno del servidor
    echo json_encode(array("success" => false, "message" => "Error en la preparación de la consulta: " . $conn->error));
    exit;
}

$stmt->execute();
$result = $stmt->get_result();

$mensajes = array();
while ($row = $result->fetch_assoc()) {
    $mensajes[] = $row;
}

http_response_code(200); // Éxito
echo json_encode(array("success" => true, "data" => $mensajes));

$stmt->close();
$conn->close();
?>

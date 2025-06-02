<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// para peticiones pre-flight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'connection.php';   // Asegúrate de que apunta a tu archivo de conexión

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Método no soportado"]);
    exit;
}

// Leer el cuerpo JSON
$body = json_decode(file_get_contents("php://input"), true);
$id = isset($body['id']) ? intval($body['id']) : 0;

// Validar ID
if ($id === 0) {
    echo json_encode([
        "success" => false,
        "message" => "ID no especificado o inválido"
    ]);
    exit;
}

// Ejecutar DELETE
$sql = "DELETE FROM Tutor WHERE idTutor = ?";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Error al preparar la consulta"
    ]);
    exit;
}

$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Tutor eliminado"]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Error al eliminar: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
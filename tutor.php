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

include 'connection.php';   // ➜ asegúrate de que apunta a tu archivo de conexión

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Método no soportado"]);
    exit;
}

/* ---------- 1. Leer el cuerpo JSON ---------- */
$body = json_decode(file_get_contents("php://input"), true);
$id          = isset($body['id'])          ? intval($body['id'])          : 0;
$titulo      = isset($body['titulo'])      ? trim($body['titulo'])        : '';
$fecha       = isset($body['fecha'])       ? trim($body['fecha'])         : '';
$hora        = isset($body['hora'])        ? trim($body['hora'])          : '';
$descripcion = isset($body['descripcion']) ? trim($body['descripcion'])   : null; // opcional

/* ---------- 2. Validar datos mínimos ---------- */
if ($id === 0 || $titulo === '' || $fecha === '' || $hora === '') {
    echo json_encode([
        "success" => false,
        "message" => "Datos incompletos (id, titulo, fecha u hora faltan)"
    ]);
    exit;
}

/* ---------- 3. Preparar y ejecutar UPDATE ---------- */
$sql  = "UPDATE Actividades 
         SET titulo = ?, fecha = ?, hora = ?, descripcion = ?
         WHERE id = ?";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Error al preparar la consulta"
    ]);
    exit;
}

$stmt->bind_param("ssssi", $titulo, $fecha, $hora, $descripcion, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Actividad actualizada"]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Error al actualizar: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>

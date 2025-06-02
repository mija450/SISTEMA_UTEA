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
$titulo = isset($body['titulo']) ? $body['titulo'] : '';
$fecha = isset($body['fecha']) ? $body['fecha'] : '';
$hora = isset($body['hora']) ? $body['hora'] : '';
$descripcion = isset($body['descripcion']) ? $body['descripcion'] : '';

/* ---------- 2. Validar datos ---------- */
if (empty($titulo) || empty($fecha) || empty($hora)) {
    echo json_encode([
        "success" => false,
        "message" => "Faltan datos obligatorios (titulo, fecha, hora)"
    ]);
    exit;
}

/* ---------- 3. Preparar la consulta para insertar la nueva actividad ---------- */
$sql = "INSERT INTO Actividades (titulo, fecha, hora, descripcion) VALUES (?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Error al preparar la consulta"
    ]);
    exit;
}

$stmt->bind_param("ssss", $titulo, $fecha, $hora, $descripcion);

/* ---------- 4. Ejecutar la consulta ---------- */
if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Actividad agregada correctamente"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Error al agregar la actividad: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>

<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
    // Si es una solicitud OPTIONS, simplemente retorna
    exit;
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Validar que se reciban todos los parámetros
    if (!isset($_POST['nombre'], $_POST['fecha'], $_POST['hora'], $_POST['detalles'])) {
        echo json_encode(["success" => false, "error" => "Datos incompletos"]);
        exit;
    }

    $nombre = $_POST['nombre'];
    $fecha = $_POST['fecha'];
    $hora = $_POST['hora'];
    $detalles = $_POST['detalles'];

    // Validar formato de fecha y hora
    if (!DateTime::createFromFormat('Y-m-d', $fecha) || !DateTime::createFromFormat('H:i:s', $hora)) {
        echo json_encode(["success" => false, "error" => "Formato de fecha o hora inválido"]);
        exit;
    }

    // Usar prepared statement para mayor seguridad
    $stmt = $conn->prepare("INSERT INTO anuncios (nombre, fecha, hora, detalles) VALUES (?, ?, ?, ?)");
    
    if (!$stmt) {
        echo json_encode(["success" => false, "error" => $conn->error]);
        exit;
    }

    $stmt->bind_param("ssss", $nombre, $fecha, $hora, $detalles);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Anuncio creado con éxito"]);
    } else {
        echo json_encode(["success" => false, "error" => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Método no soportado"]);
}
?>
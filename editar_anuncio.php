<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include 'connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $id = isset($_POST['id']) ? $_POST['id'] : '';
    $nombre = isset($_POST['nombre']) ? $_POST['nombre'] : '';
    $fecha = isset($_POST['fecha']) ? $_POST['fecha'] : '';
    $hora = isset($_POST['hora']) ? $_POST['hora'] : '';
    $detalles = isset($_POST['detalles']) ? $_POST['detalles'] : '';

    // Debugging: Mostrar datos recibidos
    error_log("ID: $id, Nombre: $nombre, Fecha: $fecha, Hora: $hora, Detalles: $detalles");

    if (empty($id) || empty($nombre) || empty($fecha) || empty($hora) || empty($detalles)) {
        echo json_encode(["success" => false, "error" => "Datos incompletos"]);
        exit;
    }

    $sql = "UPDATE anuncios SET nombre = ?, fecha = ?, hora = ?, detalles = ? WHERE id = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "error" => "Error en la preparación de la consulta: " . $conn->error]);
        exit;
    }
    $stmt->bind_param("ssssi", $nombre, $fecha, $hora, $detalles, $id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Anuncio actualizado con éxito"]);
    } else {
        echo json_encode(["success" => false, "error" => "Error al actualizar anuncio"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "error" => "Método no soportado"]);
}
?>
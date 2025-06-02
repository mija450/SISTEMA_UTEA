<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

// Verifica que sea POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Recuperar campos
    $id = isset($_POST['id']) ? $_POST['id'] : '';
    $titulo = isset($_POST['titulo']) ? $_POST['titulo'] : '';
    $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : '';
    $fecha = isset($_POST['fecha']) ? $_POST['fecha'] : '';
    $hora = isset($_POST['hora']) ? $_POST['hora'] : '';
    $lugar = isset($_POST['lugar']) ? $_POST['lugar'] : '';

    // Validar que vengan
    if (empty($id) || empty($titulo) || empty($descripcion) || empty($fecha) || empty($hora) || empty($lugar)) {
        echo json_encode([
            "success" => false,
            "error" => "Datos de texto incompletos"
        ]);
        exit;
    }

    // Preparar la consulta de actualización
    $sql = "UPDATE Eventos SET 
                titulo = '$titulo', 
                descripcion = '$descripcion', 
                fecha = '$fecha', 
                hora = '$hora', 
                lugar = '$lugar' 
            WHERE id = $id";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Evento actualizado correctamente"]);
    } else {
        echo json_encode([
            "success" => false,
            "error" => "Error al actualizar en la BD: " . $conn->error
        ]);
    }

    $conn->close();
} else {
    echo json_encode([
        "success" => false,
        "error" => "Método no soportado"
    ]);
}
?>
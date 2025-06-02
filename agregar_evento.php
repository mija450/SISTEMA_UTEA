<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Obtenemos los datos desde el POST
$titulo = $_POST['titulo'] ?? '';
$descripcion = $_POST['descripcion'] ?? '';
$fecha = $_POST['fecha'] ?? '';
$hora = $_POST['hora'] ?? '';
$lugar = $_POST['lugar'] ?? '';

// Validar que todos los campos requeridos estén presentes
if (empty($titulo) || empty($descripcion) || empty($fecha) || empty($hora) || empty($lugar)) {
    echo json_encode(["success" => false, "message" => "Todos los campos son obligatorios"]);
    exit;
}

// Insertamos en la tabla 'Eventos'
$sql = "INSERT INTO Eventos (titulo, descripcion, fecha, hora, lugar)
        VALUES ('$titulo', '$descripcion', '$fecha', '$hora', '$lugar')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Evento agregado correctamente"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al agregar evento: " . $conn->error]);
}

$conn->close();
?>
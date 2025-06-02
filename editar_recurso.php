<?php
header('Content-Type: application/json');

// Incluir el archivo de conexión
require 'connection.php';

// Verifica que sea PUT
parse_str(file_get_contents("php://input"), $_PUT);

// Recuperar campos
$id = isset($_PUT['id']) ? $_PUT['id'] : '';
$nombre = isset($_PUT['nombre']) ? $_PUT['nombre'] : '';
$link = isset($_PUT['link']) ? $_PUT['link'] : '';

// Validar que todos los campos estén presentes
if (empty($id) || empty($nombre) || empty($link)) {
    echo json_encode(['success' => false, 'message' => 'Todos los campos son requeridos']);
    exit;
}

// Preparar la consulta de actualización
$sql = "UPDATE Recursos SET titulo = ?, enlace = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssi", $nombre, $link, $id);

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Error en la actualización: ' . $stmt->error]);
}

// Cerrar la conexión
$stmt->close();
$conn->close();
?>
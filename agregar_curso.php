<?php
header('Content-Type: application/json');
include 'conexion.php';

$nombre = $_POST['nombre'] ?? '';
$descripcion = $_POST['descripcion'] ?? '';
$fecha_inicio = $_POST['fecha_inicio'] ?? '';
$fecha_fin = $_POST['fecha_fin'] ?? '';
$docente = $_POST['docente'] ?? '';

if (empty($nombre) || empty($fecha_inicio) || empty($fecha_fin) || empty($docente)) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos obligatorios']);
    exit;
}

$stmt = $conn->prepare("INSERT INTO Curso (nombre, descripcion, fecha_inicio, fecha_fin, docente) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param('sssss', $nombre, $descripcion, $fecha_inicio, $fecha_fin, $docente);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Curso agregado correctamente']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al agregar curso: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

<?php
header('Content-Type: application/json');
include 'conexion.php';

$id = $_POST['id'] ?? '';
$nombre = $_POST['nombre'] ?? '';
$descripcion = $_POST['descripcion'] ?? '';
$fecha_inicio = $_POST['fecha_inicio'] ?? '';
$fecha_fin = $_POST['fecha_fin'] ?? '';
$docente = $_POST['docente'] ?? '';

if (empty($id) || empty($nombre) || empty($fecha_inicio) || empty($fecha_fin) || empty($docente)) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos obligatorios']);
    exit;
}

$stmt = $conn->prepare("UPDATE Curso SET nombre = ?, descripcion = ?, fecha_inicio = ?, fecha_fin = ?, docente = ? WHERE id = ?");
$stmt->bind_param('sssssi', $nombre, $descripcion, $fecha_inicio, $fecha_fin, $docente, $id);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Curso actualizado correctamente']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al actualizar curso: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

<?php
header('Content-Type: application/json');
include 'conexion.php';

$id = $_GET['id'] ?? '';

if (empty($id)) {
    echo json_encode(['success' => false, 'message' => 'ID del curso requerido']);
    exit;
}

$stmt = $conn->prepare("DELETE FROM Curso WHERE id = ?");
$stmt->bind_param('i', $id);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Curso eliminado correctamente']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al eliminar curso: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

<?php
header('Content-Type: application/json');

// Incluir el archivo de conexión
require 'connection.php';

// Consultar los recursos
$sql = "SELECT id, titulo AS nombre, descripcion, tipo, enlace AS link FROM Recursos";
$result = $conn->query($sql);

if ($result === false) {
    // Manejo de errores en la consulta
    echo json_encode(['success' => false, 'message' => 'Error en la consulta: ' . $conn->error]);
} elseif ($result->num_rows > 0) {
    // Almacenar los recursos en un array
    $recursos = [];
    while ($row = $result->fetch_assoc()) {
        $recursos[] = $row;
    }

    // Retornar respuesta exitosa
    echo json_encode(['success' => true, 'data' => $recursos]);
} else {
    // Retornar respuesta si no hay recursos
    echo json_encode(['success' => false, 'message' => 'No se encontraron recursos']);
}

// Cerrar la conexión
$conn->close();
?>
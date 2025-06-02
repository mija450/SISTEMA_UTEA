<?php
header('Content-Type: application/json');

// Incluir el archivo de conexión
require 'connection.php';

// Verifica que sea PUT
parse_str(file_get_contents("php://input"), $_PUT);

// Recuperar campos
$id = isset($_PUT['id']) ? $_PUT['id'] : '';
$codigo = isset($_PUT['codigo']) ? $_PUT['codigo'] : '';
$titulo = isset($_PUT['titulo']) ? $_PUT['titulo'] : '';
$autor = isset($_PUT['autor']) ? $_PUT['autor'] : '';
$descripcion = isset($_PUT['descripcion']) ? $_PUT['descripcion'] : '';
$tipo = isset($_PUT['tipo']) ? $_PUT['tipo'] : '';
$enlace = isset($_PUT['enlace']) ? $_PUT['enlace'] : '';
$archivo_pdf = isset($_PUT['archivo_pdf']) ? $_PUT['archivo_pdf'] : '';
$fecha_publicacion = isset($_PUT['fecha_publicacion']) ? $_PUT['fecha_publicacion'] : '';
$categoria_id = isset($_PUT['categoria_id']) ? $_PUT['categoria_id'] : '';

// Validar que todos los campos estén presentes
if (empty($id) || empty($codigo) || empty($titulo) || empty($autor) || empty($descripcion) || empty($tipo)) {
    echo json_encode(['success' => false, 'message' => 'Todos los campos requeridos son necesarios']);
    exit;
}

// Preparar la consulta de actualización
$sql = "UPDATE biblioteca SET codigo = ?, titulo = ?, autor = ?, descripcion = ?, tipo = ?, enlace = ?, archivo_pdf = ?, fecha_publicacion = ?, categoria_id = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssssssssii", $codigo, $titulo, $autor, $descripcion, $tipo, $enlace, $archivo_pdf, $fecha_publicacion, $categoria_id, $id);

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Error en la actualización: ' . $stmt->error]);
}

// Cerrar la conexión
$stmt->close();
$conn->close();
?>
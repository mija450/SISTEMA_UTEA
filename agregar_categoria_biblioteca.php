<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php'; // Asegúrate de que este archivo tenga la conexión correcta a la base de datos

// Verificar que sea una solicitud POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Recuperar datos del POST
    $nombre = isset($_POST['nombre']) ? $_POST['nombre'] : '';
    $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : '';

    // Validar que los campos no estén vacíos
    if (empty($nombre)) {
        echo json_encode(array("success" => false, "message" => "El nombre de la categoría es requerido."));
        exit;
    }
    
    // Preparar la consulta para insertar la nueva categoría
    $sql = "INSERT INTO categoria_biblioteca (nombre, descripcion) VALUES (?, ?)";
    $stmt = $conn->prepare($sql);

    // Verificar si la preparación de la consulta fue exitosa
    if ($stmt === false) {
        echo json_encode(array("success" => false, "message" => "Error en la preparación de la consulta: " . $conn->error));
        exit;
    }

    // Vincular parámetros
    $stmt->bind_param("ss", $nombre, $descripcion);

    // Ejecutar la consulta
    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "Categoría agregada exitosamente."));
    } else {
        echo json_encode(array("success" => false, "message" => "Error al agregar la categoría: " . $stmt->error));
    }

    // Cerrar la declaración
    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Método no permitido"));
}

// Cerrar la conexión
$conn->close();
?>
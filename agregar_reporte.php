<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Verificar si se reciben datos
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $titulo = isset($_POST['titulo']) ? $_POST['titulo'] : '';
    $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : '';
    $fecha = isset($_POST['fecha']) ? $_POST['fecha'] : '';

    // Validar los datos recibidos
    if (empty($titulo)) {
        echo json_encode(array("success" => false, "message" => "El título es requerido"));
        exit;
    }
    if (empty($descripcion)) {
        echo json_encode(array("success" => false, "message" => "La descripción es requerida"));
        exit;
    }
    if (empty($fecha)) {
        echo json_encode(array("success" => false, "message" => "La fecha es requerida"));
        exit;
    }

    // Preparar la consulta para insertar los datos
    $sql = "INSERT INTO reportes (titulo, descripcion, fecha) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $titulo, $descripcion, $fecha);

    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "Reporte agregado con éxito"));
    } else {
        echo json_encode(array("success" => false, "message" => "Error al agregar el reporte"));
    }

    // Cerrar la declaración
    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Método no permitido"));
}

// Cerrar la conexión
$conn->close();
?>
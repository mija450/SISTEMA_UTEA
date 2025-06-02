<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Verificar si se reciben datos
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $pregunta = isset($_POST['pregunta']) ? $_POST['pregunta'] : '';
    $respuesta = isset($_POST['respuesta']) ? $_POST['respuesta'] : '';

    // Validar los datos recibidos
    if (empty($pregunta)) {
        echo json_encode(array("success" => false, "message" => "La pregunta es requerida"));
        exit;
    }

    // Preparar la consulta para insertar los datos
    $sql = "INSERT INTO soporte (pregunta, respuesta) VALUES (?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $pregunta, $respuesta);

    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "Consulta agregada con éxito"));
    } else {
        echo json_encode(array("success" => false, "message" => "Error al agregar la consulta"));
    }

    // Cerrar la declaración
    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Método no permitido"));
}

// Cerrar la conexión
$conn->close();
?>
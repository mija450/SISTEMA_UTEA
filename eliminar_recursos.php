<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

// Verifica que sea POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Recuperar campos
    $id = isset($_POST['id']) ? $_POST['id'] : '';

    // Validar que vengan
    if (empty($id)) {
        echo json_encode([
            "success" => false,
            "error" => "ID no proporcionado"
        ]);
        exit;
    }

    // Preparar la consulta de eliminación
    $sql = "DELETE FROM Recursos WHERE id = $id";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Recurso eliminado correctamente"]);
    } else {
        echo json_encode([
            "success" => false,
            "error" => "Error al eliminar en la BD: " . $conn->error
        ]);
    }

    $conn->close();
} else {
    echo json_encode([
        "success" => false,
        "error" => "Método no soportado"
    ]);
}
?>
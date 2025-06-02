<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

if ($_SERVER["REQUEST_METHOD"] == "DELETE") {
    // Obtener el cuerpo de la solicitud
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (isset($data["id"])) { // Cambia aquí para obtenerlo del cuerpo
        $id = intval($data["id"]); // Asegúrate de que sea un entero
        $sql = "DELETE FROM anuncios WHERE id = ?"; // Usar 'id' en la consulta
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            echo json_encode(["success" => false, "error" => "Error en la preparación de la consulta: " . $conn->error]);
            exit;
        }
        $stmt->bind_param("i", $id);
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Anuncio eliminado con éxito"]);
        } else {
            echo json_encode(["success" => false, "error" => "Error al eliminar el anuncio: " . $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(["success" => false, "error" => "Parámetro id no proporcionado"]);
    }
} else {
    echo json_encode(["success" => false, "error" => "Método no soportado"]);
}

$conn->close();
?>
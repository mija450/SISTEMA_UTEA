<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $idUsuario = $_POST['idUsuario'] ?? '';

    if (empty($idUsuario)) {
        echo json_encode(["success" => false, "message" => "Falta idUsuario"]);
        exit;
    }

    $sql = "DELETE FROM usuario WHERE idUsuario = $idUsuario";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Usuario eliminado con éxito"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al eliminar usuario: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Método no soportado"]);
}

$conn->close();
?>

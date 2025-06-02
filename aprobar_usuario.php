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

    // Actualiza la tabla 'usuario', poniendo 'activo = 1'
    $sql = "UPDATE usuario SET activo = 1 WHERE idUsuario = $idUsuario";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Usuario aprobado con éxito"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al aprobar usuario: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Método no soportado"]);
}

$conn->close();
?>

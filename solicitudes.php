<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Listar usuarios con activo = 0
$sql = "SELECT idUsuario, nombre, correo, rol
        FROM usuario
        WHERE activo = 0";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $usuarios = array();
    while ($row = $result->fetch_assoc()) {
        $usuarios[] = $row;
    }
    echo json_encode(["success" => true, "data" => $usuarios]);
} else {
    echo json_encode(["success" => false, "message" => "No hay solicitudes pendientes"]);
}

$conn->close();
?>

<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Obtenemos los datos
$nombreAntiguo = $_POST['nombreAntiguo'] ?? '';
$nombreNuevo   = $_POST['nombreNuevo']   ?? '';
$correoNuevo   = $_POST['correoNuevo']   ?? '';

// Validaciones mínimas
if (empty($nombreAntiguo) || empty($nombreNuevo) || empty($correoNuevo)) {
    echo json_encode(["success" => false, "message" => "Faltan datos"]);
    $conn->close();
    exit;
}

// Actualizamos en la tabla 'usuario' donde 'nombre' = $nombreAntiguo
$sql = "UPDATE usuario
        SET nombre = '$nombreNuevo', correo = '$correoNuevo'
        WHERE nombre = '$nombreAntiguo'";

if ($conn->query($sql) === TRUE) {
    if ($conn->affected_rows > 0) {
        echo json_encode(["success" => true, "message" => "Perfil actualizado correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "No se encontró el usuario o no se modificó nada"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Error al actualizar perfil: " . $conn->error]);
}

$conn->close();
?>

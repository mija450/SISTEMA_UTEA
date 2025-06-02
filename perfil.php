<?php
session_start();
header("Access-Control-Allow-Origin: *"); 
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// Incluir conexión a la base de datos
include 'connection.php';

// Recibir el nombre desde la solicitud POST
$nombre = isset($_POST['nombre']) ? $_POST['nombre'] : '';

if (empty($nombre)) {
    echo json_encode(["success" => false, "message" => "Nombre no proporcionado"]);
    exit;
}

// Consulta a la base de datos para obtener los detalles del usuario por nombre
$sql = "SELECT correo, rol FROM usuario WHERE nombre = ?"; // Asegúrate de que el nombre de la tabla sea correcto
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $nombre);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();

    // Enviar los datos del usuario
    echo json_encode([
        "success" => true,
        "data" => [
            "nombre" => $nombre,
            "correo" => $row['correo'],
            "rol" => $row['rol'] // Obtener el rol
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "vuelva a iniciar secion porfavor"]);
}

// Cerrar conexión
$stmt->close();
$conn->close();
?>
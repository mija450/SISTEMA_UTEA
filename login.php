<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Método no permitido. Usa POST."]);
    exit;
}

$correo = trim($_POST['correo'] ?? '');
$codigo = trim($_POST['codigo'] ?? '');

if (empty($correo) || empty($codigo)) {
    echo json_encode(["success" => false, "message" => "Correo y contraseña son obligatorios."]);
    exit;
}

$sql = "SELECT idUsuario, nombre, rol, contraseña FROM Usuario WHERE correo = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Error interno."]);
    exit;
}

$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

// Para evitar revelar si el correo está mal, tratamos errores con el mismo mensaje
if ($result->num_rows !== 1) {
    echo json_encode(["success" => false, "message" => "Credenciales incorrectas."]);
    $stmt->close();
    $conn->close();
    exit;
}

$row = $result->fetch_assoc();
$hashGuardado = $row['contraseña'];

if (password_verify($codigo, $hashGuardado)) {
    echo json_encode([
        "success" => true,
        "message" => "Acceso correcto.",
        "user" => [
            "idUsuario" => $row['idUsuario'],
            "nombre" => $row['nombre'],
            "rol" => $row['rol']
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Credenciales incorrectas."]);
}

$stmt->close();
$conn->close();
?>

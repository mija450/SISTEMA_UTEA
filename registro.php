<?php
// Encabezados para permitir peticiones desde cualquier origen
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Incluir conexión a base de datos
include 'connection.php'; // Asegúrate de que $conn esté definido correctamente

// Solo permitir método POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Método no soportado. Usa POST."]);
    exit;
}

// Recoger datos del formulario
$rol = $_POST['rol'] ?? '';
$nombre = $_POST['nombre'] ?? '';
$correo = $_POST['correo'] ?? '';
$codigo = $_POST['codigo'] ?? '';

// Validar campos vacíos
if (empty($rol) || empty($nombre) || empty($correo) || empty($codigo)) {
    echo json_encode(["success" => false, "message" => "Todos los campos son obligatorios."]);
    exit;
}

// Validar formato del correo
if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(["success" => false, "message" => "Correo no válido."]);
    exit;
}

// Verificar si ya existe ese correo
$checkEmailSql = "SELECT idUsuario FROM Usuario WHERE correo = ?";
$stmt = $conn->prepare($checkEmailSql);
if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Error en la preparación (SELECT): " . $conn->error]);
    exit;
}

$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "El correo ya está registrado."]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Encriptar el código como contraseña
$contraseña = password_hash($codigo, PASSWORD_BCRYPT);

// Insertar nuevo usuario
$insertSql = "INSERT INTO Usuario (nombre, correo, codigo, rol, contraseña) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($insertSql);

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Error preparando inserción (INSERT): " . $conn->error]);
    $conn->close();
    exit;
}

$stmt->bind_param("sssss", $nombre, $correo, $codigo, $rol, $contraseña);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Registro exitoso."]);
} else {
    echo json_encode(["success" => false, "message" => "Error al registrar: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

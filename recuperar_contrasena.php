<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/PHPMailer.php';
require 'PHPMailer/SMTP.php';
require 'PHPMailer/Exception.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

$correo = trim($_POST['correo'] ?? '');

if (empty($correo)) {
    echo json_encode(['success' => false, 'message' => 'Correo requerido']);
    exit;
}

// Buscar usuario por correo
$stmt = $conn->prepare("SELECT idUsuario, nombre FROM Usuario WHERE correo = ?");
$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'Correo no registrado']);
    $stmt->close();
    $conn->close();
    exit;
}

$usuario = $result->fetch_assoc();
$nombre = $usuario['nombre'];
$codigoTemporal = rand(100000, 999999);

// Aquí puedes guardar el código temporal en la base si quieres (opcional)
// $update = $conn->prepare("UPDATE Usuario SET codigo_recuperacion = ? WHERE correo = ?");
// $update->bind_param("ss", $codigoTemporal, $correo);
// $update->execute();

// Configurar PHPMailer
$mail = new PHPMailer(true);

try {
    // Configuración SMTP
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'gatocr2005@gmail.com';  // Cambia a tu correo real
    $mail->Password   = 'tu_contraseña_app';     // Cambia a tu contraseña de app real
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port       = 587;

    // Detalles del correo
    $mail->setFrom('no-reply@uteago.edu.pe', 'UTEA GO');
    $mail->addAddress($correo, $nombre);

    $mail->Subject = 'Recuperación de contraseña - UTEA GO';
    $mail->Body    = "Hola $nombre,\n\nTu código de recuperación es: $codigoTemporal\n\nSi no solicitaste esto, ignora este mensaje.";
    $mail->AltBody = "Tu código de recuperación es: $codigoTemporal";

    $mail->send();
    echo json_encode(['success' => true, 'message' => 'Correo enviado con éxito', 'codigo' => $codigoTemporal]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error al enviar el correo: ' . $mail->ErrorInfo]);
}

$stmt->close();
$conn->close();

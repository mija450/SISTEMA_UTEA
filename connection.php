<?php
// connection.php

// Parámetros de conexión
$host = "localhost"; 
$user = "admincs";       // Ajusta según tu configuración
$password = "Qxu@zRd7A^BS";       // Contraseña de MySQL (en XAMPP suele ser vacía)
$dbname = "colegio";  // Nombre de la base de datos

// Crear la conexión
$conn = new mysqli($host, $user, $password, $dbname);

// Verificar la conexión
if ($conn->connect_error) {
    die("Error de conexión: " . $conn->connect_error);
}

// Establecer el charset
$conn->set_charset("utf8");
?>

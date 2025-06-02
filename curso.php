<?php
// curso.php

// Encabezados para permitir CORS y definir tipo de contenido
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Configuración de conexión
$host = "localhost";
$user = "admincs";
$password = "Qxu@zRd7A^BS";
$database = "colegio";

// Crear conexión
$conn = new mysqli($host, $user, $password, $database);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(array("success" => false, "message" => "Conexión fallida: " . $conn->connect_error)));
}

// Solo aceptar método GET
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT * FROM Curso";
    $result = $conn->query($sql);

    $data = array();

    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode(array("success" => true, "data" => $data));
    } else {
        echo json_encode(array("success" => false, "message" => "No hay cursos disponibles"));
    }
} else {
    echo json_encode(array("success" => false, "message" => "Método no soportado"));
}

$conn->close();
?>

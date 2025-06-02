<?php
// aula.php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$user = "admincs";
$password = "Qxu@zRd7A^BS";
$database = "colegio";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Conexión fallida: " . $conn->connect_error
    ]));
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT * FROM Aula ORDER BY idAula ASC";
    $result = $conn->query($sql);

    $data = [];

    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = [
                "idAula" => (int)$row['idAula'],
                "nombre" => $row['nombre'],
                "capacidad" => (int)$row['capacidad'],
                "tipo" => $row['tipo'],
                "recursos" => $row['recursos'],
                "created_at" => $row['created_at']
            ];
        }
        echo json_encode([
            "success" => true,
            "data" => $data
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "No hay aulas disponibles"
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Método no soportado"
    ]);
}

$conn->close();
?>

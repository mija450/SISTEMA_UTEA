<?php
// comunicacion.php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Consulta para obtener todos los registros de la tabla "anuncios"
    $sql = "SELECT * FROM anuncios";
    $result = $conn->query($sql);

    $data = array();
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode(array("success" => true, "data" => $data));
    } else {
        echo json_encode(array("success" => false, "message" => "No hay anuncios disponibles"));
    }
} else {
    echo json_encode(array("success" => false, "message" => "Método no soportado"));
}

$conn->close();
?>
<?php
include 'connection.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$action = isset($_GET['action']) ? $_GET['action'] : '';

if ($action == "getAlumnos") {
    $sql = "SELECT nombre FROM usuario WHERE rol = 'alumno'";
} elseif ($action == "getDocentes") {
    $sql = "SELECT nombre FROM usuario WHERE rol = 'docente'";
} elseif ($action == "getDireccion") {
    $sql = "SELECT nombre FROM usuario WHERE rol = 'direccion'";
} elseif ($action == "getCursos") {
    $sql = "SELECT nombre FROM cursos";
} else {
    echo json_encode(["success" => false, "message" => "Acción no válida"]);
    exit;
}

$result = $conn->query($sql);
$data = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(["success" => true, "data" => $data]);
} else {
    echo json_encode(["success" => false, "message" => "No hay datos disponibles"]);
}
?>

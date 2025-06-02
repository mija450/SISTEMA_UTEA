<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

$sql = "SELECT * FROM Tareas";
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(array("success" => true, "data" => $data));
} else {
    echo json_encode(array("success" => false, "message" => "No hay tareas disponibles"));
}

$conn->close();
?>

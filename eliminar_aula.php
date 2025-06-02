<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$user = "admincs";
$password = "Qxu@zRd7A^BS";
$dbname = "colegio";

$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);
$idAula = $data['idAula'];

$sql = "DELETE FROM Aula WHERE idAula = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $idAula);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Aula eliminada con éxito"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al eliminar aula: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

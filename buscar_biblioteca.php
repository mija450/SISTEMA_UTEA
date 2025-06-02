<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

// Verifica que sea POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Recuperar campos
    $query = isset($_POST['query']) ? $_POST['query'] : '';

    // Validar que venga
    if (empty($query)) {
        echo json_encode([
            "success" => false,
            "error" => "Consulta no proporcionada"
        ]);
        exit;
    }

    // Preparar la consulta de búsqueda
    $sql = "SELECT id, titulo, descripcion FROM biblioteca WHERE titulo LIKE '%$query%' OR descripcion LIKE '%$query%'";
    $result = $conn->query($sql);

    $data = array();
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode(array("success" => true, "data" => $data));
    } else {
        echo json_encode(array("success" => false, "message" => "No se encontraron recursos"));
    }

    $conn->close();
} else {
    echo json_encode([
        "success" => false,
        "error" => "Método no soportado"
    ]);
}
?>
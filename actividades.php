<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Incluir el archivo de conexión a la base de datos
include 'connection.php';

// Consulta para seleccionar todas las entradas en la tabla Actividades
$sql = "SELECT * FROM Actividades ORDER BY fecha, hora"; // opcional: ordena por fecha y hora
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    // Recorrer los resultados y almacenarlos en un array
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    // Devolver los datos en formato JSON
    echo json_encode(array("success" => true, "data" => $data));
} else {
    // Mensaje si no hay actividades disponibles
    echo json_encode(array("success" => false, "message" => "No hay actividades disponibles"));
}

// Cerrar la conexión
$conn->close();
?>

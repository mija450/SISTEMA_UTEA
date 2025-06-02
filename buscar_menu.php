<?php
header('Content-Type: application/json');
require 'connection.php'; // Asegúrate de tener este archivo para la conexión a la base de datos

if (isset($_POST['search'])) {
    $searchTerm = $_POST['search'];
    
    // Conectar a la base de datos
    $conn = new mysqli($servername, $username, $password, $dbname);
    
    // Verificar la conexión
    if ($conn->connect_error) {
        die(json_encode(['success' => false, 'message' => 'Conexión fallida: ' . $conn->connect_error]));
    }

    // Prepare y bind
    $stmt = $conn->prepare("SELECT * FROM menu_items WHERE name LIKE ?");
    $searchTermLike = "%" . $searchTerm . "%";
    $stmt->bind_param("s", $searchTermLike);
    
    // Ejecutar la consulta
    $stmt->execute();
    $result = $stmt->get_result();

    $items = [];
    while ($row = $result->fetch_assoc()) {
        $items[] = $row;
    }

    // Cerrar la conexión
    $stmt->close();
    $conn->close();

    // Devolver los resultados
    echo json_encode(['success' => true, 'data' => $items]);
} else {
    echo json_encode(['success' => false, 'message' => 'Término de búsqueda no proporcionado']);
}
?>
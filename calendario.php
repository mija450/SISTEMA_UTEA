<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$user = "admincs";
$password = "Qxu@zRd7A^BS";
$dbname = "colegio";

// Crear conexión
$conn = new mysqli($host, $user, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $sql = "SELECT * FROM calendario";
        $result = $conn->query($sql);

        $data = [];
        if ($result && $result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                // Garantizar que los campos no sean null
                $row['id'] = $row['id'] ?? 0;
                $row['title'] = $row['title'] ?? '';
                $row['description'] = $row['description'] ?? '';
                $row['start_date'] = isset($row['start_date']) ? date('Y-m-d H:i:s', strtotime($row['start_date'])) : '';
                $row['end_date'] = isset($row['end_date']) ? date('Y-m-d H:i:s', strtotime($row['end_date'])) : '';
                
                $data[] = $row;
            }
        }

        echo json_encode($data);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);

        // Validar campos requeridos
        if (!isset($data['title'], $data['start_date'], $data['end_date'], $data['description'])) {
            http_response_code(400);
            echo json_encode(["error" => "Faltan campos requeridos"]);
            exit;
        }

        $title = $conn->real_escape_string($data['title']);
        $start_date = $conn->real_escape_string($data['start_date']);
        $end_date = $conn->real_escape_string($data['end_date']);
        $description = $conn->real_escape_string($data['description']);

        $sql = "INSERT INTO calendario (title, start_date, end_date, description) VALUES ('$title', '$start_date', '$end_date', '$description')";

        if ($conn->query($sql)) {
            echo json_encode(["message" => "Evento agregado con éxito"]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al agregar evento: " . $conn->error]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['id'], $data['title'], $data['start_date'], $data['end_date'], $data['description'])) {
            http_response_code(400);
            echo json_encode(["error" => "Faltan campos requeridos para actualizar"]);
            exit;
        }

        $id = (int)$data['id'];
        $title = $conn->real_escape_string($data['title']);
        $start_date = $conn->real_escape_string($data['start_date']);
        $end_date = $conn->real_escape_string($data['end_date']);
        $description = $conn->real_escape_string($data['description']);

        $sql = "UPDATE calendario SET title='$title', start_date='$start_date', end_date='$end_date', description='$description' WHERE id=$id";

        if ($conn->query($sql)) {
            echo json_encode(["message" => "Evento actualizado con éxito"]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al actualizar evento: " . $conn->error]);
        }
        break;

    case 'DELETE':
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['id'])) {
            http_response_code(400);
            echo json_encode(["error" => "Falta el ID para eliminar"]);
            exit;
        }

        $id = (int)$data['id'];

        $sql = "DELETE FROM calendario WHERE id=$id";

        if ($conn->query($sql)) {
            echo json_encode(["message" => "Evento eliminado con éxito"]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al eliminar evento: " . $conn->error]);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(["error" => "Método no permitido"]);
}

$conn->close();
?>

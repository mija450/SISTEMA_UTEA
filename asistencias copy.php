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
    die(json_encode(array("success" => false, "message" => "Connection failed: " . $conn->connect_error)));
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $sql = "SELECT * FROM asistencias";
        $result = $conn->query($sql);

        $data = array();
        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                // Format the date to DD/MM/YYYY for Flutter
                $row['date'] = date('d/m/Y', strtotime($row['date']));
                $data[] = $row;
            }
            echo json_encode(array("success" => true, "data" => $data));
        } else {
            echo json_encode(array("success" => true, "message" => "No hay asistencias disponibles", "data" => []));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        $subject = $data['subject'];
        // Convert the date from DD/MM/YYYY to YYYY-MM-DD for the database
        $date = date('Y-m-d', strtotime(str_replace('/', '-', $data['date'])));
        $status = $data['status'];

        $sql = "INSERT INTO asistencias (subject, date, status) VALUES ('$subject', '$date', '$status')";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Asistencia agregada con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al agregar asistencia: " . $conn->error));
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'];
        $subject = $data['subject'];
        // Convert the date from DD/MM/YYYY to YYYY-MM-DD for the database
        $date = date('Y-m-d', strtotime(str_replace('/', '-', $data['date'])));
        $status = $data['status'];

        $sql = "UPDATE asistencias SET subject='$subject', date='$date', status='$status' WHERE id=$id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Asistencia actualizada con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al actualizar asistencia: " . $conn->error));
        }
        break;

    case 'DELETE':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'];

        $sql = "DELETE FROM asistencias WHERE id=$id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Asistencia eliminada con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al eliminar asistencia: " . $conn->error));
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(array("success" => false, "message" => "Método no permitido"));
}

$conn->close();
?>
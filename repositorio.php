<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$user = "admincs"; // Replace with your MySQL username
$password = "Qxu@zRd7A^BS"; // Replace with your MySQL password
$dbname = "colegio"; // Replace with your MySQL database name

// Crear conexión
$conn = new mysqli($host, $user, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(array("success" => false, "message" => "Connection failed: " . $conn->connect_error)));
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $sql = "SELECT * FROM repositorio";
        $result = $conn->query($sql);

        $data = array();
        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                // Format the date to DD/MM/YYYY HH:mm:ss for Flutter (optional)
                // $row['fecha_subida'] = date('d/m/Y H:i:s', strtotime($row['fecha_subida']));

                $data[] = $row;
            }
            echo json_encode(array("success" => true, "data" => $data));
        } else {
            echo json_encode(array("success" => true, "message" => "No hay archivos disponibles", "data" => []));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        $nombre_archivo = $data['nombre_archivo'];
        $tipo_archivo = $data['tipo_archivo'];
        $ruta_archivo = $data['ruta_archivo'];
        $descripcion = isset($data['descripcion']) ? $data['descripcion'] : null;
        $categoria = isset($data['categoria']) ? $data['categoria'] : null;
        $tamano_archivo = $data['tamano_archivo'];
        $usuario_subida = isset($data['usuario_subida']) ? $data['usuario_subida'] : null;
        $nombre_original = $data['nombre_original'];

        $sql = "INSERT INTO repositorio (nombre_archivo, tipo_archivo, ruta_archivo, descripcion, categoria, tamano_archivo, usuario_subida, nombre_original)
                VALUES ('$nombre_archivo', '$tipo_archivo', '$ruta_archivo', " . ($descripcion === null ? 'NULL' : "'$descripcion'") . ", " . ($categoria === null ? 'NULL' : "'$categoria'") . ", $tamano_archivo, " . ($usuario_subida === null ? 'NULL' : "$usuario_subida") . ", '$nombre_original')";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Archivo agregado con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al agregar archivo: " . $conn->error));
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'];
        $nombre_archivo = $data['nombre_archivo'];
        $tipo_archivo = $data['tipo_archivo'];
        $ruta_archivo = $data['ruta_archivo'];
        $descripcion = isset($data['descripcion']) ? $data['descripcion'] : null;
        $categoria = isset($data['categoria']) ? $data['categoria'] : null;
        $tamano_archivo = $data['tamano_archivo'];
        $usuario_subida = isset($data['usuario_subida']) ? $data['usuario_subida'] : null;
        $nombre_original = $data['nombre_original'];

        $sql = "UPDATE repositorio SET
                nombre_archivo='$nombre_archivo',
                tipo_archivo='$tipo_archivo',
                ruta_archivo='$ruta_archivo',
                descripcion=" . ($descripcion === null ? 'NULL' : "'$descripcion'") . ",
                categoria=" . ($categoria === null ? 'NULL' : "'$categoria'") . ",
                tamano_archivo=$tamano_archivo,
                usuario_subida=" . ($usuario_subida === null ? 'NULL' : "$usuario_subida") . ",
                nombre_original='$nombre_original'
                WHERE id=$id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Archivo actualizado con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al actualizar archivo: " . $conn->error));
        }
        break;

    case 'DELETE':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'];

        $sql = "DELETE FROM repositorio WHERE id=$id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Archivo eliminado con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al eliminar archivo: " . $conn->error));
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(array("success" => false, "message" => "Método no permitido"));
}

$conn->close();
?>
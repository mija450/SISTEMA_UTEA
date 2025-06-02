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
        $sql = "SELECT * FROM biblioteca";
        $result = $conn->query($sql);

        $data = array();
        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                // Format the date to DD/MM/YYYY for Flutter
                if ($row['fecha_publicacion'] != null) {
                    $row['fecha_publicacion'] = date('d/m/Y', strtotime($row['fecha_publicacion']));
                }
                $data[] = $row;
            }
            echo json_encode(array("success" => true, "data" => $data));
        } else {
            echo json_encode(array("success" => true, "message" => "No hay libros disponibles", "data" => []));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        $titulo = $data['titulo'];
        $autor = $data['autor'];
        $genero = isset($data['genero']) ? $data['genero'] : null;
        $isbn = $data['isbn'];

        // Convert the date from DD/MM/YYYY to YYYY-MM-DD for the database
        $fecha_publicacion = isset($data['fecha_publicacion']) && $data['fecha_publicacion'] != "" ? date('Y-m-d', strtotime(str_replace('/', '-', $data['fecha_publicacion']))) : null;

        $descripcion = isset($data['descripcion']) ? $data['descripcion'] : null;
        $cantidad_disponible = $data['cantidad_disponible'];
        $portada_url = isset($data['portada_url']) ? $data['portada_url'] : null;

        $sql = "INSERT INTO biblioteca (titulo, autor, genero, isbn, fecha_publicacion, descripcion, cantidad_disponible, portada_url)
                VALUES ('$titulo', '$autor', " . ($genero === null ? 'NULL' : "'$genero'") . ", '$isbn', " . ($fecha_publicacion === null ? 'NULL' : "'$fecha_publicacion'") . ", " . ($descripcion === null ? 'NULL' : "'$descripcion'") . ", $cantidad_disponible, " . ($portada_url === null ? 'NULL' : "'$portada_url'") . ")";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Libro agregado con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al agregar libro: " . $conn->error));
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'];
        $titulo = $data['titulo'];
        $autor = $data['autor'];
        $genero = isset($data['genero']) ? $data['genero'] : null;
        $isbn = $data['isbn'];

        // Convert the date from DD/MM/YYYY to YYYY-MM-DD for the database
        $fecha_publicacion = isset($data['fecha_publicacion']) && $data['fecha_publicacion'] != "" ? date('Y-m-d', strtotime(str_replace('/', '-', $data['fecha_publicacion']))) : null;

        $descripcion = isset($data['descripcion']) ? $data['descripcion'] : null;
        $cantidad_disponible = $data['cantidad_disponible'];
        $portada_url = isset($data['portada_url']) ? $data['portada_url'] : null;

        $sql = "UPDATE biblioteca SET
                titulo='$titulo',
                autor='$autor',
                genero=" . ($genero === null ? 'NULL' : "'$genero'") . ",
                isbn='$isbn',
                fecha_publicacion=" . ($fecha_publicacion === null ? 'NULL' : "'$fecha_publicacion'") . ",
                descripcion=" . ($descripcion === null ? 'NULL' : "'$descripcion'") . ",
                cantidad_disponible=$cantidad_disponible,
                portada_url=" . ($portada_url === null ? 'NULL' : "'$portada_url'") . "
                WHERE id=$id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Libro actualizado con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al actualizar libro: " . $conn->error));
        }
        break;

    case 'DELETE':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'];

        $sql = "DELETE FROM biblioteca WHERE id=$id";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Libro eliminado con éxito"));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al eliminar libro: " . $conn->error));
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(array("success" => false, "message" => "Método no permitido"));
}

$conn->close();
?>
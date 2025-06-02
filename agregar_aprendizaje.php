<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

// Verificar que sea una solicitud POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Recibir datos
    $codigo = isset($_POST['codigo']) ? $_POST['codigo'] : '';
    $titulo = isset($_POST['titulo']) ? $_POST['titulo'] : '';
    $autor = isset($_POST['autor']) ? $_POST['autor'] : '';
    $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : '';
    $tipo = isset($_POST['tipo']) ? $_POST['tipo'] : '';
    $enlace = isset($_POST['enlace']) ? $_POST['enlace'] : '';
    $archivo_pdf = isset($_POST['archivo_pdf']) ? $_POST['archivo_pdf'] : '';
    $categoria_id = isset($_POST['categoria_id']) ? (int)$_POST['categoria_id'] : null; // Convertir a entero

    // Diagnóstico: Mostrar el ID de categoría recibido
    echo "ID de categoría recibido: " . ($categoria_id !== null ? $categoria_id : 'null') . "\n"; // Para depuración

    // Validar los datos recibidos
    if (empty($codigo)) {
        echo json_encode(array("success" => false, "message" => "El código es requerido"));
        exit;
    }
    if (empty($titulo)) {
        echo json_encode(array("success" => false, "message" => "El título es requerido"));
        exit;
    }
    if (empty($autor)) {
        echo json_encode(array("success" => false, "message" => "El autor es requerido"));
        exit;
    }
    if (empty($descripcion)) {
        echo json_encode(array("success" => false, "message" => "La descripción es requerida"));
        exit;
    }
    if (empty($tipo)) {
        echo json_encode(array("success" => false, "message" => "El tipo es requerido"));
        exit;
    }
    if (is_null($categoria_id) || $categoria_id <= 0) {
        echo json_encode(array("success" => false, "message" => "La categoría es requerida"));
        exit;
    }

    // Validar que categoria_id sea un entero válido
    if (!filter_var($categoria_id, FILTER_VALIDATE_INT)) {
        echo json_encode(array("success" => false, "message" => "ID de categoría inválido"));
        exit;
    }

    // Verificar que categoria_id exista en la tabla categoria_biblioteca
    $check_sql = "SELECT * FROM categoria_biblioteca WHERE id = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("i", $categoria_id);
    $check_stmt->execute();
    $result = $check_stmt->get_result();

    if ($result->num_rows === 0) {
        echo json_encode(array("success" => false, "message" => "ID de categoría no existe"));
        exit;
    }

    // Preparar la consulta para insertar los datos
    $sql = "INSERT INTO biblioteca (codigo, titulo, autor, descripcion, tipo, enlace, archivo_pdf, categoria_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);

    // Verificar si la preparación de la consulta fue exitosa
    if ($stmt === false) {
        echo json_encode(array("success" => false, "message" => "Error en la preparación de la consulta: " . $conn->error));
        exit;
    }

    // Vincular parámetros
    $stmt->bind_param("sssssssi", $codigo, $titulo, $autor, $descripcion, $tipo, $enlace, $archivo_pdf, $categoria_id);

    // Ejecutar la consulta
    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "Recurso agregado con éxito"));
    } else {
        echo json_encode(array("success" => false, "message" => "Error al agregar el recurso: " . $stmt->error));
    }

    // Cerrar la declaración
    $stmt->close();
    $check_stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Método no permitido"));
}

// Cerrar la conexión
$conn->close();
?>
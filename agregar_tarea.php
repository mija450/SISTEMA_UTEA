<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Recuperar campos
        $titulo = isset($_POST['titulo']) ? $_POST['titulo'] : '';
        $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : '';
        $cursoId = isset($_POST['curso_id']) ? $_POST['curso_id'] : '';
        $fechaLimite = isset($_POST['fecha_limite']) ? $_POST['fecha_limite'] : '';

        // Validar que vengan
        if (empty($titulo) || empty($descripcion) || empty($cursoId) || empty($fechaLimite)) {
            echo json_encode([
                "success" => false,
                "error" => "Datos de texto incompletos"
            ]);
            exit;
        }

        // Verificar que venga el archivo PDF
        if (!isset($_FILES['archivo']) || $_FILES['archivo']['error'] !== UPLOAD_ERR_OK) {
            echo json_encode([
                "success" => false,
                "error" => "No se recibió el archivo o hubo un error en la subida"
            ]);
            exit;
        }

        // Leer el contenido binario del PDF
        $pdfData = file_get_contents($_FILES['archivo']['tmp_name']);
        if ($pdfData === false) {
            echo json_encode([
                "success" => false,
                "error" => "Error al leer el archivo PDF"
            ]);
            exit;
        }

        // Escapar el binario para insertarlo como BLOB
        $pdfDataEscaped = mysqli_real_escape_string($conn, $pdfData);

        // Insertar en la base de datos
        $sql = "INSERT INTO Tareas (titulo, descripcion, fecha_limite, estado, curso_id, archivo) 
                VALUES ('$titulo', '$descripcion', '$fechaLimite', 'pendiente', '$cursoId', '$pdfDataEscaped')";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(["success" => true, "message" => "Tarea agregada correctamente"]);
        } else {
            echo json_encode([
                "success" => false,
                "error" => "Error al insertar en la BD: " . $conn->error
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            "success" => false,
            "error" => "Error: " . $e->getMessage()
        ]);
    } finally {
        $conn->close();
    }
} else {
    echo json_encode([
        "success" => false,
        "error" => "Método no soportado"
    ]);
}
?>
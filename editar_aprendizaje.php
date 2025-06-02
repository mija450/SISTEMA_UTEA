<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'connection.php';

// Verifica que sea POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Recuperar campos
    $id = isset($_POST['id']) ? $_POST['id'] : '';
    $titulo = isset($_POST['titulo']) ? $_POST['titulo'] : '';
    $subtitulo = isset($_POST['subtitulo']) ? $_POST['subtitulo'] : '';

    // Validar que vengan
    if (empty($id) || empty($titulo) || empty($subtitulo)) {
        echo json_encode([
            "success" => false,
            "error" => "Datos de texto incompletos"
        ]);
        exit;
    }

    // Preparar la consulta de actualización
    $sql = "UPDATE aprendizaje SET titulo = '$titulo', subtitulo = '$subtitulo' WHERE id = $id";

    // Verificar si hay un archivo PDF
    if (isset($_FILES['archivo']) && $_FILES['archivo']['error'] === UPLOAD_ERR_OK) {
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
        
        // Actualizar también el archivo
        $sql = "UPDATE aprendizaje SET titulo = '$titulo', subtitulo = '$subtitulo', archivo = '$pdfDataEscaped' WHERE id = $id";
    }

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Aprendizaje actualizado correctamente"]);
    } else {
        echo json_encode([
            "success" => false,
            "error" => "Error al actualizar en la BD: " . $conn->error
        ]);
    }

    $conn->close();
} else {
    echo json_encode([
        "success" => false,
        "error" => "Método no soportado"
    ]);
}
?>
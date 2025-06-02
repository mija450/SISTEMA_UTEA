<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/pdf");

include 'connection.php';

if (isset($_GET['id'])) {
    $id = (int)$_GET['id'];

    $sql = "SELECT archivo FROM aprendizaje WHERE id = $id";
    $result = $conn->query($sql);

    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo $row['archivo']; // Imprime directamente el contenido BLOB del PDF
    } else {
        echo "No se encontró el archivo con ID: $id";
    }
} else {
    echo "ID no especificado";
}

$conn->close();
?>

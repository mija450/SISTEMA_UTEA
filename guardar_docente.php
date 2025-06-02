<?php
include 'conexion.php';

$id = $_POST['idDocente'];
$nombre = $_POST['nombreDocente'];
$dni = $_POST['dni'];
$codigo = $_POST['codigo'];
$materia = $_POST['materia'];
$campo = $_POST['campo'];
$horario = $_POST['horariosDisponibles'];
$aula = $_POST['aula'];

$query = "INSERT INTO Docente (idDocente, nombreDocente, dni, codigo, materia, campo, horariosDisponibles, aula) 
          VALUES ('$id', '$nombre', '$dni', '$codigo', '$materia', '$campo', '$horario', '$aula')";

if ($conn->query($query)) {
    header("Location: docentes.php");
} else {
    echo "Error: " . $conn->error;
}
?>

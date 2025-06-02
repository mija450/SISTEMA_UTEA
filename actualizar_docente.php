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

$query = "UPDATE Docente SET 
            nombreDocente='$nombre', 
            dni='$dni', 
            codigo='$codigo', 
            materia='$materia', 
            campo='$campo', 
            horariosDisponibles='$horario', 
            aula='$aula' 
          WHERE idDocente=$id";

if ($conn->query($query)) {
    header("Location: docentes.php");
} else {
    echo "Error: " . $conn->error;
}
?>

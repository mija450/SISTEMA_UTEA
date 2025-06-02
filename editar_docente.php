<?php
include 'conexion.php';
$id = $_GET['id'];
$query = "SELECT * FROM Docente WHERE idDocente = $id";
$result = $conn->query($query);
$docente = $result->fetch_assoc();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Editar Docente</title>
</head>
<body>
    <h1>Editar Docente</h1>
    <form action="actualizar_docente.php" method="POST">
        <input type="hidden" name="idDocente" value="<?= $docente['idDocente'] ?>">
        <input type="text" name="nombreDocente" value="<?= $docente['nombreDocente'] ?>" required><br>
        <input type="text" name="dni" value="<?= $docente['dni'] ?>" required><br>
        <input type="text" name="codigo" value="<?= $docente['codigo'] ?>" required><br>
        <input type="text" name="materia" value="<?= $docente['materia'] ?>" required><br>
        <input type="text" name="campo" value="<?= $docente['campo'] ?>" required><br>
        <input type="text" name="horariosDisponibles" value="<?= $docente['horariosDisponibles'] ?>" required><br>
        <input type="text" name="aula" value="<?= $docente['aula'] ?>" required><br>
        <button type="submit">Actualizar</button>
    </form>
</body>
</html>

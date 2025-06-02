<!DOCTYPE html>
<html>
<head>
    <title>Agregar Docente</title>
</head>
<body>
    <h1>Agregar Docente</h1>
    <form action="guardar_docente.php" method="POST">
        <input type="number" name="idDocente" placeholder="ID del Usuario" required><br>
        <input type="text" name="nombreDocente" placeholder="Nombre" required><br>
        <input type="text" name="dni" placeholder="DNI" required><br>
        <input type="text" name="codigo" placeholder="Código" required><br>
        <input type="text" name="materia" placeholder="Materia" required><br>
        <input type="text" name="campo" placeholder="Campo" required><br>
        <input type="text" name="horariosDisponibles" placeholder="Horarios Disponibles" required><br>
        <input type="text" name="aula" placeholder="Aula" required><br>
        <button type="submit">Guardar</button>
    </form>
</body>
</html>

/*
private user = root;
private host = localhost;
private password = ;
private name = colegio;
*/

select*from usuario;
select*from notificacion;
select*from chat;
select*from mensaje;
select*from estudiante;
select*from tutor;
select*from sesion;
select*from material;

select*from anuncios;
select*from aprendizaje;
select*from tareas;
select*from eventos;
select*from recursos;
select*from categoria_biblioteca;
select*from curso;
select*from eventos;
select*from encuestas;
select*from reportes;
select*from biblioteca;
select*from categoria;

CREATE TABLE Usuario (
    idUsuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    correo VARCHAR(255) NOT NULL,
    codigo VARCHAR(50) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    contraseña VARCHAR(255) NOT NULL 
);

CREATE TABLE Notificacion (
    idNotificacion INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL,
    mensaje VARCHAR(255) NOT NULL,
    fecha DATE NOT NULL,
    usuarios_id INT,
    FOREIGN KEY (usuarios_id) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Chat (
    idChat INT PRIMARY KEY AUTO_INCREMENT
);

CREATE TABLE tareas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_limite DATE,
    estado ENUM('pendiente', 'completada') DEFAULT 'pendiente'
);

CREATE TABLE Mensaje (
    idMensaje INT PRIMARY KEY AUTO_INCREMENT,
    contenido TEXT NOT NULL,
    fechaEnvio DATE NOT NULL,
    remitente INT,
    FOREIGN KEY (remitente) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Estudiante (
    idEstudiante INT PRIMARY KEY AUTO_INCREMENT,
    nivelAcademico VARCHAR(255) NOT NULL,
    FOREIGN KEY (idEstudiante) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Tutor (
    idTutor INT PRIMARY KEY AUTO_INCREMENT,
    especialidad VARCHAR(255) NOT NULL,
    horariosDisponibles TEXT NOT NULL,
    FOREIGN KEY (idTutor) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Sesion (
    idSesion INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(50) NOT NULL
);

CREATE TABLE Material (
    idMaterial INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    archivo BLOB NOT NULL
);

INSERT INTO Chat (idChat) VALUES 
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20);

CREATE TABLE anuncios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    detalles TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE aprendizaje (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    subtitulo VARCHAR(255) NOT NULL,
    archivo LONGBLOB NOT NULL,  -- Cambia el tipo de dato para almacenar archivos
    nombre_archivo VARCHAR(255) NOT NULL  -- Almacena el nombre del archivo
);

CREATE TABLE Eventos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    lugar VARCHAR(255) NOT NULL
);

CREATE TABLE recursos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    categoria VARCHAR(100),
    enlace VARCHAR(255),
    fecha_actualizacion DATE,
    notas TEXT
);

CREATE TABLE Curso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    docente VARCHAR(255) NOT NULL
);

CREATE TABLE encuestas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha DATE NOT NULL
);

CREATE TABLE reportes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha DATE NOT NULL
);

CREATE TABLE soporte (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pregunta VARCHAR(255) NOT NULL,
    respuesta TEXT NOT NULL
);

CREATE TABLE categoria_biblioteca (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE biblioteca (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(50) NOT NULL UNIQUE, -- Código único del libro o recurso
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL, -- Autor del recurso
    descripcion TEXT NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- Tipo del recurso (libro, documento, etc.)
    enlace VARCHAR(255), -- Enlace adicional
    archivo_pdf VARCHAR(255), -- Nombre del archivo PDF
    fecha_publicacion DATE, -- Fecha de publicación del recurso
    categoria_id INT, -- ID de la categoría
    CONSTRAINT fk_categoria FOREIGN KEY (categoria_id) REFERENCES categoria_biblioteca(id) -- Clave foránea
);

INSERT INTO Usuario (nombre, correo, codigo, rol, contraseña) VALUES 
('admin', 'admincs@gmail.com', '1', 'administrador', '1');

INSERT INTO Notificacion (tipo, mensaje, fecha, usuarios_id) VALUES 
('info', 'Bienvenido al sistema.', '2023-03-12', 1),
('alerta', 'Reunión programada para mañana.', '2023-03-12', 2),
('recordatorio', 'Entrega de tareas el viernes.', '2023-03-12', 3);

INSERT INTO Mensaje (contenido, fechaEnvio, remitente) VALUES 
('Hola, ¿cómo están?', '2023-03-12', 1),
('Estoy aquí para ayudar.', '2023-03-12', 2),
('No olviden la tarea.', '2023-03-12', 3);

INSERT INTO Estudiante (nivelAcademico) VALUES 
('Primaria'),
('Secundaria'),
('Bachillerato');

INSERT INTO Tutor (especialidad, horariosDisponibles) VALUES 
('Matemáticas', 'Lunes a Viernes 10:00-12:00'),
('Ciencias', 'Lunes, Miércoles 14:00-16:00'),
('Literatura', 'Martes y Jueves 09:00-11:00');

INSERT INTO Sesion (fecha, hora, estado) VALUES 
('2023-03-15', '10:00:00', 'programada'),
('2023-03-16', '11:00:00', 'completada'),
('2023-03-17', '12:00:00', 'cancelada');

INSERT INTO tareas (titulo, descripcion, fecha_limite, estado) VALUES
('Tarea 1', 'Descripción de la tarea 1', '2025-05-01', 'pendiente'),
('Tarea 2', 'Descripción de la tarea 2', '2025-06-15', 'pendiente'),
('Tarea 3', 'Descripción de la tarea 3', '2025-07-20', 'completada');

INSERT INTO Material (titulo, descripcion, tipo, archivo) VALUES 
('Guía de Estudio', 'Guía para preparar el examen.', 'PDF', 'archivo1.pdf'),
('Ejercicios de Matemáticas', 'Colección de ejercicios resueltos.', 'PDF', 'archivo2.pdf'),
('Lectura de Literatura', 'Textos clásicos para estudiar.', 'PDF', 'archivo3.pdf');

INSERT INTO anuncios (nombre, fecha, hora, detalles) VALUES 
('Reunión de Padres', '2023-03-20', '18:00:00', 'Se invita a todos los padres.'),
('Inicio de Clases', '2023-03-25', '08:00:00', 'Las clases comienzan el lunes.'),
('Evaluaciones', '2023-03-30', '09:00:00', 'Se realizarán evaluaciones a final de mes.');

INSERT INTO aprendizaje (titulo, subtitulo, archivo, nombre_archivo) VALUES 
('Matemáticas Básicas', 'Conceptos Fundamentales', 'archivo_aprendizaje1.pdf', 'matematicas_basicas.pdf'),
('Historia del Arte', 'Desde la Prehistoria hasta Hoy', 'archivo_aprendizaje2.pdf', 'historia_del_arte.pdf'),
('Física Moderna', 'Teorías y Aplicaciones', 'archivo_aprendizaje3.pdf', 'fisica_moderna.pdf');

INSERT INTO Eventos (titulo, descripcion, fecha, hora, lugar) VALUES 
('Conferencia de Tecnología', 'Una charla sobre las últimas tendencias.', '2023-04-05', '10:00:00', 'Auditorio Principal'),
('Taller de Programación', 'Aprende a programar en Python.', '2023-04-10', '14:00:00', 'Sala de Computadoras'),
('Exposición de Ciencias', 'Presentación de proyectos científicos.', '2023-04-15', '09:00:00', 'Sala de Exposiciones');

INSERT INTO recursos (nombre, descripcion, categoria, enlace, fecha_actualizacion, notas) VALUES 
('Libro de Matemáticas', 'Un libro de referencia.', 'Libros', 'http://ejemplo.com/libro', '2023-03-12', 'Actualizado'),
('Software de Física', 'Herramienta para simulaciones.', 'Software', 'http://ejemplo.com/software', '2023-03-15', 'Nueva versión disponible'),
('Artículos de Literatura', 'Colección de artículos.', 'Artículos', 'http://ejemplo.com/articulos', '2023-03-18', 'Revisar');

INSERT INTO Curso (nombre, descripcion, fecha_inicio, fecha_fin, docente) VALUES 
('Curso de Matemáticas Avanzadas', 'Curso para profundizar en matemáticas.', '2023-04-01', '2023-06-30', 'Prof. Ana Gómez'),
('Curso de Historia Universal', 'Un recorrido por la historia del mundo.', '2023-04-15', '2023-07-15', 'Prof. Luis Martínez'),
('Curso de Programación en Python', 'Aprende a programar desde cero.', '2023-05-01', '2023-08-01', 'Prof. Juan Pérez');

INSERT INTO encuestas (titulo, descripcion, fecha) VALUES 
('Encuesta de Satisfacción', 'Queremos conocer tu opinión.', '2023-03-12'),
('Encuesta de Necesidades Educativas', 'Identificamos áreas de mejora.', '2023-03-15'),
('Encuesta de Clima Escolar', 'Evaluamos el ambiente escolar.', '2023-03-20');

INSERT INTO reportes (titulo, descripcion, fecha) VALUES 
('Reporte de Asistencia', 'Asistencia de estudiantes en marzo.', '2023-03-12'),
('Reporte de Evaluación', 'Resultados de las evaluaciones trimestrales.', '2023-03-15'),
('Reporte de Actividades', 'Actividades realizadas en el primer trimestre.', '2023-03-20');

INSERT INTO soporte (pregunta, respuesta) VALUES 
('¿Cómo recupero mi contraseña?', 'Puedes recuperar tu contraseña desde la página de inicio.'),
('¿Dónde encuentro los materiales de estudio?', 'Los materiales están disponibles en la sección de recursos.'),
('¿Cómo contactar a mi tutor?', 'Puedes contactarlo a través del chat en la plataforma.');

INSERT INTO categoria_biblioteca (nombre, descripcion) VALUES 
('Libros', 'Categoría que incluye libros de texto y referencia.'),
('Artículos', 'Colección de artículos académicos y de investigación.'),
('Software', 'Herramientas y programas educativos.');

INSERT INTO biblioteca (codigo, titulo, autor, descripcion, tipo, enlace, archivo_pdf, fecha_publicacion, categoria_id) VALUES 
('B001', 'Matemáticas para Todos', 'Autor A', 'Un libro básico de matemáticas.', 'Libro', 'http://ejemplo.com/libro1', 'libro1.pdf', '2022-01-01', 1),
('A001', 'Revista de Ciencias', 'Autor B', 'Revista de investigación científica.', 'Artículo', 'http://ejemplo.com/revista1', 'revista1.pdf', '2022-02-01', 2),
('S001', 'Programa de Matemáticas', 'Autor C', 'Software educativo para matemáticas.', 'Software', 'http://ejemplo.com/software1', 'software1.pdf', '2022-03-01', 3);
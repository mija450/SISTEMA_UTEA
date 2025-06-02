create database colegio
use colegio
/*
private user = admincs;
private host = localhost;
private password = Qxu@zRd7A^BS;
private name = colegio;
*/

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

CREATE TABLE Docente (
    idDocente INT PRIMARY KEY,
    nombreDocente VARCHAR(255) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    materia VARCHAR(255) NOT NULL,
    campo VARCHAR(255) NOT NULL,
    horariosDisponibles TEXT NOT NULL,
    aula VARCHAR(100) NOT NULL,
    FOREIGN KEY (idDocente) REFERENCES Usuario(idUsuario)
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
    CONSTRAINT fk_categoria
        FOREIGN KEY (categoria_id) REFERENCES categoria_biblioteca(id) -- Clave foránea
);

CREATE TABLE recuperaciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  correo VARCHAR(100) NOT NULL,
  codigo VARCHAR(10) NOT NULL,
  expiracion DATETIME NOT NULL,
  usado BOOLEAN DEFAULT FALSE
);

CREATE TABLE actividades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(100) NOT NULL,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Aula (
    idAula INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    capacidad INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    recursos TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE calendario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE asistencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    status ENUM('Presente', 'Ausente', 'Tarde') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO Usuario (nombre, correo, codigo, rol, contraseña) VALUES 
('admin', 'admincs@gmail.com', '1', 'administrador', '1'),
('Ana Martínez', 'ana.martinez@example.com', 'DOC001', 'docente', 'password1'),
('Carlos Pérez', 'carlos.perez@example.com', 'DOC002', 'docente', 'password2'),
('Lucía Gutiérrez', 'lucia.gutierrez@example.com', 'DOC003', 'docente', 'password3'),
('Jorge Ramírez', 'jorge.ramirez@example.com', 'DOC004', 'docente', 'password4'),
('María López', 'maria.lopez@example.com', 'DOC005', 'docente', 'password5'),
('Luis Torres', 'luis.torres@example.com', 'DOC006', 'docente', 'password6'),
('Carmen Rodríguez', 'carmen.rodriguez@example.com', 'DOC007', 'docente', 'password7'),
('Pedro Castillo', 'pedro.castillo@example.com', 'DOC008', 'docente', 'password8'),
('Valeria Salas', 'valeria.salas@example.com', 'DOC009', 'docente', 'password9'),
('Hugo Fernández', 'hugo.fernandez@example.com', 'DOC010', 'docente', 'password10');

INSERT INTO Mensaje (contenido, fechaEnvio, remitente) VALUES 
('Hola, ¿cómo están?', '2023-03-12', 1),
('Estoy aquí para ayudar.', '2023-03-12', 1),
('No olviden la tarea.', '2023-03-12', 1);

INSERT INTO Sesion (fecha, hora, estado) VALUES 
('2023-03-15', '10:00:00', 'programada'),
('2023-03-16', '11:00:00', 'completada'),
('2023-03-17', '12:00:00', 'cancelada');

INSERT INTO tareas (titulo, descripcion, fecha_limite, estado) VALUES
('Tarea 1', 'Descripción de la tarea 1', '2025-05-01', 'pendiente'),
('Tarea 2', 'Descripción de la tarea 2', '2025-06-15', 'pendiente'),
('Tarea 3', 'Descripción de la tarea 3', '2025-07-20', 'completada');

INSERT INTO Estudiante (nivelAcademico) VALUES 
('Primaria'),
('Secundaria'),
('Bachillerato');

INSERT INTO Tutor (especialidad, horariosDisponibles) VALUES 
('Matemáticas', 'Lunes a Viernes 10:00-12:00'),
('Ciencias', 'Lunes, Miércoles 14:00-16:00'),
('Literatura', 'Martes y Jueves 09:00-11:00');

INSERT INTO Docente (idDocente, nombreDocente, dni, codigo, materia, campo, horariosDisponibles, aula) VALUES
(1, 'Ana Martínez', '73214567', 'DOC001', 'Matemática', 'Ciencias', 'Lunes y miércoles 8:00-10:00', 'Aula 101'),
(2, 'Carlos Pérez', '74829123', 'DOC002', 'Comunicación', 'Lengua', 'Martes y jueves 9:00-11:00', 'Aula 102'),
(3, 'Lucía Gutiérrez', '75432189', 'DOC003', 'Biología', 'Ciencias Naturales', 'Lunes y viernes 10:00-12:00', 'Aula 103'),
(4, 'Jorge Ramírez', '76321984', 'DOC004', 'Física', 'Ciencias', 'Miércoles 8:00-12:00', 'Aula 104'),
(5, 'María López', '71239845', 'DOC005', 'Historia', 'Ciencias Sociales', 'Martes y jueves 13:00-15:00', 'Aula 105'),
(6, 'Luis Torres', '76891234', 'DOC006', 'Inglés', 'Idiomas', 'Lunes y miércoles 15:00-17:00', 'Aula 106'),
(7, 'Carmen Rodríguez', '73456789', 'DOC007', 'Educación Física', 'Educación Física', 'Viernes 8:00-12:00', 'Patio Principal'),
(8, 'Pedro Castillo', '72564123', 'DOC008', 'Química', 'Ciencias Naturales', 'Martes y viernes 10:00-12:00', 'Laboratorio 1'),
(9, 'Valeria Salas', '78912345', 'DOC009', 'Arte', 'Arte y Cultura', 'Miércoles 14:00-16:00', 'Aula de Arte'),
(10, 'Hugo Fernández', '79456123', 'DOC010', 'Computación', 'Tecnología', 'Lunes a viernes 8:00-9:00', 'Sala de Cómputo');

INSERT INTO aprendizaje (titulo, subtitulo, archivo, nombre_archivo) VALUES 
('Matemáticas Básicas', 'Conceptos Fundamentales', 'archivo_aprendizaje1.pdf', 'matematicas_basicas.pdf'),
('Historia del Arte', 'Desde la Prehistoria hasta Hoy', 'archivo_aprendizaje2.pdf', 'historia_del_arte.pdf'),
('Física Moderna', 'Teorías y Aplicaciones', 'archivo_aprendizaje3.pdf', 'fisica_moderna.pdf');

INSERT INTO Eventos (titulo, descripcion, fecha, hora, lugar) VALUES 
('Conferencia de Tecnología', 'Una charla sobre las últimas tendencias.', '2023-04-05', '10:00:00', 'Auditorio Principal'),
('Taller de Programación', 'Aprende a programar en Python.', '2023-04-10', '14:00:00', 'Sala de Computadoras'),
('Exposición de Ciencias', 'Presentación de proyectos científicos.', '2023-04-15', '09:00:00', 'Sala de Exposiciones');

INSERT INTO Material (titulo, descripcion, tipo, archivo) VALUES 
('Guía de Estudio', 'Guía para preparar el examen.', 'PDF', 'archivo1.pdf'),
('Ejercicios de Matemáticas', 'Colección de ejercicios resueltos.', 'PDF', 'archivo2.pdf'),
('Lectura de Literatura', 'Textos clásicos para estudiar.', 'PDF', 'archivo3.pdf');

INSERT INTO anuncios (nombre, fecha, hora, detalles) VALUES 
('Reunión de Padres', '2023-03-20', '18:00:00', 'Se invita a todos los padres.'),
('Inicio de Clases', '2023-03-25', '08:00:00', 'Las clases comienzan el lunes.'),
('Evaluaciones', '2023-03-30', '09:00:00', 'Se realizarán evaluaciones a final de mes.');

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

INSERT INTO Notificacion (tipo, mensaje, fecha, usuarios_id) VALUES
('Sistema', 'Tu contraseña ha sido actualizada exitosamente.', '2025-05-16', NULL),
('Recordatorio', 'Tienes una tarea pendiente por entregar mañana.', '2025-05-16', NULL),
('Alerta', 'Se detectó un inicio de sesión desde un nuevo dispositivo.', '2025-05-15', NULL),
('Información', 'Nuevo material de estudio disponible en el curso de Matemáticas.', '2025-05-14', NULL);

INSERT INTO Actividades (titulo, fecha, hora, descripcion, created_at) VALUES
('Clase de Matemáticas', '2025-05-20', '08:00:00', 'Introducción a álgebra', NOW()),
('Clase de Física', '2025-05-21', '10:00:00', 'Dinámica y fuerzas', NOW()),
('Clase de Química', '2025-05-22', '09:00:00', 'Química orgánica básica', NOW()),
('Clase de Biología', '2025-05-23', '11:00:00', 'Células y tejidos', NOW()),
('Clase de Lenguaje', '2025-05-24', '08:30:00', 'Análisis de textos', NOW()),
('Clase de Historia', '2025-05-25', '10:30:00', 'Historia contemporánea', NOW()),
('Clase de Geografía', '2025-05-26', '09:30:00', 'Geografía física', NOW()),
('Clase de Educación Física', '2025-05-27', '07:00:00', 'Entrenamiento básico', NOW()),
('Clase de Arte', '2025-05-28', '11:30:00', 'Técnicas de pintura', NOW()),
('Clase de Informática', '2025-05-29', '08:45:00', 'Introducción a programación', NOW());

INSERT INTO Aula (nombre, capacidad, tipo, recursos) VALUES 
('Aula 101', 30, 'Teórica', 'Proyector, Pizarrón'),
('Aula 102', 25, 'Laboratorio', 'Computadoras, Materiales de laboratorio'),
('Aula 103', 50, 'Auditorio', 'Sistema de sonido, Proyector'),
('Aula 104', 20, 'Teórica', 'Pizarrón, Sillas'),
('Aula 105', 40, 'Laboratorio', 'Materiales de ciencias');

INSERT INTO calendario (title, start_date, end_date, description) VALUES
('Evento 1', '2023-10-01 10:00:00', '2023-10-01 12:00:00', 'Descripción del evento 1'),
('Evento 2', '2023-10-05 14:00:00', '2023-10-05 16:00:00', 'Descripción del evento 2'),
('Evento 3', '2023-10-10 09:00:00', '2023-10-10 11:00:00', 'Descripción del evento 3'),
('Evento 4', '2023-10-15 13:00:00', '2023-10-15 15:00:00', 'Descripción del evento 4'),
('Evento 5', '2023-10-20 08:00:00', '2023-10-20 10:00:00', 'Descripción del evento 5'),
('Evento 6', '2023-10-25 11:00:00', '2023-10-25 13:00:00', 'Descripción del evento 6'),
('Evento 7', '2023-10-30 15:00:00', '2023-10-30 17:00:00', 'Descripción del evento 7'),
('Evento 8', '2023-11-01 10:00:00', '2023-11-01 12:00:00', 'Descripción del evento 8'),
('Evento 9', '2023-11-05 14:00:00', '2023-11-05 16:00:00', 'Descripción del evento 9'),
('Evento 10', '2023-11-10 09:00:00', '2023-11-10 11:00:00', 'Descripción del evento 10');

INSERT INTO asistencias (subject, date, status) VALUES
('Matemáticas', '2023-10-01', 'Presente'),
('Historia', '2023-10-01', 'Ausente'),
('Ciencias', '2023-10-02', 'Presente'),
('Literatura', '2023-10-02', 'Tarde'),
('Geografía', '2023-10-03', 'Presente'),
('Arte', '2023-10-03', 'Ausente'),
('Educación Física', '2023-10-04', 'Presente'),
('Inglés', '2023-10-04', 'Tarde'),
('Música', '2023-10-05', 'Presente'),
('Física', '2023-10-05', 'Ausente');

select*from usuario;
select*from notificacion;
select*from chat;
select*from mensaje;
select*from estudiante;
select*from tutor;
select*from sesion;
select*from material;

-- /tablas interfaz(home)
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
select*from docente;
select*from aula;
select*from calendario;
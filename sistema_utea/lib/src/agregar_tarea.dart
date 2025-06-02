import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'tareas.dart'; // Importa la pantalla de tareas
import 'package:file_picker/file_picker.dart'; // Importa file_picker

class AgregarTareaScreen extends StatefulWidget {
  const AgregarTareaScreen({Key? key}) : super(key: key);

  @override
  _AgregarTareaScreenState createState() => _AgregarTareaScreenState();
}

class _AgregarTareaScreenState extends State<AgregarTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _cursoSeleccionado;
  List<dynamic> _cursos = [];
  String? _filePath; // Para almacenar la ruta del archivo PDF

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES';
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    // Carga de cursos de ejemplo
    _cursos = [
      {"idCurso": 1, "nombre": "Matemáticas Básicas"},
      {"idCurso": 2, "nombre": "Historia del Arte"},
      {"idCurso": 3, "nombre": "Programación en Python"},
      {"idCurso": 4, "nombre": "Física Avanzada"},
      {"idCurso": 5, "nombre": "Literatura Contemporánea"},
      {"idCurso": 6, "nombre": "Comunicación Efectiva"},
      {"idCurso": 7, "nombre": "Álgebra"},
      {"idCurso": 8, "nombre": "Geometría"},
    ];
    setState(() {}); // Actualiza el estado después de cargar los cursos
  }

  Future<void> _seleccionarFecha() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (pickedDate != null) {
      setState(() {
        _fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _subirArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path; // Almacena la ruta del archivo PDF
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Archivo seleccionado: ${result.files.single.name}")),
      );
    }
  }

  void _guardarTarea() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_tarea.php");
    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['titulo'] = _tituloController.text.trim();
      request.fields['curso'] = _cursoSeleccionado ?? '';
      request.fields['descripcion'] = _descripcionController.text.trim();
      request.fields['fechaEntrega'] = _fechaController.text.trim();

      // Agregar archivo PDF si se seleccionó
      if (_filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('archivo', _filePath!));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tarea agregada con éxito")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TareasScreen(
              role: "docente", // Cambia esto según el rol real
              name: "Nombre Docente", // Cambia esto según el nombre real
              isDarkMode: false,
              onThemeChanged: (val) {
                // Implementa la lógica necesaria si es necesario
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data["message"] ?? "Desconocido"}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _confirmarGuardado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue[50], // Color de fondo
        title: const Text("Confirmación", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Desea guardar la tarea?"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancelar
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Color del botón Cancelar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "❌ Cancelar",
              style: TextStyle(color: Colors.white), // Texto en blanco
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmar
              _guardarTarea();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Color del botón Aceptar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "✅ Aceptar",
              style: TextStyle(color: Colors.white), // Texto en blanco
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Nueva Tarea"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue[50], // Fondo azul
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "📚 Registrar Tarea",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título de la Tarea",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Ingrese un título" : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _cursoSeleccionado,
                  items: _cursos.map((curso) {
                    return DropdownMenuItem<String>(
                      value: curso["idCurso"].toString(),
                      child: Text(curso["nombre"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _cursoSeleccionado = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Seleccionar Curso",
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ? "Seleccione un curso" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Fecha de Entrega",
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _seleccionarFecha,
                  validator: (value) => value!.isEmpty ? "Seleccione la fecha de entrega" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: "Descripción de la Tarea",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? "Ingrese la descripción" : null,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _subirArchivo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Subir PDF", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _confirmarGuardado,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.blue, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Guardar Tarea", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
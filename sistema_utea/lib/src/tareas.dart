import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart'; // Importa el paquete
import 'configuraciones_tareas.dart';

class TareasScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const TareasScreen({
    Key? key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  List<dynamic> tareas = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchTareas();
  }

  Future<void> _fetchTareas() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/tareas.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            tareas = data['data']; // Lista de tareas
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ayuda para Agregar Tarea'),
          content: const Text(
            'Para agregar una nueva tarea, asegúrate de ingresar un título y una descripción. '
            'Puedes seleccionar una fecha de entrega y, si deseas, adjuntar un archivo PDF. '
            'Una vez que hayas completado todos los campos, haz clic en "Agregar" para guardar la tarea.',
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "estudiante"
        ? "Sesión activa del alumno: ${widget.name}"
        : "Sesión activa del docente: ${widget.name}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.role.toLowerCase() == "docente")
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Configuraciones de Tareas",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionesTareasScreen(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.warning),
            tooltip: "Agregar Tarea",
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.yellowAccent], // Colores de degradado
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(child: Text("Error al cargar tareas", style: TextStyle(color: Colors.red)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen de portada
                      Image.asset('assets/images/comunicados_portada.png'),
                      const SizedBox(height: 16),
                      // Texto de sesión activa
                      Text(
                        sessionText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      // Mensaje de advertencia
                      const Text(
                        '⚠️ Recuerda que todas las tareas deben ser completadas antes de la fecha de entrega.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      // Título de tareas pendientes
                      const Text(
                        'Tareas Pendientes',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tareas.length,
                          itemBuilder: (context, index) {
                            final tarea = tareas[index];
                            return _buildTaskItem(
                              tarea['titulo'] ?? 'Título no disponible',
                              "${tarea['descripcion'] ?? 'Descripción no disponible'}\nEntrega: ${tarea['fecha_limite'] ?? 'Fecha no disponible'}",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTaskItem(String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        subtitle: Text(description, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
      ),
    );
  }
}
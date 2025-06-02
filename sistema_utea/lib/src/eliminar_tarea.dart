import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tareas.dart'; // Para navegar a TareasScreen
// Si no lo usas directamente, quita la import

class EliminarTareaScreen extends StatefulWidget {
  const EliminarTareaScreen({Key? key}) : super(key: key);

  @override
  _EliminarTareaScreenState createState() => _EliminarTareaScreenState();
}

class _EliminarTareaScreenState extends State<EliminarTareaScreen> {
  List<dynamic> tareas = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchTareas();
  }

  // 1. Obtener todas las tareas desde "tareas.php"
  Future<void> _fetchTareas() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/tareas.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            tareas = data['data'];
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
    }
  }

  // 2. Confirmación antes de eliminar
  void _confirmDelete(String idTarea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmación"),
        content: const Text("¿Desea eliminar esta tarea?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sí"),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteTarea(idTarea);
      }
    });
  }

  // 3. Eliminar la tarea en la BD y volver a TareasScreen refrescando
  Future<void> _deleteTarea(String idTarea) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_tarea.php?id=$idTarea");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tarea eliminada con éxito")),
          );
          // Aquí, en vez de solo pop(), navegamos a TareasScreen con pushReplacement
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TareasScreen(
                role: "docente",
                name: "Nombre Docente",
                isDarkMode: false,
                onThemeChanged: _dummyOnThemeChanged,
              ),
            ),
          );
        } else {
          final errorMsg = data['error'] ?? "Error desconocido";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $errorMsg")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error en el servidor: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Dummy callback para el onThemeChanged
  static void _dummyOnThemeChanged(bool val) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eliminar Tarea"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar tareas"))
              : tareas.isEmpty
                  ? const Center(child: Text("No hay tareas para eliminar"))
                  : ListView.builder(
                      itemCount: tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = tareas[index];
                        return Card(
                          child: ListTile(
                            title: Text(tarea['curso'] ?? ""),
                            subtitle: Text(
                              "${tarea['descripcion'] ?? ''}\nEntrega: ${tarea['fechaEntrega'] ?? ''}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(tarea['idTarea'].toString());
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

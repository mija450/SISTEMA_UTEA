import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EditarTareaScreen extends StatefulWidget {
  const EditarTareaScreen({Key? key}) : super(key: key);

  @override
  _EditarTareaScreenState createState() => _EditarTareaScreenState();
}

class _EditarTareaScreenState extends State<EditarTareaScreen> {
  List<dynamic> tareas = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchTareas();
  }

  // Obtener todas las tareas desde "tareas.php"
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

  // Navegar a la pantalla de edición de tarea
  void _navigateToEditTask(String tareaId, String titulo, String descripcion, String fechaLimite, String cursoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarTareaDetailScreen(
          tareaId: tareaId,
          titulo: titulo,
          descripcion: descripcion,
          fechaLimite: fechaLimite,
          cursoId: cursoId,
        ),
      ),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tarea editada con éxito")),
        );
        _fetchTareas(); // Refresca la lista de tareas después de editar
      }
    });
  }

  // Confirmación antes de eliminar
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
            onPressed: () {
              Navigator.of(context).pop(true);
              _deleteTarea(idTarea);
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }

  // Eliminar la tarea en la BD
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
          _fetchTareas(); // Refresca la lista de tareas después de eliminar
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Tarea a Editar'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar tareas"))
              : tareas.isEmpty
                  ? const Center(child: Text("No hay tareas para editar"))
                  : ListView.builder(
                      itemCount: tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = tareas[index];
                        return Card(
                          child: ListTile(
                            title: Text(tarea['titulo'] ?? ""),
                            subtitle: Text(
                              "${tarea['descripcion'] ?? ''}\nEntrega: ${DateFormat.yMd().format(DateTime.parse(tarea['fecha_limite']))}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _navigateToEditTask(
                                      tarea['idTarea'].toString(),
                                      tarea['titulo'],
                                      tarea['descripcion'],
                                      tarea['fecha_limite'],
                                      tarea['curso_id'],
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(tarea['idTarea'].toString());
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class EditarTareaDetailScreen extends StatefulWidget {
  final String tareaId;
  final String titulo;
  final String descripcion;
  final String fechaLimite;
  final String cursoId;

  const EditarTareaDetailScreen({
    Key? key,
    required this.tareaId,
    required this.titulo,
    required this.descripcion,
    required this.fechaLimite,
    required this.cursoId,
  }) : super(key: key);

  @override
  _EditarTareaDetailScreenState createState() => _EditarTareaDetailScreenState();
}

class _EditarTareaDetailScreenState extends State<EditarTareaDetailScreen> {
  late String titulo;
  late String descripcion;
  late DateTime fechaLimite;

  @override
  void initState() {
    super.initState();
    titulo = widget.titulo;
    descripcion = widget.descripcion;
    fechaLimite = DateTime.parse(widget.fechaLimite);
  }

  Future<void> _updateTarea() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/editar_tarea.php");
    
    try {
      final response = await http.post(url, body: {
        'id': widget.tareaId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_limite': fechaLimite.toIso8601String(),
        'curso_id': widget.cursoId, // Asegúrate de enviar el ID del curso
      });

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true); // Regresar a la pantalla anterior
      } else {
        print("Error al actualizar la tarea: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Título'),
              onChanged: (value) {
                titulo = value;
              },
              controller: TextEditingController(text: titulo),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Descripción'),
              onChanged: (value) {
                descripcion = value;
              },
              controller: TextEditingController(text: descripcion),
            ),
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: fechaLimite,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    fechaLimite = picked;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Fecha Limite',
                    hintText: DateFormat.yMd().format(fechaLimite),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateTarea();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
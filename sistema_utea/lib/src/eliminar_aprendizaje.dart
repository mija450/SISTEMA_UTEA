import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EliminarCursoScreen extends StatefulWidget {
  const EliminarCursoScreen({Key? key}) : super(key: key);

  @override
  _EliminarCursoScreenState createState() => _EliminarCursoScreenState();
}

class _EliminarCursoScreenState extends State<EliminarCursoScreen> {
  List<dynamic> cursos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCursos();
  }

  Future<void> _fetchCursos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/aprendizaje.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            cursos = data['data'];
            isLoading = false;
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

  Future<void> _deleteCurso(String id) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_aprendizaje.php?id=$id");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Curso eliminado con éxito")),
          );
          // Al eliminar, regresa inmediatamente a la pantalla de Aprendizaje con resultado true.
          Navigator.pop(context, true);
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

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmación"),
        content: const Text("¿Desea eliminar este curso?"),
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
        _deleteCurso(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eliminar Curso"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar cursos"))
              : cursos.isEmpty
                  ? const Center(child: Text("No hay cursos para eliminar"))
                  : ListView.builder(
                      itemCount: cursos.length,
                      itemBuilder: (context, index) {
                        final curso = cursos[index];
                        return Card(
                          child: ListTile(
                            title: Text(curso['titulo'] ?? ""),
                            subtitle: Text(curso['subtitulo'] ?? ""),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(curso['id'].toString());
                              },
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_back),
        onPressed: () {
          // Si el usuario decide volver sin eliminar, se retorna false.
          Navigator.pop(context, false);
        },
      ),
    );
  }
}

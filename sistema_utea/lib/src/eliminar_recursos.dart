import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recursos.dart';

class EliminarRecursoScreen extends StatefulWidget {
  const EliminarRecursoScreen({Key? key}) : super(key: key);

  @override
  _EliminarRecursoScreenState createState() => _EliminarRecursoScreenState();
}

class _EliminarRecursoScreenState extends State<EliminarRecursoScreen> {
  List<dynamic> recursos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
  }

  // Cargar todos los recursos desde "recursos.php"
  Future<void> _fetchRecursos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/recursos.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            recursos = data['data'];
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

  // Confirmar antes de eliminar
  void _confirmDelete(String idRecursos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmación"),
        content: const Text("¿Desea eliminar este recurso?"),
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
        _deleteRecurso(idRecursos);
      }
    });
  }

  // Llamar a eliminar_recursos.php
  Future<void> _deleteRecurso(String idRecursos) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_recursos.php?id=$idRecursos");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recurso eliminado con éxito")),
          );
          // Navegar a RecursosScreen refrescando
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RecursosScreen(
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
            SnackBar(content: Text("Error al eliminar: $errorMsg")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error del servidor: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  static void _dummyOnThemeChanged(bool val) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eliminar Recurso")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar recursos"))
              : recursos.isEmpty
                  ? const Center(child: Text("No hay recursos para eliminar"))
                  : ListView.builder(
                      itemCount: recursos.length,
                      itemBuilder: (context, index) {
                        final recurso = recursos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            title: Text(
                              recurso['nombre'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(recurso['link'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(recurso['idRecursos'].toString());
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

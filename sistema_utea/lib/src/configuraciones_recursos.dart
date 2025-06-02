import 'package:flutter/material.dart';
import 'agregar_recursos.dart';
import 'editar_recurso.dart';
import 'eliminar_recursos.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfiguracionesRecursosScreen extends StatefulWidget {
  const ConfiguracionesRecursosScreen({Key? key, required bool isDarkMode, required Function(bool p1) onThemeChanged}) : super(key: key);

  @override
  _ConfiguracionesRecursosScreenState createState() => _ConfiguracionesRecursosScreenState();
}

class _ConfiguracionesRecursosScreenState extends State<ConfiguracionesRecursosScreen> {
  List<dynamic> recursos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRecursos(); // Cargar recursos al inicio
  }

  Future<void> _fetchRecursos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/recursos.php");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            recursos = data['data'];
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
      print("Error al obtener recursos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones de Recursos"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📚 Gestión de Recursos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text("Error al cargar recursos"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recursos.length,
                          itemBuilder: (context, index) {
                            return _buildRecursoCard(recursos[index]);
                          },
                        ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.add,
                label: "Agregar Recurso",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarRecursoScreen(),
                    ),
                  );
                  if (result == true) {
                    _fetchRecursos(); // Recargar recursos después de agregar
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecursoCard(Map<String, dynamic> recurso) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(recurso['nombre'] ?? "Sin título"),
        subtitle: Text("Link: ${recurso['link'] ?? "Sin enlace"}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarRecursoScreen(
                      id: recurso['id'].toString(),
                      nombre: recurso['nombre'],
                      link: recurso['link'],
                    ),
                  ),
                );
                if (result == true) {
                  _fetchRecursos(); // Recargar recursos después de editar
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeletion(recurso);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(Map<String, dynamic> recurso) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar este recurso?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo sin eliminar
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteRecurso(recurso['id'].toString()); // Asegúrate de usar el ID correcto
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecurso(String id) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_recursos.php");
    try {
      final response = await http.delete(url, 
        body: json.encode({"id": id}), 
        headers: {
          "Content-Type": "application/json",
        }
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recurso eliminado con éxito")),
        );
        _fetchRecursos(); // Recargar recursos después de eliminar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar recurso: ${data["error"] ?? ""}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onPressed,
      ),
    );
  }
}
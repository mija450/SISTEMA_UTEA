import 'package:flutter/material.dart';
import 'agregar_aprendizaje.dart';
import 'editar_aprendizaje.dart';
import 'eliminar_aprendizaje.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfiguracionesAprendizajeScreen extends StatefulWidget {
  const ConfiguracionesAprendizajeScreen({Key? key, required bool isDarkMode, required Function(bool p1) onThemeChanged}) : super(key: key);

  @override
  _ConfiguracionesAprendizajeScreenState createState() => _ConfiguracionesAprendizajeScreenState();
}

class _ConfiguracionesAprendizajeScreenState extends State<ConfiguracionesAprendizajeScreen> {
  List<dynamic> aprendizajes = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAprendizajes(); // Cargar aprendizajes al inicio
  }

  Future<void> _fetchAprendizajes() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/aprendizaje.php");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            aprendizajes = data['data'];
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
      print("Error al obtener aprendizajes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones de Aprendizaje"),
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
                '📚 Gestión de Aprendizajes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text("Error al cargar aprendizajes"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: aprendizajes.length,
                          itemBuilder: (context, index) {
                            return _buildAprendizajeCard(aprendizajes[index]);
                          },
                        ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.add,
                label: "Agregar Aprendizaje",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarAprendizajeScreen(),
                    ),
                  );
                  if (result == true) {
                    _fetchAprendizajes(); // Recargar aprendizajes después de agregar
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

  Widget _buildAprendizajeCard(Map<String, dynamic> aprendizaje) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(aprendizaje['titulo'] ?? "Sin título"),
        subtitle: Text("Subtítulo: ${aprendizaje['subtitulo']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarAprendizajeScreen(aprendizaje: aprendizaje),
                  ),
                );
                if (result == true) {
                  _fetchAprendizajes(); // Recargar aprendizajes después de editar
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeletion(aprendizaje);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(Map<String, dynamic> aprendizaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar este aprendizaje?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo sin eliminar
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteAprendizaje(aprendizaje['id'].toString()); // Asegúrate de usar el ID correcto
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAprendizaje(String id) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_aprendizaje.php");
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
          const SnackBar(content: Text("Aprendizaje eliminado con éxito")),
        );
        _fetchAprendizajes(); // Recargar aprendizajes después de eliminar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar aprendizaje: ${data["error"] ?? ""}")),
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
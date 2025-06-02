import 'package:flutter/material.dart';
import 'agregar_anuncio.dart';
import 'editar_anuncio.dart';
import 'eliminar_anuncio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfiguracionesComunicacionScreen extends StatefulWidget {
  const ConfiguracionesComunicacionScreen({Key? key}) : super(key: key);

  @override
  _ConfiguracionesComunicacionScreenState createState() => _ConfiguracionesComunicacionScreenState();
}

class _ConfiguracionesComunicacionScreenState extends State<ConfiguracionesComunicacionScreen> {
  List<dynamic> anuncios = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAnuncios(); // Cargar anuncios al inicio
  }

  Future<void> _fetchAnuncios() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/comunicacion.php");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            anuncios = data['data'];
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
      print("Error al obtener anuncios: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones de Comunicación"),
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
                '📢 Gestión de Anuncios',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text("Error al cargar anuncios"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: anuncios.length,
                          itemBuilder: (context, index) {
                            return _buildAnnouncementCard(anuncios[index]);
                          },
                        ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.add,
                label: "Agregar Anuncio",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarAnuncioScreen(),
                    ),
                  );
                  if (result == true) {
                    _fetchAnuncios(); // Recargar anuncios después de agregar
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

  Widget _buildAnnouncementCard(Map<String, dynamic> anuncio) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(anuncio['nombre'] ?? "Sin título"),
        subtitle: Text("Fecha: ${anuncio['fecha']}\nHora: ${anuncio['hora']}\nDetalles: ${anuncio['detalles']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarAnuncioScreen(anuncio: anuncio), // Asegúrate de pasar el anuncio
                  ),
                );
                if (result == true) {
                  _fetchAnuncios(); // Recargar anuncios después de editar
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeletion(anuncio);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(Map<String, dynamic> anuncio) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar este anuncio?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo sin eliminar
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteAnuncio(anuncio['id'].toString()); // Asegúrate de usar el ID correcto
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnuncio(String id) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_anuncio.php");
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
          const SnackBar(content: Text("Anuncio eliminado con éxito")),
        );
        _fetchAnuncios(); // Recargar anuncios después de eliminar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar anuncio: ${data["error"] ?? ""}")),
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
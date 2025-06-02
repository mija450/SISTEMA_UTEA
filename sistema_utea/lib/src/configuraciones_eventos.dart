import 'package:flutter/material.dart';
import 'agregar_evento.dart'; // Importamos la pantalla para agregar eventos
import 'editar_evento.dart'; // Importamos la pantalla para editar eventos
import 'eliminar_evento.dart'; // Importamos la pantalla para eliminar eventos
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfiguracionesEventosScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ConfiguracionesEventosScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _ConfiguracionesEventosScreenState createState() =>
      _ConfiguracionesEventosScreenState();
}

class _ConfiguracionesEventosScreenState extends State<ConfiguracionesEventosScreen> {
  List<dynamic> eventos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchEventos(); // Cargar eventos al inicio
  }

  Future<void> _fetchEventos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eventos.php");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            eventos = data['data'];
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
      print("Error al obtener eventos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones de Eventos"),
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
                '📅 Gestión de Eventos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Administra tus eventos de manera eficiente. Selecciona una de las opciones a continuación:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text("Error al cargar eventos"))
                      : eventos.isEmpty
                          ? const Center(child: Text("No hay eventos disponibles"))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                return _buildEventoCard(eventos[index]);
                              },
                            ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.add,
                label: "Agregar Evento",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarEventoScreen(),
                    ),
                  );
                  if (result == true) {
                    _fetchEventos(); // Recargar eventos después de agregar
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

  Widget _buildEventoCard(Map<String, dynamic> evento) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(evento['titulo'] ?? "Sin título", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fecha: ${evento['fecha'] ?? ''}"),
            Text("Hora: ${evento['hora'] ?? ''}"),
            Text("Lugar: ${evento['lugar'] ?? ''}"),
            const SizedBox(height: 4),
            Text("Descripción: ${evento['descripcion'] ?? ''}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarEventoScreen(evento: evento), // Asegúrate de pasar el evento
                  ),
                );
                if (result == true) {
                  _fetchEventos(); // Recargar eventos después de editar
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeletion(evento);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(Map<String, dynamic> evento) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar este evento?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo sin eliminar
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteEvento(evento['id'].toString()); // Asegúrate de usar el ID correcto
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvento(String idEvento) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_evento.php?id=$idEvento");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Evento eliminado con éxito")),
          );
          _fetchEventos(); // Recargar eventos después de eliminar
        } else {
          final errorMsg = data['error'] ?? "Error desconocido";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al eliminar: $errorMsg")),
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
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'eventos.dart'; // Para volver a la lista de eventos después de eliminar

class EliminarEventoScreen extends StatefulWidget {
  const EliminarEventoScreen({Key? key}) : super(key: key);

  @override
  _EliminarEventoScreenState createState() => _EliminarEventoScreenState();
}

class _EliminarEventoScreenState extends State<EliminarEventoScreen> {
  List<dynamic> eventos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  // 1. Obtener la lista de eventos desde "eventos.php"
  Future<void> _fetchEventos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eventos.php");
    try {
      final response = await http.get(url);
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
    }
  }

  // 2. Mostrar ventana de confirmación antes de eliminar
  void _confirmDelete(String idEvento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmación"),
        content: const Text("¿Desea eliminar este evento?"),
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
        _deleteEvento(idEvento);
      }
    });
  }

  // 3. Eliminar el evento en la BD y regresar a EventosScreen
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
          // Volver a la pantalla principal de eventos con pushReplacement
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EventosScreen(
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
          SnackBar(content: Text("Error en el servidor: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Callback dummy para onThemeChanged
  static void _dummyOnThemeChanged(bool val) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eliminar Evento")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar eventos"))
              : eventos.isEmpty
                  ? const Center(child: Text("No hay eventos para eliminar"))
                  : ListView.builder(
                      itemCount: eventos.length,
                      itemBuilder: (context, index) {
                        final evento = eventos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            title: Text(
                              evento['nombre'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${evento['descripcion'] ?? ''}\nFecha: ${evento['fecha'] ?? ''}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(evento['idEvento'].toString()),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

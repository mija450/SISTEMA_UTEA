import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'configuraciones_recursos.dart';

class RecursosScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const RecursosScreen({
    Key? key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _RecursosScreenState createState() => _RecursosScreenState();
}

class _RecursosScreenState extends State<RecursosScreen> {
  List<dynamic> recursos = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
  }

  Future<void> _fetchRecursos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/recursos.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            recursos = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            errorMessage = data['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error ${response.statusCode} al cargar recursos';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error: $e';
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorDialog('No se pudo abrir el enlace: $url');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
    String sessionText = "Sesión activa de: ${widget.name}";
    if (widget.role.toLowerCase() == "estudiante") {
      sessionText = "Sesión activa del alumno: ${widget.name}";
    } else if (widget.role.toLowerCase() == "docente") {
      sessionText = "Sesión activa del docente: ${widget.name}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos'),
        backgroundColor: Colors.blue,
        actions: [
          if (widget.role.toLowerCase() == "docente")
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Configuraciones de Recursos",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionesRecursosScreen(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/comunicados_portada.png'), // Imagen de portada
                      const SizedBox(height: 16),
                      Text(
                        sessionText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Recursos de Estudio',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: recursos.length,
                          itemBuilder: (context, index) {
                            final recurso = recursos[index];
                            return _buildResourceItem(
                              recurso['nombre'] ?? 'Título no disponible',
                              recurso['link'] ?? 'URL no disponible',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildResourceItem(String title, String url) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        subtitle: Text(url),
        trailing: const Icon(Icons.link, color: Colors.green),
        onTap: () => _openLink(url),
      ),
    );
  }
}
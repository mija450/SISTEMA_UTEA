import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Para dar formato a las fechas
import 'agregar_encuesta.dart'; // Asegúrate de importar el archivo

class EncuestasScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const EncuestasScreen({
    Key? key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _EncuestasScreenState createState() => _EncuestasScreenState();
}

class _EncuestasScreenState extends State<EncuestasScreen> {
  List<dynamic> encuestas = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchEncuestas();
  }

  Future<void> _fetchEncuestas() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/encuestas.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            encuestas = data['data'];
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
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "estudiante"
        ? "Sesión activa del alumno: ${widget.name}"
        : "Sesión activa del docente: ${widget.name}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuestas'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Agregar Encuesta",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgregarEncuestaScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar encuestas"))
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
                        'Encuestas Disponibles',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: encuestas.length,
                          itemBuilder: (context, index) {
                            final encuesta = encuestas[index];
                            return _buildEncuestaItem(
                              encuesta['titulo'] ?? 'Título no disponible',
                              "${encuesta['descripcion'] ?? 'Descripción no disponible'}\nFecha: ${encuesta['fecha'] ?? 'Fecha no disponible'}",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEncuestaItem(String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        subtitle: Text(description),
        trailing: const Icon(Icons.poll, color: Colors.green),
      ),
    );
  }
}
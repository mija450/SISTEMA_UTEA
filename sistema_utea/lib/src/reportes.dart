import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'agregar_reporte.dart'; // Importa el archivo para agregar reportes

class ReportesScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ReportesScreen({
    Key? key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<dynamic> reportes = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchReportes();
  }

  Future<void> _fetchReportes() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/reportes.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            reportes = data['data'];
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

  Widget _buildReporteItem(String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        subtitle: Text(description),
        trailing: const Icon(Icons.bar_chart, color: Colors.green),
      ),
    );
  }

  void _navigateToAgregarReporte() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarReporteScreen()),
    ).then((_) {
      // Refresca la lista de reportes cuando regresa
      _fetchReportes();
    });
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "estudiante"
        ? "Sesión activa del alumno: ${widget.name}"
        : "Sesión activa del docente: ${widget.name}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Actualizar Reportes",
            onPressed: _fetchReportes,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Agregar Reporte",
            onPressed: _navigateToAgregarReporte,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar reportes"))
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
                        'Reportes Disponibles',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: reportes.length,
                          itemBuilder: (context, index) {
                            final reporte = reportes[index];
                            return _buildReporteItem(
                              reporte['titulo'] ?? 'Título no disponible',
                              "${reporte['descripcion'] ?? 'Descripción no disponible'}\nFecha: ${reporte['fecha'] ?? 'Fecha no disponible'}",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
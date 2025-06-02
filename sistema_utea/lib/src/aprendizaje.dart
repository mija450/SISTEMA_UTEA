import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'configuraciones_aprendizaje.dart';

class AprendizajeScreen extends StatefulWidget {
  final String role;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const AprendizajeScreen({
    Key? key,
    required this.role,
    required this.isDarkMode,
    required this.onThemeChanged, required String name,
  }) : super(key: key);

  @override
  _AprendizajeScreenState createState() => _AprendizajeScreenState();
}

class _AprendizajeScreenState extends State<AprendizajeScreen> {
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
        debugPrint("Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      debugPrint("Error: $e");
    }
  }

  Future<void> _abrirPDF(int idCurso) async {
    final urlDescarga = "http://127.0.0.1/ProyectoColegio/Colegio/descargar_aprendizaje.php?id=$idCurso";
    final uri = Uri.parse(urlDescarga);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir el PDF")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aprendizaje"),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (widget.role.toLowerCase() == "docente")
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Configuraciones",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionesAprendizajeScreen(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                ).then((result) {
                  if (result == true) {
                    _fetchCursos();
                  }
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar cursos"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/comunicados_portada.png'), // Imagen de portada
                      const SizedBox(height: 16),
                      const Text(
                        "Bienvenido a la sección de Aprendizaje",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "📚 ¡Cursos gratis y disponibles para reforzar!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...cursos.map((curso) {
                        final int idCurso = int.tryParse(curso['id'].toString()) ?? 0;
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                            title: Text(curso['titulo'] ?? ""),
                            subtitle: Text(curso['subtitulo'] ?? ""),
                            trailing: IconButton(
                              icon: const Icon(Icons.book_rounded, color: Colors.green),
                              tooltip: "Abrir PDF en el navegador",
                              onPressed: () {
                                if (idCurso != 0) {
                                  _abrirPDF(idCurso);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("ID inválido")),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}
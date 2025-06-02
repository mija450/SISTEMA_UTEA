import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'agregar_biblioteca.dart';
import 'configuraciones_biblioteca.dart';
import 'buscar_biblioteca.dart';
import 'package:url_launcher/url_launcher.dart';

class BibliotecaScreen extends StatefulWidget {
  final String role;
  final String name;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const BibliotecaScreen({
    Key? key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _BibliotecaScreenState createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  List<dynamic> recursos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
  }

  Future<void> _fetchRecursos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/biblioteca.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
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
      print("Error: $e");
    }
  }

  void _navigateToAgregarBiblioteca() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarBibliotecaScreen()),
    ).then((_) => _fetchRecursos());
  }

  void _navigateToDetalleRecurso(Map<String, dynamic> recurso) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleRecursoScreen(recurso: recurso),
      ),
    );
  }

  Widget _buildRecursoItem(Map<String, dynamic> recurso) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.menu_book, color: Colors.blueAccent, size: 30),
        title: Text(
          recurso['titulo'] ?? 'Título no disponible',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          recurso['descripcion'] ?? 'Descripción no disponible',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black45),
        onTap: () => _navigateToDetalleRecurso(recurso),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "estudiante"
        ? "Sesión activa del alumno: ${widget.name}"
        : "Sesión activa del docente: ${widget.name}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Biblioteca'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Buscar Recursos",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuscarBibliotecaScreen()),
              ).then((_) => _fetchRecursos());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Configuraciones",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfiguracionesBibliotecaScreen(
                    isDarkMode: widget.isDarkMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              ).then((_) => _fetchRecursos());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        tooltip: "Agregar Recurso",
        onPressed: _navigateToAgregarBiblioteca,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar recursos"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/comunicados_portada.png'),
                      const SizedBox(height: 20),
                      Text(
                        sessionText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Recursos Disponibles',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: recursos.length,
                          itemBuilder: (context, index) {
                            return _buildRecursoItem(recursos[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class DetalleRecursoScreen extends StatelessWidget {
  final Map<String, dynamic> recurso;

  const DetalleRecursoScreen({Key? key, required this.recurso}) : super(key: key);

  Future<void> _launchEnlace(String enlace) async {
    final Uri url = Uri.parse(enlace);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se puede abrir el enlace: $enlace';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recurso['titulo'] ?? 'Detalle del Recurso'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.book, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                recurso['titulo'] ?? 'Título no disponible',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                recurso['descripcion'] ?? 'Descripción no disponible',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                "Autor: ${recurso['autor'] ?? 'Autor no disponible'}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                "Código: ${recurso['codigo'] ?? 'Código no disponible'}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                "Fecha de Publicación: ${recurso['fecha_publicacion'] ?? 'No disponible'}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              if (recurso['enlace'] != null && recurso['enlace'].toString().isNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchEnlace(recurso['enlace']),
                    icon: const Icon(Icons.link),
                    label: const Text('Abrir Recurso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                )
              else
                const Text("Este recurso no tiene enlace disponible"),
            ],
          ),
        ),
      ),
    );
  }
}

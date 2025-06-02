import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'agregar_biblioteca.dart';
import 'configuraciones_biblioteca.dart';
import 'buscar_biblioteca.dart';
import 'package:url_launcher/url_launcher.dart';

// Clase Libro para almacenar los datos de cada libro
class Libro {
  int id;
  String titulo;
  String autor;
  String? genero;
  String isbn;
  String? fechaPublicacion;
  String? descripcion;
  int cantidadDisponible;
  String? portadaUrl;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    this.genero,
    required this.isbn,
    this.fechaPublicacion,
    this.descripcion,
    required this.cantidadDisponible,
    this.portadaUrl,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: int.parse(json['id'].toString()),
      titulo: json['titulo'] ?? '',
      autor: json['autor'] ?? '',
      genero: json['genero'],
      isbn: json['isbn'] ?? '',
      fechaPublicacion: json['fecha_publicacion'],
      descripcion: json['descripcion'],
      cantidadDisponible: int.parse(json['cantidad_disponible'].toString()),
      portadaUrl: json['portada_url'],
    );
  }
}

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
  List<Libro> libros = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = '';
  bool sortByTitle = true; // Sort by title initially

  @override
  void initState() {
    super.initState();
    _fetchLibros();
  }

  Future<void> _fetchLibros() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/biblioteca.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            libros = (data['data'] as List).map((json) => Libro.fromJson(json)).toList();
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
    ).then((_) => _fetchLibros());
  }

  void _navigateToDetalleLibro(Libro libro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleLibroScreen(libro: libro),
      ),
    );
  }

  Widget _buildLibroItem(Libro libro) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.menu_book, color: Colors.blueAccent, size: 30),
        title: Text(
          libro.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          libro.descripcion ?? 'Descripción no disponible',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black45),
        onTap: () => _navigateToDetalleLibro(libro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "estudiante"
        ? "Sesión activa del alumno: ${widget.name}"
        : "Sesión activa del docente: ${widget.name}";

    List<Libro> filteredLibros = libros.where((libro) {
      return libro.titulo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (libro.descripcion?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    }).toList();

    filteredLibros.sort((a, b) {
      if (sortByTitle) {
        return a.titulo.compareTo(b.titulo);
      } else {
        return a.autor.compareTo(b.autor);
      }
    });

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
              ).then((_) => _fetchLibros());
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: "Ordenar por Título/Autor",
            onPressed: () {
              setState(() {
                sortByTitle = !sortByTitle;
              });
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
              ).then((_) => _fetchLibros());
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
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar libro por título o descripción...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredLibros.length,
                          itemBuilder: (context, index) {
                            return _buildLibroItem(filteredLibros[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class DetalleLibroScreen extends StatelessWidget {
  final Libro libro;

  const DetalleLibroScreen({Key? key, required this.libro}) : super(key: key);

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
        title: Text(libro.titulo),
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
                libro.titulo,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                libro.descripcion ?? 'Descripción no disponible',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                "Autor: ${libro.autor}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                "ISBN: ${libro.isbn}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                "Fecha de Publicación: ${libro.fechaPublicacion ?? 'No disponible'}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              if (libro.portadaUrl != null && libro.portadaUrl!.isNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchEnlace(libro.portadaUrl!),
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
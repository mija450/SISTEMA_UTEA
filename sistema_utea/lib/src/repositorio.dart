import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model class for ArchivoRepositorio
class ArchivoRepositorio {
  final int id;
  final String nombreArchivo;
  final String tipoArchivo;
  final String rutaArchivo;
  final DateTime fechaSubida;
  final String? descripcion;
  final String? categoria;
  final int tamanoArchivo;
  final int? usuarioSubida;
  final String nombreOriginal;

  ArchivoRepositorio({
    required this.id,
    required this.nombreArchivo,
    required this.tipoArchivo,
    required this.rutaArchivo,
    required this.fechaSubida,
    this.descripcion,
    this.categoria,
    required this.tamanoArchivo,
    this.usuarioSubida,
    required this.nombreOriginal,
  });

  factory ArchivoRepositorio.fromJson(Map<String, dynamic> json) {
    return ArchivoRepositorio(
      id: int.parse(json['id'].toString()),
      nombreArchivo: json['nombre_archivo'] ?? '',
      tipoArchivo: json['tipo_archivo'] ?? '',
      rutaArchivo: json['ruta_archivo'] ?? '',
      fechaSubida: DateTime.parse(json['fecha_subida']),
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      tamanoArchivo: int.parse(json['tamano_archivo'].toString()),
      usuarioSubida: json['usuario_subida'] != null ? int.parse(json['usuario_subida'].toString()) : null,
      nombreOriginal: json['nombre_original'] ?? '',
    );
  }
}

class RepositorioScreen extends StatefulWidget {
  final String role;
  final String name;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const RepositorioScreen({
    Key? key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _RepositorioScreenState createState() => _RepositorioScreenState();
}

class _RepositorioScreenState extends State<RepositorioScreen> {
  List<ArchivoRepositorio> archivos = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = '';
  bool sortByNombre = true; // Sort by nombreArchivo initially

  @override
  void initState() {
    super.initState();
    _fetchArchivos();
  }

  Future<void> _fetchArchivos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Sistema_Utea/repositorio.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            archivos = (data['data'] as List).map((json) => ArchivoRepositorio.fromJson(json)).toList();
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

  Widget _buildArchivoItem(ArchivoRepositorio archivo) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.archive, color: Colors.blueAccent, size: 30),
        title: Text(
          archivo.nombreOriginal,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Tipo: ${archivo.tipoArchivo}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black45),
        // onTap: () => _navigateToDetalleArchivo(archivo), // Implement this if you have a detail screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "estudiante"
        ? "Sesión activa del alumno: ${widget.name}"
        : "Sesión activa del docente: ${widget.name}";

    List<ArchivoRepositorio> filteredArchivos = archivos.where((archivo) {
      return archivo.nombreOriginal.toLowerCase().contains(searchQuery.toLowerCase()) ||
          archivo.tipoArchivo.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filteredArchivos.sort((a, b) {
      if (sortByNombre) {
        return a.nombreOriginal.compareTo(b.nombreOriginal);
      } else {
        return a.tipoArchivo.compareTo(b.tipoArchivo);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Repositorio'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Buscar Recursos",
            onPressed: () {
              // Implement search functionality if needed
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: "Ordenar por Nombre/Tipo",
            onPressed: () {
              setState(() {
                sortByNombre = !sortByNombre;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Configuraciones",
            onPressed: () {
              // Implement settings navigation
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar archivos"))
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
                        'Archivos Disponibles',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar archivo por nombre o tipo...',
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
                          itemCount: filteredArchivos.length,
                          itemBuilder: (context, index) {
                            return _buildArchivoItem(filteredArchivos[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
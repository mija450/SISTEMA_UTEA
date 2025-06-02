import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Curso {
  final int id;
  final String nombre;
  final String descripcion;
  final String fechaInicio;
  final String fechaFin;
  final String docente;

  Curso({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.docente,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaInicio: json['fecha_inicio'] ?? '',
      fechaFin: json['fecha_fin'] ?? '',
      docente: json['docente'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'docente': docente,
      };
}

class CursosScreen extends StatefulWidget {
  const CursosScreen({Key? key}) : super(key: key);

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  final String apiBaseUrl = 'http://127.0.0.1/ProyectoColegio/Sistema_Utea';

  List<Curso> cursos = [];
  List<Curso> cursosFiltrados = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCursos();
    searchController.addListener(() {
      filtrarCursos(searchController.text);
    });
  }

  Future<void> fetchCursos() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/curso.php'));

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);
        if (jsonResp['success'] == true && jsonResp['data'] != null) {
          cursos = (jsonResp['data'] as List)
              .map((e) => Curso.fromJson(e))
              .toList();
          cursosFiltrados = List.from(cursos);
        } else {
          errorMessage = jsonResp['message'] ?? 'Error inesperado del servidor.';
        }
      } else {
        errorMessage = 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al conectar con el servidor: $e';
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filtrarCursos(String query) {
    query = query.toLowerCase();
    setState(() {
      cursosFiltrados = cursos.where((curso) {
        return curso.nombre.toLowerCase().contains(query) ||
            curso.descripcion.toLowerCase().contains(query) ||
            curso.docente.toLowerCase().contains(query);
      }).toList();
    });
  }

  void confirmarEliminacion(Curso curso) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Seguro que deseas eliminar el curso "${curso.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await eliminarCurso(curso.id);
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }

  Future<void> eliminarCurso(int idCurso) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/eliminar_curso.php?id=$idCurso'),
      );

      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Curso eliminado correctamente.')));
          await fetchCursos();
        } else {
          errorMessage = resp['message'] ?? 'No se pudo eliminar el curso.';
        }
      } else {
        errorMessage = 'Error en servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al eliminar curso: $e';
    }

    if (mounted) {
      setState(() => isLoading = false);

      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  void mostrarFormulario({Curso? curso}) {
    final _formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: curso?.nombre ?? '');
    final descripcionCtrl = TextEditingController(text: curso?.descripcion ?? '');
    final fechaInicioCtrl = TextEditingController(text: curso?.fechaInicio ?? '');
    final fechaFinCtrl = TextEditingController(text: curso?.fechaFin ?? '');
    final docenteCtrl = TextEditingController(text: curso?.docente ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(curso == null ? 'Agregar Curso' : 'Editar Curso'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('Nombre', nombreCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Descripción', descripcionCtrl, maxLines: 3),
                  const SizedBox(height: 8),
                  _buildTextField('Fecha Inicio (YYYY-MM-DD)', fechaInicioCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Fecha Fin (YYYY-MM-DD)', fechaFinCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Docente', docenteCtrl),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                await guardarCurso(
                  curso?.id,
                  nombreCtrl.text,
                  descripcionCtrl.text,
                  fechaInicioCtrl.text,
                  fechaFinCtrl.text,
                  docenteCtrl.text,
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
    );
  }

  Future<void> guardarCurso(
    int? id,
    String nombre,
    String descripcion,
    String fechaInicio,
    String fechaFin,
    String docente,
  ) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final uri = Uri.parse(id == null
          ? '$apiBaseUrl/agregar_curso.php'
          : '$apiBaseUrl/editar_curso.php');

      final response = await http.post(uri, body: {
        if (id != null) 'id': id.toString(),
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'docente': docente,
      });

      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(id == null
                  ? 'Curso agregado correctamente.'
                  : 'Curso actualizado correctamente.')));
          await fetchCursos();
        } else {
          errorMessage = resp['message'] ?? 'Error al guardar curso.';
        }
      } else {
        errorMessage = 'Error en servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al guardar curso: $e';
    }

    if (mounted) {
      setState(() => isLoading = false);
      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  Future<void> exportarCsv() async {
    List<List<String>> rows = [
      ['ID', 'Nombre', 'Descripción', 'Fecha Inicio', 'Fecha Fin', 'Docente'],
    ];

    for (var curso in cursos) {
      rows.add([
        curso.id.toString(),
        curso.nombre,
        curso.descripcion,
        curso.fechaInicio,
        curso.fechaFin,
        curso.docente,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'cursos_export.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Gestión de Cursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => mostrarFormulario(),
            tooltip: 'Agregar Curso',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: exportarCsv,
            tooltip: 'Exportar CSV',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD1C4E9), // Lila claro
              Color(0xFFB39DDB), // Lila medio
              Color(0xFF90CAF9), // Azul claro
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre, descripción o docente',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cursosFiltrados.length,
                        itemBuilder: (context, index) {
                          final curso = cursosFiltrados[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            color: Colors.white,
                            child: ListTile(
                              title: Text(curso.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Docente: ${curso.docente}'),
                                  Text('Inicio: ${curso.fechaInicio}'),
                                  Text('Fin: ${curso.fechaFin}'),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        mostrarFormulario(curso: curso),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        confirmarEliminacion(curso),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

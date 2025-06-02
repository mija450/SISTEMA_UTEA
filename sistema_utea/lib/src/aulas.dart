import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Aula {
  final int idAula;
  final String nombre;
  final int capacidad;
  final String tipo;
  final String recursos;
  final String createdAt;

  Aula({
    required this.idAula,
    required this.nombre,
    required this.capacidad,
    required this.tipo,
    required this.recursos,
    required this.createdAt,
  });

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      idAula: int.tryParse(json['idAula'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      capacidad: int.tryParse(json['capacidad'].toString()) ?? 0,
      tipo: json['tipo'] ?? '',
      recursos: json['recursos'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'idAula': idAula.toString(),
        'nombre': nombre,
        'capacidad': capacidad.toString(),
        'tipo': tipo,
        'recursos': recursos,
        'created_at': createdAt,
      };
}

class AulasScreen extends StatefulWidget {
  const AulasScreen({Key? key}) : super(key: key);

  @override
  State<AulasScreen> createState() => _AulasScreenState();
}

class _AulasScreenState extends State<AulasScreen> {
  final String apiBaseUrl = 'http://127.0.0.1/ProyectoColegio/Sistema_Utea';

  List<Aula> aulas = [];
  List<Aula> aulasFiltradas = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAulas();
    searchController.addListener(() {
      filtrarAulas(searchController.text);
    });
  }

  Future<void> fetchAulas() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/aula.php'));

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);
        if (jsonResp['success'] == true && jsonResp['data'] != null) {
          aulas = (jsonResp['data'] as List)
              .map((e) => Aula.fromJson(e))
              .toList();
          aulasFiltradas = List.from(aulas);
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
      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  void filtrarAulas(String query) {
    query = query.toLowerCase();
    setState(() {
      aulasFiltradas = aulas.where((aula) {
        return aula.nombre.toLowerCase().contains(query) ||
            aula.tipo.toLowerCase().contains(query) ||
            aula.recursos.toLowerCase().contains(query);
      }).toList();
    });
  }

  void confirmarEliminacion(Aula aula) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Seguro que deseas eliminar el aula "${aula.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await eliminarAula(aula.idAula);
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }

  Future<void> eliminarAula(int idAula) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/eliminar_aula.php?id=$idAula'),
      );

      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aula eliminada correctamente.')));
          await fetchAulas();
        } else {
          errorMessage = resp['message'] ?? 'No se pudo eliminar el aula.';
        }
      } else {
        errorMessage = 'Error en servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al eliminar aula: $e';
    }

    if (mounted) {
      setState(() => isLoading = false);
      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  void mostrarFormulario({Aula? aula}) {
    final _formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: aula?.nombre ?? '');
    final capacidadCtrl = TextEditingController(text: aula?.capacidad.toString() ?? '0');
    final tipoCtrl = TextEditingController(text: aula?.tipo ?? '');
    final recursosCtrl = TextEditingController(text: aula?.recursos ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aula == null ? 'Agregar Aula' : 'Editar Aula'),
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
                  _buildTextField('Capacidad', capacidadCtrl,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  _buildTextField('Tipo', tipoCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Recursos', recursosCtrl, maxLines: 3),
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
                await guardarAula(
                  aula?.idAula,
                  nombreCtrl.text,
                  int.tryParse(capacidadCtrl.text) ?? 0,
                  tipoCtrl.text,
                  recursosCtrl.text,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (label == 'Capacidad') {
          if (int.tryParse(value) == null) return 'Ingrese un número válido';
        }
        return null;
      },
    );
  }

  Future<void> guardarAula(
    int? idAula,
    String nombre,
    int capacidad,
    String tipo,
    String recursos,
  ) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final uri = Uri.parse(idAula == null
          ? '$apiBaseUrl/agregar_aula.php'
          : '$apiBaseUrl/editar_aula.php');

      final response = await http.post(uri, body: {
        if (idAula != null) 'idAula': idAula.toString(),
        'nombre': nombre,
        'capacidad': capacidad.toString(),
        'tipo': tipo,
        'recursos': recursos,
      });

      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(idAula == null
                  ? 'Aula agregada correctamente.'
                  : 'Aula actualizada correctamente.'),
            ),
          );
          await fetchAulas();
        } else {
          errorMessage = resp['message'] ?? 'Error al guardar aula.';
        }
      } else {
        errorMessage = 'Error de servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al guardar aula: $e';
    }

    if (mounted) {
      setState(() => isLoading = false);
      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  void exportarCsv() {
    List<List<dynamic>> rows = [
      ['idAula', 'Nombre', 'Capacidad', 'Tipo', 'Recursos', 'Creado en'],
      ...aulasFiltradas.map((a) => [
            a.idAula,
            a.nombre,
            a.capacidad,
            a.tipo,
            a.recursos,
            a.createdAt,
          ])
    ];

    String csvData = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'aulas.csv';
    html.document.body!.append(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Aulas'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            tooltip: 'Exportar a CSV',
            icon: const Icon(Icons.download),
            onPressed: aulasFiltradas.isEmpty ? null : exportarCsv,
          ),
          IconButton(
            tooltip: 'Agregar Aula',
            icon: const Icon(Icons.add),
            onPressed: () => mostrarFormulario(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe0c3fc), Color(0xff8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar aulas',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (aulasFiltradas.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No se encontraron aulas.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: aulasFiltradas.length,
                  itemBuilder: (_, index) {
                    final aula = aulasFiltradas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(aula.nombre),
                        subtitle: Text(
                          'Capacidad: ${aula.capacidad} | Tipo: ${aula.tipo}\nRecursos: ${aula.recursos}',
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => mostrarFormulario(aula: aula),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => confirmarEliminacion(aula),
                            ),
                          ],
                        ),
                      ),
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
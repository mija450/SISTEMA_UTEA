import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Modelo de datos para un docente
class Docente {
  final int id;
  final String nombre;
  final String dni;
  final String codigo;
  final String materia;
  final String campo;
  final String horario;
  final String aula;

  Docente({
    required this.id,
    required this.nombre,
    required this.dni,
    required this.codigo,
    required this.materia,
    required this.campo,
    required this.horario,
    required this.aula,
  });

  factory Docente.fromJson(Map<String, dynamic> json) {
    return Docente(
      id: int.tryParse(json['idDocente'].toString()) ?? 0,
      nombre: json['nombreDocente'] ?? '',
      dni: json['dni'] ?? '',
      codigo: json['codigo'] ?? '',
      materia: json['materia'] ?? '',
      campo: json['campo'] ?? '',
      horario: json['horariosDisponibles'] ?? '',
      aula: json['aula'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'idDocente': id.toString(),
        'nombreDocente': nombre,
        'dni': dni,
        'codigo': codigo,
        'materia': materia,
        'campo': campo,
        'horariosDisponibles': horario,
        'aula': aula,
      };
}

class DocentesScreen extends StatefulWidget {
  const DocentesScreen({Key? key}) : super(key: key);

  @override
  State<DocentesScreen> createState() => _DocentesScreenState();
}

class _DocentesScreenState extends State<DocentesScreen> {
  final String apiBaseUrl = 'http://localhost/ProyectoColegio/Sistema_Utea';

  List<Docente> docentes = [];
  List<Docente> docentesFiltrados = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDocentes();
    searchController.addListener(() {
      filtrarDocentes(searchController.text);
    });
  }

  /// Obtiene los docentes desde el backend PHP
  Future<void> fetchDocentes() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/docentes.php'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResp = jsonDecode(response.body);
        if (jsonResp['success'] == true && jsonResp['data'] != null) {
          List<dynamic> data = jsonResp['data'];
          docentes = data.map((e) => Docente.fromJson(e)).toList();
          docentesFiltrados = List.from(docentes);
        } else {
          errorMessage = jsonResp['message'] ?? 'Error inesperado del servidor.';
          docentes = [];
          docentesFiltrados = [];
        }
      } else {
        errorMessage = 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al conectar con el servidor: $e';
    }

    setState(() {
      isLoading = false;
    });
  }

  /// Filtra docentes según texto buscado
  void filtrarDocentes(String query) {
    query = query.toLowerCase();
    setState(() {
      docentesFiltrados = docentes.where((docente) {
        return docente.nombre.toLowerCase().contains(query) ||
            docente.materia.toLowerCase().contains(query) ||
            docente.aula.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Muestra diálogo para confirmar eliminación
  void confirmarEliminacion(Docente docente) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Seguro que deseas eliminar a "${docente.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await eliminarDocente(docente.id);
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }

  /// Elimina docente enviando petición al backend
  Future<void> eliminarDocente(int idDocente) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response =
          await http.get(Uri.parse('$apiBaseUrl/eliminar_docente.php?id=$idDocente'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Docente eliminado correctamente.')));
          await fetchDocentes();
        } else {
          errorMessage = resp['message'] ?? 'No se pudo eliminar el docente.';
        }
      } else {
        errorMessage = 'Error en servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al eliminar docente: $e';
    }

    setState(() {
      isLoading = false;
    });

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  /// Muestra formulario para agregar o editar docente
  void mostrarFormulario({Docente? docente}) {
    final _formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: docente?.nombre ?? '');
    final dniCtrl = TextEditingController(text: docente?.dni ?? '');
    final codigoCtrl = TextEditingController(text: docente?.codigo ?? '');
    final materiaCtrl = TextEditingController(text: docente?.materia ?? '');
    final campoCtrl = TextEditingController(text: docente?.campo ?? '');
    final horarioCtrl = TextEditingController(text: docente?.horario ?? '');
    final aulaCtrl = TextEditingController(text: docente?.aula ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docente == null ? 'Agregar Docente' : 'Editar Docente'),
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
                  _buildTextField('DNI', dniCtrl, keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  _buildTextField('Código', codigoCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Materia', materiaCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Campo', campoCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Horario', horarioCtrl),
                  const SizedBox(height: 8),
                  _buildTextField('Aula', aulaCtrl),
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
                await guardarDocente(
                  docente?.id,
                  nombreCtrl.text,
                  dniCtrl.text,
                  codigoCtrl.text,
                  materiaCtrl.text,
                  campoCtrl.text,
                  horarioCtrl.text,
                  aulaCtrl.text,
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Widget para campos de texto en el formulario
  Widget _buildTextField(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
    );
  }

  /// Guarda o actualiza docente enviando datos al backend
  Future<void> guardarDocente(
    int? id,
    String nombre,
    String dni,
    String codigo,
    String materia,
    String campo,
    String horario,
    String aula,
  ) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final uri = Uri.parse(id == null
          ? '$apiBaseUrl/agregar_docente.php'
          : '$apiBaseUrl/editar_docente.php');

      final response = await http.post(uri, body: {
        if (id != null) 'idDocente': id.toString(),
        'nombreDocente': nombre,
        'dni': dni,
        'codigo': codigo,
        'materia': materia,
        'campo': campo,
        'horariosDisponibles': horario,
        'aula': aula,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> resp = jsonDecode(response.body);
        if (resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(id == null
                  ? 'Docente agregado correctamente.'
                  : 'Docente actualizado correctamente.')));
          await fetchDocentes();
        } else {
          errorMessage = resp['message'] ?? 'Error al guardar docente.';
        }
      } else {
        errorMessage = 'Error en servidor: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error al guardar docente: $e';
    }

    setState(() {
      isLoading = false;
    });

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Docentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar lista',
            onPressed: fetchDocentes,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar docente',
            onPressed: () => mostrarFormulario(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar docente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : docentesFiltrados.isEmpty
                      ? Center(
                          child: Text(
                            errorMessage.isNotEmpty
                                ? errorMessage
                                : 'No hay docentes disponibles',
                            style: const TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: docentesFiltrados.length,
                          itemBuilder: (context, index) {
                            final docente = docentesFiltrados[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(docente.nombre),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DNI: ${docente.dni} | Código: ${docente.codigo}'),
                                    Text('Materia: ${docente.materia} | Campo: ${docente.campo}'),
                                    Text('Horario: ${docente.horario} | Aula: ${docente.aula}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'editar') {
                                      mostrarFormulario(docente: docente);
                                    } else if (value == 'eliminar') {
                                      confirmarEliminacion(docente);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Text('Editar'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'eliminar',
                                      child: Text('Eliminar'),
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

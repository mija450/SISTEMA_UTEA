import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Modelo de datos para un Docente
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
      id: int.parse(json['idDocente']),
      nombre: json['nombreDocente'],
      dni: json['dni'],
      codigo: json['codigo'],
      materia: json['materia'],
      campo: json['campo'],
      horario: json['horariosDisponibles'],
      aula: json['aula'],
    );
  }
}

/// Pantalla principal para listar y administrar docentes
class DocentesScreen extends StatefulWidget {
  const DocentesScreen({super.key});

  @override
  State<DocentesScreen> createState() => _DocentesScreenState();
}

class _DocentesScreenState extends State<DocentesScreen> {
  List<Docente> docentes = [];
  bool isLoading = true;

  // Cambia esta URL por la dirección real del backend PHP
  final String apiUrl = 'http://127.0.0.1/ProyectoColegio/Sistema_Utea/docentes.php';

  @override
  void initState() {
    super.initState();
    fetchDocentes();
  }

Future<void> fetchDocentes() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];

        setState(() {
          docentes = data.map((item) => Docente.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(jsonResponse['message'] ?? 'No hay datos');
      }
    } else {
      throw Exception('Error al cargar docentes');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    debugPrint('Error: $e');
  }
}


  Future<void> eliminarDocente(int idDocente) async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1/ProyectoColegio/Sistema_Utea/eliminar_docente.php?id=$idDocente'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Docente eliminado con éxito.')));
      fetchDocentes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar docente.')));
    }
  }

  void confirmarEliminacion(int id, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar al docente "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              eliminarDocente(id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocenteCard(Docente d) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          d.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DNI: ${d.dni}"),
            Text("Código: ${d.codigo}"),
            Text("Materia: ${d.materia}"),
            Text("Campo: ${d.campo}"),
            Text("Horario: ${d.horario}"),
            Text("Aula: ${d.aula}"),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') {
              // Aquí deberías ir a la pantalla de edición
            } else if (value == 'eliminar') {
              confirmarEliminacion(d.id, d.nombre);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Docentes'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : docentes.isEmpty
              ? const Center(child: Text('No hay docentes disponibles'))
              : RefreshIndicator(
                  onRefresh: fetchDocentes,
                  child: ListView.builder(
                    itemCount: docentes.length,
                    itemBuilder: (context, index) {
                      return _buildDocenteCard(docentes[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a pantalla para agregar docente
        },
        label: const Text('Agregar Docente'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

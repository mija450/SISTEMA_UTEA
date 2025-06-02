import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Asistencia {
  final String subject;
  final String date;
  final String status;

  Asistencia({
    required this.subject,
    required this.date,
    required this.status,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      subject: json['subject'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }
  
  Object? toJson() {}
}

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({Key? key}) : super(key: key);

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  static const String baseUrl = 'http://127.0.0.1/ProyectoColegio/Sistema_Utea/asistencias.php'; // Cambia a tu URL real

  List<Asistencia> asistencias = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAsistencias();
  }

  Future<void> _fetchAsistencias() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          asistencias = data.map((e) => Asistencia.fromJson(e)).toList();
        });
      } else {
        throw Exception('Error al cargar asistencias');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar asistencias: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _addOrEditAsistencia({Asistencia? asistencia}) async {
    final result = await showDialog<Asistencia>(
      context: context,
      builder: (_) => AsistenciaDialog(asistencia: asistencia),
    );
    if (result != null) {
      setState(() => isLoading = true);
      try {
        final isNew = asistencia == null;
        final uri = isNew ? Uri.parse(baseUrl) : Uri.parse('$baseUrl?id=${asistencia!.subject}');
        final response = isNew
            ? await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(result.toJson()))
            : await http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(result.toJson()));

        if (response.statusCode == 200) {
          await _fetchAsistencias();
        } else {
          throw Exception(isNew ? 'Error al agregar asistencia' : 'Error al actualizar asistencia');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteAsistencia(Asistencia asistencia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Deseas eliminar la asistencia de "${asistencia.subject}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        final uri = Uri.parse('$baseUrl?subject=${asistencia.subject}');
        final response = await http.delete(uri);
        if (response.statusCode == 200) {
          await _fetchAsistencias();
        } else {
          throw Exception('Error al eliminar asistencia');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia de Clases'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar asistencias',
            onPressed: _fetchAsistencias,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : asistencias.isEmpty
                      ? Center(
                          child: Text(
                            'No hay registros de asistencia',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        )
                      : ListView.builder(
                          itemCount: asistencias.length,
                          itemBuilder: (context, i) {
                            final a = asistencias[i];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                  a.subject,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(a.date))}\nEstado: ${a.status}',
                                  style: const TextStyle(height: 1.3),
                                ),
                                trailing: Wrap(
                                  spacing: 12,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _addOrEditAsistencia(asistencia: a),
                                      tooltip: 'Editar asistencia',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _deleteAsistencia(a),
                                      tooltip: 'Eliminar asistencia',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAsistencia(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar nueva asistencia',
      ),
    );
  }
}

class AsistenciaDialog extends StatefulWidget {
  final Asistencia? asistencia;
  const AsistenciaDialog({Key? key, this.asistencia}) : super(key: key);

  @override
  State<AsistenciaDialog> createState() => _AsistenciaDialogState();
}

class _AsistenciaDialogState extends State<AsistenciaDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _subjectController;
  late TextEditingController _dateController;
  String _status = 'Presente'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    final a = widget.asistencia;
    _subjectController = TextEditingController(text: a?.subject ?? '');
    _dateController = TextEditingController(text: a?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _status = a?.status ?? 'Presente';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.asistencia == null ? 'Agregar Asistencia' : 'Editar Asistencia'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Materia'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese una materia' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese una fecha' : null,
              ),
              DropdownButton<String>(
                value: _status,
                items: ['Presente', 'Ausente', 'Tarde'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final nuevaAsistencia = Asistencia(
                subject: _subjectController.text.trim(),
                date: _dateController.text.trim(),
                status: _status,
              );
              Navigator.pop(context, nuevaAsistencia);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
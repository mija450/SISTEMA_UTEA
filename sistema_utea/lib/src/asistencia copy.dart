import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({Key? key}) : super(key: key);

  @override
  _AsistenciaScreenState createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  List<dynamic> asistencias = [];
  Color backgroundColor = Colors.white; // Fondo blanco por defecto
  Color primaryColor = Colors.blue[800]!;
  Color accentColor = Colors.blue[800]!;
  bool isLoading = false;

  TextEditingController subjectController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _cargarAsistencias();
  }

  @override
  void dispose() {
    subjectController.dispose();
    dateController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> _cargarAsistencias() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
        "http://127.0.0.1/ProyectoColegio/Sistema_Utea/asistencias.php"); // Replace with your API endpoint
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('API Response: ${response.body}'); // Debug

        final data = json.decode(response.body);

        // Assuming the API returns a list directly
        if (data is List) {
          setState(() {
            asistencias = List<Map<String, dynamic>>.from(data);
          });
        }
        // Assuming the API returns an object with a 'data' key
        else if (data is Map && data.containsKey('data') && data['data'] is List) {
          setState(() {
            asistencias = List<Map<String, dynamic>>.from(data['data']);
          });
        }
        else {
          print('Error: Unexpected API response format');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Formato de respuesta de la API inesperado")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al obtener asistencias")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seleccionar Color de Fondo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGradientOption("Blanco", [Colors.white]),
                _buildGradientOption("Gris Claro", [Colors.grey.shade200]),
                _buildGradientOption("Beige", [Colors.amber.shade100]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOption(String title, List<Color> colors) {
    return GestureDetector(
      onTap: () {
        setState(() {
          backgroundColor = colors[0]; // Use the first color from the list
        });
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: colors[0], // Usar el primer color para el fondo
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(title, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  void _showAddAsistenciaDialog() {
    subjectController.text = '';
    dateController.text = '';
    statusController.text = '';
    editingIndex = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nueva Asistencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Materia'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Fecha (DD/MM/AAAA)'),
              ),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Estado (Presente/Falta)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Agregar'),
              onPressed: () async { // Make it async
                if (subjectController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    statusController.text.isNotEmpty) {

                  final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Sistema_Utea/asistencias.php"); // Replace with your API endpoint

                  final Map<String, dynamic> asistenciaData = {
                    'subject': subjectController.text,
                    'date': dateController.text,
                    'status': statusController.text,
                  };

                  try {
                    final response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(asistenciaData),
                    );

                    if (response.statusCode == 200) {
                      _cargarAsistencias(); // Reload data
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Asistencia agregada con éxito")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error al agregar asistencia")));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditAsistenciaDialog(int index) {
    subjectController.text = asistencias[index]['subject'].toString();
    dateController.text = asistencias[index]['date'].toString();
    statusController.text = asistencias[index]['status'].toString();
    editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Asistencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Materia'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Fecha (DD/MM/AAAA)'),
              ),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Estado (Presente/Falta)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (subjectController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    statusController.text.isNotEmpty) {

                  final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Sistema_Utea/asistencias.php"); // Replace with your API endpoint

                  final Map<String, dynamic> asistenciaData = {
                    'id': asistencias[index]['id'], // Assuming you have an 'id'
                    'subject': subjectController.text,
                    'date': dateController.text,
                    'status': statusController.text,
                  };

                  try {
                    final response = await http.put( // Use PUT for updates
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(asistenciaData),
                    );

                    if (response.statusCode == 200) {
                      _cargarAsistencias(); // Reload data
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Asistencia actualizada con éxito")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error al actualizar asistencia")));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAsistencia(int index) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Sistema_Utea/asistencias.php"); // Replace with your API endpoint

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': asistencias[index]['id']}), // Send ID to delete
      );

      if (response.statusCode == 200) {
        _cargarAsistencias(); // Reload data
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Asistencia eliminada con éxito")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al eliminar asistencia")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildAsistenciaCard(String subject, String date, String status, int index) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detalles de asistencia de $subject')));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Icon(
              status.toLowerCase() == 'presente' ? Icons.check_circle : Icons.cancel,
              color: status.toLowerCase() == 'presente' ? Colors.green : Colors.red,
              size: 30,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Estado: $status',
                  style: TextStyle(
                    color: status.toLowerCase() == 'presente' ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Asistencia 📋', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.white),
            onPressed: _showColorDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddAsistenciaDialog,
      ),
      body: Container(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120.0,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner8.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registro de Asistencia',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: asistencias.length,
                  itemBuilder: (context, index) {
                    final asistencia = asistencias[index];
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmar"),
                                content: const Text("¿Estás seguro de que quieres eliminar este registro de asistencia?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteAsistencia(index);
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          _showEditAsistenciaDialog(index);
                          return false;
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Asistencia de ${asistencias[index]['subject']} eliminada')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Editar asistencia de ${asistencias[index]['subject']}')));
                        }
                      },
                      child: _buildAsistenciaCard(asistencia['subject'].toString(), asistencia['date'].toString(), asistencia['status'].toString(), index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
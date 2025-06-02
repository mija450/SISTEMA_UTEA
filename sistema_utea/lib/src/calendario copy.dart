import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({Key? key}) : super(key: key);

  @override
  _CalendarioScreenState createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  List<dynamic> events = [];
  Color backgroundColor = Colors.white;
  Color primaryColor = const Color(0xFF005EB8);
  Color accentColor = const Color(0xFFFFC107);
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
        "http://127.0.0.1/ProyectoColegio/Sistema_Utea/calendario.php"); // Replace with your actual API URL
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('API Response: ${response.body}'); // Debug: Print the response

        final data = json.decode(response.body);

        // Check if the API returns a list directly
        if (data is List) {
          setState(() {
            events = List<Map<String, dynamic>>.from(data);
          });
        }
        // Check if the API returns an object with a 'data' key containing the list
        else if (data is Map && data.containsKey('data') && data['data'] is List) {
          setState(() {
            events = List<Map<String, dynamic>>.from(data['data']);
          });
        }
        // Check if the API returns an object with a 'success' and 'data' key
        else if (data is Map && data.containsKey('success') && data['success'] == true && data.containsKey('data') && data['data'] is List) {
          setState(() {
            events = List<Map<String, dynamic>>.from(data['data']);
          });
        }
        else {
          print('Error: Unexpected API response format');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Formato de respuesta de la API inesperado")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al obtener eventos del calendario")));
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
                _buildColorOption("Blanco", Colors.white),
                _buildColorOption("Gris Claro", Colors.grey.shade200),
                _buildColorOption("Beige", Colors.amber.shade100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorOption(String title, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          backgroundColor = color;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(title, style: TextStyle(color: primaryColor)),
      ),
    );
  }

  void _showAddEventDialog() {
    _titleController.text = '';
    _startDateController.text = '';
    _endDateController.text = '';
    _descriptionController.text = '';
    _editingIndex = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Nuevo Evento"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha de Inicio (yyyy-MM-dd HH:mm:ss)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una fecha de inicio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha de Fin (yyyy-MM-dd HH:mm:ss)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una fecha de fin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveEvent();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(int index) {
    final event = events[index];
    _titleController.text = event['title'];
    _startDateController.text = event['start_date'];
    _endDateController.text = event['end_date'];
    _descriptionController.text = event['description'] ?? ''; // Handle null
    _editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Evento"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha de Inicio (yyyy-MM-dd HH:mm:ss)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una fecha de inicio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha de Fin (yyyy-MM-dd HH:mm:ss)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una fecha de fin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveEvent();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _saveEvent() async {
    final url = Uri.parse(
        "http://127.0.0.1/ProyectoColegio/Sistema_Utea/calendario.php"); // Replace with your actual API URL

    final Map<String, dynamic> eventData = {
      'title': _titleController.text,
      'start_date': _startDateController.text,
      'end_date': _endDateController.text,
      'description': _descriptionController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(eventData),
      );

      if (response.statusCode == 200) {
        // Recargar eventos después de guardar
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Evento guardado con éxito")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al guardar el evento")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _deleteEvent(int index) async {
    final event = events[index];
    final url = Uri.parse(
        "http://127.0.0.1/ProyectoColegio/Sistema_Utea/calendario.php"); // Replace with your actual API URL

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': event['id']}), // Envía el ID para eliminar
      );

      if (response.statusCode == 200) {
        // Recargar eventos después de eliminar
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Evento eliminado con éxito")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al eliminar el evento")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Calendario 📅',
            style: TextStyle(color: Colors.white)),
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
        onPressed: _showAddEventDialog,
        backgroundColor: accentColor,
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120.0,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/banner12.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '🗓️ Eventos 🗓️',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : events.isEmpty
                      ? const Center(
                          child: Text('No hay eventos programados',
                              style: TextStyle(fontSize: 16)))
                      : ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Dismissible(
                              key: UniqueKey(),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.blue,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.edit,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction ==
                                    DismissDirection.startToEnd) {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirmar"),
                                        content: const Text(
                                            "¿Estás seguro de que quieres eliminar este evento?"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteEvent(index);
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text("Eliminar"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  _showEditEventDialog(index);
                                  return false;
                                }
                              },
                              onDismissed: (direction) {
                                if (direction ==
                                    DismissDirection.startToEnd) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '${event['title']} eliminado')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Editar ${event['title']}')));
                                }
                              },
                              child: AnimatedOpacity(
                                opacity: 1.0,
                                duration: const Duration(milliseconds: 500),
                                child: _buildEvent(
                                  event['title'],
                                  event['start_date'],
                                  event['end_date'],
                                  event['description'],
                                  index,
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

  Widget _buildEvent(String title, String startDate, String endDate, String description, int index) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abrir detalles de: $title')));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    DateFormat('dd/MM/yyyy hh:mm a')
                        .format(DateTime.parse(startDate)),
                    style: const TextStyle(color: Colors.grey)),
                Text(
                  DateFormat('dd/MM/yyyy hh:mm a')
                      .format(DateTime.parse(endDate)),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(description,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
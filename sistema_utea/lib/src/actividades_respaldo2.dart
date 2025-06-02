import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ActividadesScreen extends StatefulWidget {
  const ActividadesScreen({Key? key}) : super(key: key);

  @override
  _ActividadesScreenState createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  List<dynamic> actividades = [];
  Color backgroundColor = Colors.white;
  Color primaryColor = const Color(0xFF005EB8);
  Color accentColor = const Color(0xFFFFC107);
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _fechaController = TextEditingController();
  TextEditingController _horaController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  Future<void> _cargarActividades() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
        "http://127.0.0.1/ProyectoColegio/Sistema_Utea/actividades.php");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('API Response: ${response.body}'); // Debug: Print the response

        final data = json.decode(response.body);

        // Check if the API returns a list directly
        if (data is List) {
          setState(() {
            actividades = List<Map<String, dynamic>>.from(data);
          });
        }
        // Check if the API returns an object with a 'data' key containing the list
        else if (data is Map && data.containsKey('data') && data['data'] is List) {
          setState(() {
            actividades = List<Map<String, dynamic>>.from(data['data']);
          });
        }
        // Check if the API returns an object with a 'success' and 'data' key
        else if (data is Map && data.containsKey('success') && data['success'] == true && data.containsKey('data') && data['data'] is List) {
          setState(() {
            actividades = List<Map<String, dynamic>>.from(data['data']);
          });
        }
        else {
          print('Error: Unexpected API response format');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Formato de respuesta de la API inesperado")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al obtener actividades")));
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

  Icon getActivityIcon(String title) {
    if (title.toLowerCase().contains("clase")) {
      return const Icon(Icons.school, color: Colors.orangeAccent);
    }
    if (title.toLowerCase().contains("examen")) {
      return const Icon(Icons.assignment, color: Colors.redAccent);
    }
    if (title.toLowerCase().contains("taller")) {
      return const Icon(Icons.science, color: Colors.greenAccent);
    }
    if (title.toLowerCase().contains("excursion")) {
      return const Icon(Icons.park, color: Colors.lightGreen);
    }
    return const Icon(Icons.event, color: Colors.blueAccent);
  }

  Color getCardBorderColor(String fecha) {
    final now = DateTime.now();
    final actividadFecha = DateTime.tryParse(fecha) ?? now;

    if (actividadFecha.isBefore(now)) return Colors.grey;
    if (actividadFecha.difference(now).inDays <= 1)
      return Colors.redAccent;
    if (actividadFecha.difference(now).inDays <= 3)
      return Colors.orangeAccent;
    return Colors.purpleAccent;
  }

  String getEstadoActividad(String fecha) {
    final now = DateTime.now();
    final actividadFecha = DateTime.tryParse(fecha) ?? now;

    if (actividadFecha.isBefore(now)) return "✅ Completado";
    if (actividadFecha.difference(now).inDays == 0) return "📅 Hoy";
    return "⏳ Próximo";
  }

  void _showAddActivityDialog() {
    _tituloController.text = '';
    _fechaController.text = '';
    _horaController.text = '';
    _editingIndex = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Nueva Actividad"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _fechaController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha (yyyy-MM-dd)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una fecha';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _horaController,
                    decoration: const InputDecoration(labelText: 'Hora (HH:mm)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una hora';
                      }
                      return null;
                    },
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
                  _guardarActividad();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditActivityDialog(int index) {
    final actividad = actividades[index];
    _tituloController.text = actividad['titulo'];
    _fechaController.text = actividad['fecha'];
    _horaController.text = actividad['hora'];
    _editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Actividad"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _fechaController,
                    decoration: const InputDecoration(
                        labelText: 'Fecha (yyyy-MM-dd)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una fecha';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _horaController,
                    decoration: const InputDecoration(labelText: 'Hora (HH:mm)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una hora';
                      }
                      return null;
                    },
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
                  _guardarActividad();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

void _guardarActividad() async {
  final bool esEdicion = _editingIndex != null;
  final url = Uri.parse(
    esEdicion
        ? "http://127.0.0.1/ProyectoColegio/Sistema_Utea/editar_actividad.php"
        : "http://127.0.0.1/ProyectoColegio/Sistema_Utea/agregar_actividad.php", // o la ruta que uses para agregar
  );

  final Map<String, dynamic> actividadData = {
    'titulo': _tituloController.text,
    'fecha': _fechaController.text,
    'hora': _horaController.text,
  };

  if (esEdicion) {
    actividadData['id'] = actividades[_editingIndex!]['id'];
  }

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(actividadData),
    );

    if (response.statusCode == 200) {
      _cargarActividades();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Actividad ${esEdicion ? 'editada' : 'agregada'} con éxito")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al guardar la actividad")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}


void _eliminarActividad(int index) async {
  final actividad = actividades[index];
  final url = Uri.parse(
      "http://127.0.0.1/ProyectoColegio/Sistema_Utea/eliminar_actividad.php");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': actividad['id']}),
    );

    if (response.statusCode == 200) {
      _cargarActividades();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Actividad eliminada con éxito")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar la actividad")),
      );
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
      title: const Text(
        '🎉 Actividades 🎉',
        style: TextStyle(color: Colors.white),
      ),
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
      onPressed: _showAddActivityDialog,
      backgroundColor: accentColor,
      child: const Icon(Icons.add),
    ),
    body: Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          Container(
            width: double.infinity,
            height: 120.0,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/banner5.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            '📝 Actividades Programadas 📝',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Activities List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : actividades.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay actividades programadas',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: actividades.length,
                        itemBuilder: (context, index) {
                          final actividad = actividades[index];

                          return Dismissible(
                            key: UniqueKey(),
                            background: _dismissBackground(Colors.red, Icons.delete),
                            secondaryBackground: _dismissBackground(Colors.blue, Icons.edit),
                            confirmDismiss: (direction) async {
                              return await _confirmDismiss(context, direction, index);
                            },
                            onDismissed: (direction) {
                              _onDismissed(direction, actividad);
                            },
                            child: AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 500),
                              child: _buildActividad(
                                actividad['titulo'],
                                actividad['fecha'],
                                actividad['hora'],
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

// Function to handle Dismiss background styling
Widget _dismissBackground(Color color, IconData icon) {
  return Container(
    color: color,
    alignment: icon == Icons.delete ? Alignment.centerLeft : Alignment.centerRight,
    padding: icon == Icons.delete
        ? const EdgeInsets.only(left: 20)
        : const EdgeInsets.only(right: 20),
    child: Icon(icon, color: Colors.white),
  );
}

// Function to confirm the dismissal action
Future<bool> _confirmDismiss(BuildContext context, DismissDirection direction, int index) async {
  if (direction == DismissDirection.startToEnd) {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("¿Estás seguro de que quieres eliminar esta actividad?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarActividad(index);
                Navigator.of(context).pop(true);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  } else {
    _showEditActivityDialog(index);
    return false;
  }
}

// Function to handle actions after dismissal (delete or edit)
void _onDismissed(DismissDirection direction, Map<String, dynamic> actividad) {
  if (direction == DismissDirection.startToEnd) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${actividad['titulo']} eliminado')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar ${actividad['titulo']}')),
    );
  }
}


  Widget _buildActividad(String title, String date, String time, int index) {
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
          border: Border(
            bottom: BorderSide(color: getCardBorderColor(date), width: 4),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                getActivityIcon(title),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(date)),
                    style: const TextStyle(color: Colors.grey)),
                Text(
                  DateFormat('hh:mm a')
                      .format(DateTime.parse(date)),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(getEstadoActividad(date),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }
}
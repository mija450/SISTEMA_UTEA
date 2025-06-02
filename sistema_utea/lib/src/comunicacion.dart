import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'configuraciones_comunicacion.dart';
import 'soporte.dart';

class ComunicacionScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario

  const ComunicacionScreen({
    Key? key,
    required this.role,
    required this.name,
  }) : super(key: key);

  @override
  _ComunicacionScreenState createState() => _ComunicacionScreenState();
}

class _ComunicacionScreenState extends State<ComunicacionScreen> {
  List<dynamic> anuncios = [];
  bool isLoading = true;
  bool hasError = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchAnuncios();
  }

  Future<void> _fetchAnuncios() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/comunicacion.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            anuncios = data['data'];
            isLoading = false;
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
      print("Error al obtener anuncios: $e");
    }
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> anuncio) {
    String title = anuncio['nombre'] ?? "Sin título";
    String details =
        "Fecha: ${anuncio['fecha']}\nHora: ${anuncio['hora']}\nDetalles: ${anuncio['detalles']}";
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.announcement, color: Colors.blue),
        title: Text(title),
        subtitle: Text(details),
      ),
    );
  }

  Future<void> _sendMessage() async {
    setState(() {
      _isSending = true;
    });

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_soporte.php");
    try {
      final response = await http.post(url, body: {
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'fecha': _fechaController.text.trim(),
      });

      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Consulta enviada con éxito")),
        );
        _tituloController.clear();
        _descripcionController.clear();
        _fechaController.clear(); // Limpiar el campo de fecha después de enviar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error al enviar el mensaje")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _fechaController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = "Sesión activa de: ${widget.name}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicación'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (widget.role.toLowerCase() == "docente")
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Configuraciones de Comunicación",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfiguracionesComunicacionScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    _fetchAnuncios();
                  }
                });
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAnuncios,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/comunicados_portada.png'), // Imagen de portada
              const SizedBox(height: 16),
              Text(
                sessionText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bienvenido a la sección de Comunicación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '📢 Anuncios Importantes Para Usted',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text("Error al cargar anuncios"))
                      : Column(
                          children: anuncios
                              .map((anuncio) => _buildAnnouncementCard(anuncio))
                              .toList(),
                        ),
              const SizedBox(height: 20),
              const Text(
                '✉️ ¿Tienes dudas?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: "Título de la Pregunta",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? "Ingrese el título" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: "Mensaje",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) => value!.isEmpty ? "Escribe un mensaje." : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _fechaController,
                      decoration: const InputDecoration(
                        labelText: "Fecha",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) => value!.isEmpty ? "Ingrese la fecha" : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _sendMessage();
                              }
                            },
                      child: _isSending
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Enviar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
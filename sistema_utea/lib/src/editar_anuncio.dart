import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

/// Pantalla que lista todos los anuncios para que el usuario seleccione uno a editar.
class EditarAnuncioScreen extends StatefulWidget {
  const EditarAnuncioScreen({Key? key, required Map<String, dynamic> anuncio}) : super(key: key);

  @override
  _EditarAnuncioScreenState createState() => _EditarAnuncioScreenState();
}

class _EditarAnuncioScreenState extends State<EditarAnuncioScreen> {
  List<dynamic> anuncios = [];
  bool isLoading = true;
  bool hasError = false;

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

  void _navigateToEdit(Map<String, dynamic> anuncio) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarAnuncioFormScreen(anuncio: anuncio),
      ),
    );
    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Anuncio"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar anuncios"))
              : ListView.builder(
                  itemCount: anuncios.length,
                  itemBuilder: (context, index) {
                    final anuncio = anuncios[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(anuncio['nombre'] ?? 'Sin título'),
                        subtitle: Text("Fecha: ${anuncio['fecha']} - Hora: ${anuncio['hora']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToEdit(anuncio),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

/// Pantalla con el formulario para editar un anuncio.
class EditarAnuncioFormScreen extends StatefulWidget {
  final Map<String, dynamic> anuncio;

  const EditarAnuncioFormScreen({Key? key, required this.anuncio}) : super(key: key);

  @override
  _EditarAnuncioFormScreenState createState() => _EditarAnuncioFormScreenState();
}

class _EditarAnuncioFormScreenState extends State<EditarAnuncioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _fechaController;
  late TextEditingController _horaController;
  late TextEditingController _detallesController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.anuncio['nombre']);
    _fechaController = TextEditingController(text: widget.anuncio['fecha']);
    _horaController = TextEditingController(text: widget.anuncio['hora']);
    _detallesController = TextEditingController(text: widget.anuncio['detalles']);
  }

  Future<void> _seleccionarFecha() async {
    DateTime initialDate = DateTime.tryParse(_fechaController.text) ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
    );
    if (pickedDate != null) {
      setState(() {
        _fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _seleccionarHora() async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (_horaController.text.isNotEmpty) {
      List<String> parts = _horaController.text.split(":");
      if (parts.length == 2) {
        initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      setState(() {
        _horaController.text = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00"; // Agrega ":00" para el formato HH:mm:ss
      });
    }
  }

  Future<void> _editarAnuncio() async {
    if (!_formKey.currentState!.validate()) return;

    // Mostrar un diálogo de confirmación al presionar "Guardar Cambios"
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar edición"),
          content: const Text("¿Deseas guardar los cambios?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/editar_anuncio.php");
    try {
      final response = await http.post(url, body: {
        "id": widget.anuncio['id'].toString(), // Cambiado a 'id' en lugar de 'idAnuncio'
        "nombre": _nombreController.text,
        "fecha": _fechaController.text,
        "hora": _horaController.text,
        "detalles": _detallesController.text,
      });
      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anuncio actualizado con éxito")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar anuncio: ${data["error"] ?? ""}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Anuncio"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Editar Anuncio",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre del anuncio",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Fecha",
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _seleccionarFecha,
                  validator: (value) => value!.isEmpty ? "Seleccione una fecha" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _horaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Hora",
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _seleccionarHora,
                  validator: (value) => value!.isEmpty ? "Seleccione una hora" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _detallesController,
                  decoration: const InputDecoration(
                    labelText: "Detalles",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _editarAnuncio,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text("Guardar Cambios"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
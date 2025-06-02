import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarEventoScreen extends StatefulWidget {
  final Map<String, dynamic> evento; // Evento a editar

  const EditarEventoScreen({Key? key, required this.evento}) : super(key: key);

  @override
  _EditarEventoScreenState createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar los valores actuales del evento en los controladores
    _tituloController.text = widget.evento['titulo'];
    _descripcionController.text = widget.evento['descripcion'];
    _fechaController.text = widget.evento['fecha'];
    _horaController.text = widget.evento['hora'];
    _lugarController.text = widget.evento['lugar'];
  }

  Future<void> _guardarEdicion() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/editar_evento.php");

    try {
      final response = await http.post(url, body: {
        'id': widget.evento['id'].toString(),
        'titulo': _tituloController.text,
        'descripcion': _descripcionController.text,
        'fecha': _fechaController.text,
        'hora': _horaController.text,
        'lugar': _lugarController.text,
      });

      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evento editado con éxito")),
        );
        Navigator.pop(context, true); // Regresar a la pantalla anterior
      } else {
        final errorMsg = data['error'] ?? "Error desconocido";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al editar: $errorMsg")),
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
      appBar: AppBar(title: const Text("Editar Evento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: "Título"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: "Fecha (YYYY-MM-DD)"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(labelText: "Hora (HH:MM:SS)"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _lugarController,
                decoration: const InputDecoration(labelText: "Lugar"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarEdicion();
                  }
                },
                child: const Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
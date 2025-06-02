import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recursos.dart'; // Para navegar a RecursosScreen al terminar

class EditarRecursoScreen extends StatefulWidget {
  final String id;
  final String nombre;
  final String link;

  const EditarRecursoScreen({Key? key, required this.id, required this.nombre, required this.link}) : super(key: key);

  @override
  _EditarRecursoScreenState createState() => _EditarRecursoScreenState();
}

class _EditarRecursoScreenState extends State<EditarRecursoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombre;
    _linkController.text = widget.link;
  }

  // Muestra el diálogo de confirmación
  void _confirmarGuardado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("¿Desea guardar los cambios en este recurso?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancelar
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              _guardarRecurso();
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }

  // Envía el POST a editar_recursos.php
  Future<void> _guardarRecurso() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/editar_recurso.php");
    try {
      final response = await http.put(url, body: {
        "id": widget.id,
        "nombre": _nombreController.text.trim(),
        "link": _linkController.text.trim(),
      });

      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recurso editado con éxito")),
        );
        // Navegamos de vuelta a RecursosScreen con pushReplacement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RecursosScreen(
              role: "docente",
              name: "Nombre Docente",
              isDarkMode: false,
              onThemeChanged: _dummyOnThemeChanged,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data["message"] ?? "Desconocido"}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  static void _dummyOnThemeChanged(bool val) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Recurso"),
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16.0),
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
                  "Editar Recurso",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Campo Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    prefixIcon: Icon(Icons.library_books),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el nombre del recurso" : null,
                ),
                const SizedBox(height: 10),

                // Campo Link
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: "Link del Recurso",
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el link" : null,
                ),
                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: _confirmarGuardado,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
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
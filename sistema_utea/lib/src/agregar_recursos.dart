import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'recursos.dart'; // Para navegar a RecursosScreen al terminar

class AgregarRecursoScreen extends StatefulWidget {
  const AgregarRecursoScreen({Key? key}) : super(key: key);

  @override
  _AgregarRecursoScreenState createState() => _AgregarRecursoScreenState();
}

class _AgregarRecursoScreenState extends State<AgregarRecursoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES'; // Configura el locale para español
  }

  // Muestra el diálogo de confirmación
  Future<void> _confirmarRegistro() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.blue[50], // Color de fondo del cuadro de diálogo
          title: const Text("Confirmar Registro", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("¿Desea guardar este recurso?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false), // Cierra el diálogo y retorna false
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color del botón Cancelar
              ),
              child: const Text(
                "❌ Cancelar",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Cierra el diálogo y retorna true
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Color del botón Aceptar
              ),
              child: const Text(
                "✅ Aceptar",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _guardarRecurso();
    }
  }

  // Envía el POST a agregar_recursos.php
  Future<void> _guardarRecurso() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_recursos.php");
    try {
      final response = await http.post(url, body: {
        "nombre": _nombreController.text.trim(),
        "link": _linkController.text.trim(),
      });

      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recurso agregado con éxito")),
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
        title: const Text("Agregar Recurso"),
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
                  "Nuevo Recurso",
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
                  onPressed: _confirmarRegistro, // Cambia a la nueva función
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.blue, // Color del botón
                  ),
                  child: const Text("💾 Guardar Recurso", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
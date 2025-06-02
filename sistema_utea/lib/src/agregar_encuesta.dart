import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AgregarEncuestaScreen extends StatefulWidget {
  const AgregarEncuestaScreen({Key? key}) : super(key: key);

  @override
  _AgregarEncuestaScreenState createState() => _AgregarEncuestaScreenState();
}

class _AgregarEncuestaScreenState extends State<AgregarEncuestaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES'; // Establece la localización en español
  }

  // Selecciona fecha con un DatePicker
  Future<void> _seleccionarFecha() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (pickedDate != null) {
      setState(() {
        // Formato yyyy-MM-dd
        _fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Muestra un AlertDialog para confirmar
  Future<void> _confirmarGuardado() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.blue[50], // Color de fondo del cuadro de diálogo
          title: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("¿Desea guardar esta encuesta?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color del botón Cancelar
              ),
              child: const Text("❌ Cancelar", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Cierra el diálogo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Color del botón Aceptar
              ),
              child: const Text("✅ Aceptar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _guardarEncuesta();
    }
  }

  // Envía los datos a agregar_encuesta.php
  Future<void> _guardarEncuesta() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://10.0.2.2/ProyectoColegio/Colegio/agregar_encuesta.php");
    try {
      final response = await http.post(url, body: {
        "titulo": _tituloController.text.trim(),
        "descripcion": _descripcionController.text.trim(),
        "fecha": _fechaController.text.trim(),
      });

      final data = json.decode(response.body);
      if (data["success"] == true) {
        // Encuesta agregada con éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Encuesta agregada con éxito")),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Encuesta"),
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue[100], // Fondo azul del formulario
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
                  "📋 Nueva Encuesta",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Campo Título
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Ingrese el título" : null,
                ),
                const SizedBox(height: 10),

                // Campo Descripción
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? "Ingrese la descripción" : null,
                ),
                const SizedBox(height: 10),

                // Campo Fecha
                TextFormField(
                  controller: _fechaController,
                  decoration: const InputDecoration(
                    labelText: "Fecha (YYYY-MM-DD)",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: _seleccionarFecha,
                  validator: (value) => value!.isEmpty ? "Seleccione la fecha" : null,
                ),
                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: _confirmarGuardado,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.blue, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bordes redondeados
                    ),
                  ),
                  child: const Text("Guardar Encuesta", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
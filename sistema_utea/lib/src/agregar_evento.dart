import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'eventos.dart'; // Importamos para navegar de regreso a EventosScreen

class AgregarEventoScreen extends StatefulWidget {
  const AgregarEventoScreen({Key? key}) : super(key: key);

  @override
  _AgregarEventoScreenState createState() => _AgregarEventoScreenState();
}

class _AgregarEventoScreenState extends State<AgregarEventoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES';
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
        _fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Selecciona hora con un TimePicker
  Future<void> _seleccionarHora() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _horaController.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00"; // Formato HH:mm:ss
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
          backgroundColor: Colors.blue[50],
          title: const Text("Confirmar Registro", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("¿Desea guardar este evento?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("❌ Cancelar", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("✅ Aceptar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _guardarEvento();
    }
  }

  // Envía los datos a agregar_evento.php
  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_evento.php");
    try {
      final response = await http.post(url, body: {
        "titulo": _nombreController.text.trim(), // Cambié "nombre" a "titulo"
        "descripcion": _descripcionController.text.trim(),
        "fecha": _fechaController.text.trim(),
        "hora": _horaController.text.trim(),
      });

      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evento agregado con éxito")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EventosScreen(
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

  // Callback dummy para onThemeChanged
  static void _dummyOnThemeChanged(bool val) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Evento"),
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
                  "📅 Nuevo Evento",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Campo Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: "Título del Evento", // Cambié "Nombre" a "Título"
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el título del evento" : null,
                ),
                const SizedBox(height: 10),

                // Campo Fecha
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Fecha del Evento",
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _seleccionarFecha,
                  validator: (value) =>
                      value!.isEmpty ? "Seleccione la fecha del evento" : null,
                ),
                const SizedBox(height: 10),

                // Campo Hora
                TextFormField(
                  controller: _horaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Hora del Evento",
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _seleccionarHora,
                  validator: (value) =>
                      value!.isEmpty ? "Seleccione la hora del evento" : null,
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
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese la descripción" : null,
                ),
                const SizedBox(height: 15),

                // Botón para Guardar Evento
                ElevatedButton(
                  onPressed: _confirmarGuardado,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.blue, // Color del botón
                  ),
                  child: const Text(
                    "Guardar Evento",
                    style: TextStyle(color: Colors.white), // Texto en blanco
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
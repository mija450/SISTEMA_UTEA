import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AgregarAnuncioScreen extends StatefulWidget {
  const AgregarAnuncioScreen({Key? key}) : super(key: key);

  @override
  _AgregarAnuncioScreenState createState() => _AgregarAnuncioScreenState();
}

class _AgregarAnuncioScreenState extends State<AgregarAnuncioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _detallesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES';
  }

  Future<void> _seleccionarFecha() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _horaController.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00"; // Agrega ":00" para el formato HH:mm:ss
      });
    }
  }

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
          content: const Text("¿Estás seguro de que deseas guardar este anuncio?"),
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
      await _agregarAnuncio();
    }
  }

  Future<void> _agregarAnuncio() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_anuncio.php");
    try {
      final response = await http.post(url, body: {
        "nombre": _nombreController.text,
        "fecha": _fechaController.text,
        "hora": _horaController.text,
        "detalles": _detallesController.text,
      });

      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anuncio agregado con éxito")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al agregar anuncio: ${data["error"] ?? ""}")),
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
      appBar: AppBar(title: const Text("Agregar Anuncio")),
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
                  "📢 Nuevo Anuncio",
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
                  onPressed: _confirmarRegistro,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.blue, // Color del botón
                  ),
                  child: const Text(
                    "💾 Guardar Anuncio",
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
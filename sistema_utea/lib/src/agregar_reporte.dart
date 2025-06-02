import 'package:appcolegio/src/reportes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgregarReporteScreen extends StatefulWidget {
  const AgregarReporteScreen({Key? key}) : super(key: key);

  @override
  _AgregarReporteScreenState createState() => _AgregarReporteScreenState();
}

class _AgregarReporteScreenState extends State<AgregarReporteScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  void _confirmarGuardado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue[50], // Color de fondo del cuadro de diálogo
        title: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Desea guardar este reporte?"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(), // Cancelar
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Color del botón Cancelar
            ),
            child: const Text("❌ Cancelar", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              _guardarReporte();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Color del botón Aceptar
            ),
            child: const Text("✅ Aceptar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarReporte() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_reporte.php");
    try {
      final response = await http.post(url, body: {
        "titulo": _tituloController.text.trim(),
        "descripcion": _descripcionController.text.trim(),
        "fecha": _fechaController.text.trim(),
      });

      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reporte agregado con éxito")),
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

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(), // Cambia a dark() si deseas un tema oscuro
          child: child ?? const SizedBox(),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _fechaController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Reporte"),
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
                  "Nuevo Reporte",
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
                  validator: (value) => value!.isEmpty ? "Ingrese la descripción" : null,
                ),
                const SizedBox(height: 10),

                // Campo Fecha
                TextFormField(
                  controller: _fechaController,
                  decoration: const InputDecoration(
                    labelText: "Fecha",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Hace que el campo sea solo lectura
                  onTap: () => _selectDate(context), // Abre el selector de fecha al tocar
                  validator: (value) => value!.isEmpty ? "Ingrese la fecha" : null,
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
                  child: const Text("Guardar Reporte", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
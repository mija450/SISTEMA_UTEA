import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data'; // Import necesario para Uint8List
import 'package:file_picker/file_picker.dart';

class AgregarAprendizajeScreen extends StatefulWidget {
  const AgregarAprendizajeScreen({Key? key}) : super(key: key);

  @override
  _AgregarAprendizajeScreenState createState() =>
      _AgregarAprendizajeScreenState();
}

class _AgregarAprendizajeScreenState extends State<AgregarAprendizajeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _subtituloController = TextEditingController();

  // Para Web
  Uint8List? _fileBytes;
  String? _fileName;

  // Para Mobile
  String? _filePath;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES'; // Establecer idioma español
  }

  // Función para seleccionar archivo PDF (compatible Web/Mobile)
  Future<void> _seleccionarArchivo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // Si es Web, se obtienen los bytes
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          _fileBytes = result.files.single.bytes;
          _fileName = result.files.single.name;
        } else {
          _filePath = result.files.single.path;
        }
        setState(() {}); // Refrescar UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se seleccionó ningún archivo.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al seleccionar archivo: $e")),
      );
    }
  }

  // Función para subir el aprendizaje (PDF + campos) al servidor
  Future<void> _guardarCurso() async {
    // Verificar que se haya seleccionado un archivo PDF
    if (kIsWeb) {
      if (_fileBytes == null || _fileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, selecciona un archivo PDF.")),
        );
        return;
      }
    } else {
      if (_filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, selecciona un archivo PDF.")),
        );
        return;
      }
    }

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_aprendizaje.php");

    try {
      final request = http.MultipartRequest('POST', url);
      
      // Enviar campos de texto
      request.fields['titulo'] = _tituloController.text;
      request.fields['subtitulo'] = _subtituloController.text;

      // Adjuntar el PDF según la plataforma
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'archivo',
            _fileBytes!,
            filename: _fileName,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('archivo', _filePath!),
        );
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);
      
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aprendizaje agregado con éxito")),
        );
        // Retornamos true para indicar que se guardó el aprendizaje
        Navigator.pop(context, true);
      } else {
        final errorMsg = data['error'] ?? "Error desconocido";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $errorMsg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Muestra un diálogo de confirmación antes de guardar
  void _confirmAndGuardarCurso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue[50], // Color de fondo del cuadro de diálogo
        title: const Text("Confirmación", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Desea guardar el aprendizaje?"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancelar
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Color del botón Cancelar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "❌ Cancelar",
              style: TextStyle(color: Colors.white), // Texto en blanco
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirmar
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Color del botón Aceptar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "✅ Aceptar",
              style: TextStyle(color: Colors.white), // Texto en blanco
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _guardarCurso();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Aprendizaje")),
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
                  "📚 Nuevo Aprendizaje",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _subtituloController,
                  decoration: const InputDecoration(
                    labelText: "Subtítulo",
                    prefixIcon: Icon(Icons.subtitles),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _seleccionarArchivo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("📄 Seleccionar Archivo PDF", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 5),
                if (kIsWeb && _fileName != null)
                  Text("Archivo seleccionado: $_fileName")
                else if (!kIsWeb && _filePath != null)
                  Text("Archivo seleccionado: ${_filePath!.split('/').last}"),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _confirmAndGuardarCurso();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), backgroundColor: Colors.blue, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("💾 Guardar Aprendizaje", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data'; // Import necesario para Uint8List
import 'package:file_picker/file_picker.dart';

class EditarAprendizajeScreen extends StatefulWidget {
  final Map<String, dynamic> aprendizaje; // Recibir el aprendizaje a editar

  const EditarAprendizajeScreen({Key? key, required this.aprendizaje}) : super(key: key);

  @override
  _EditarAprendizajeScreenState createState() => _EditarAprendizajeScreenState();
}

class _EditarAprendizajeScreenState extends State<EditarAprendizajeScreen> {
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
    _tituloController.text = widget.aprendizaje['titulo'];
    _subtituloController.text = widget.aprendizaje['subtitulo'];
  }

  Future<void> _seleccionarArchivo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          _fileBytes = result.files.single.bytes;
          _fileName = result.files.single.name;
        } else {
          _filePath = result.files.single.path;
        }
        setState(() {});
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

  Future<void> _guardarEdicion() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/editar_aprendizaje.php");

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['id'] = widget.aprendizaje['id'].toString();
      request.fields['titulo'] = _tituloController.text;
      request.fields['subtitulo'] = _subtituloController.text;

      if (kIsWeb && _fileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'archivo',
            _fileBytes!,
            filename: _fileName,
          ),
        );
      } else if (_filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('archivo', _filePath!),
        );
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aprendizaje editado con éxito")),
        );
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

  void _confirmAndGuardarEdicion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmación"),
        content: const Text("¿Desea guardar los cambios?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sí"),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _guardarEdicion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Aprendizaje")),
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
                  "📚 Editar Aprendizaje",
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
                  child: const Text("Seleccionar Archivo PDF"),
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
                      _confirmAndGuardarEdicion();
                    }
                  },
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
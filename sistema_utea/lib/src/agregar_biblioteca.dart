import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class AgregarBibliotecaScreen extends StatefulWidget {
  const AgregarBibliotecaScreen({Key? key}) : super(key: key);

  @override
  _AgregarBibliotecaScreenState createState() => _AgregarBibliotecaScreenState();
}

class _AgregarBibliotecaScreenState extends State<AgregarBibliotecaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaPublicacionController = TextEditingController();
  String? _tipoSeleccionado;
  final TextEditingController _enlaceController = TextEditingController();
  String? _archivoPdf;
  String? _categoriaSeleccionada;
  List<Map<String, dynamic>> _categorias = []; // Para almacenar las categorías

  final List<String> _tipos = ['Libro', 'Documento', 'Artículo', 'Otro'];

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES';
    _obtenerCategorias(); // Cargar categorías al iniciar
  }

  Future<void> _obtenerCategorias() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/categoria_biblioteca.php");
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data["success"] == true) {
        setState(() {
          _categorias = List<Map<String, dynamic>>.from(data["data"]); // Almacenar categorías
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data["message"]}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      setState(() {
        _archivoPdf = result.files.single.name; 
      });
    }
  }

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
        _fechaPublicacionController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _confirmarGuardado() async {
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

  Future<void> _guardarRecurso() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_biblioteca.php");
    try {
      final response = await http.post(url, body: {
        "codigo": _codigoController.text.trim(),
        "titulo": _tituloController.text.trim(),
        "autor": _autorController.text.trim(),
        "descripcion": _descripcionController.text.trim(),
        "tipo": _tipoSeleccionado ?? '',
        "enlace": _enlaceController.text.trim(),
        "archivo_pdf": _archivoPdf ?? '',
        "categoria_id": _categoriaSeleccionada ?? '',
        "fecha_publicacion": _fechaPublicacionController.text.trim(), // Agregar fecha de publicación
      });

      final data = json.decode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recurso agregado con éxito")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data["message"]}")),
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
        title: const Text("Agregar Recurso"),
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue[100], // Color de fondo azul
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
                  "📚 Nuevo Recurso",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Campo Código
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    labelText: "Código",
                    prefixIcon: Icon(Icons.code),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Ingrese el código del recurso" : null,
                ),
                const SizedBox(height: 10),

                // Campo Título
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Ingrese el título del recurso" : null,
                ),
                const SizedBox(height: 10),

                // Campo Autor
                TextFormField(
                  controller: _autorController,
                  decoration: const InputDecoration(
                    labelText: "Autor",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Ingrese el autor del recurso" : null,
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

                // Campo Fecha de Publicación
                TextFormField(
                  controller: _fechaPublicacionController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Fecha de Publicación",
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _seleccionarFecha,
                  validator: (value) => value!.isEmpty ? "Seleccione la fecha de publicación" : null,
                ),
                const SizedBox(height: 10),

                // Campo Tipo
                DropdownButtonFormField<String>(
                  value: _tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Tipo",
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: _tipos.map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoSeleccionado = value;
                    });
                  },
                  validator: (value) => value == null ? "Seleccione un tipo" : null,
                ),
                const SizedBox(height: 10),

                // Campo Categoría
                DropdownButtonFormField<String>(
                  value: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria['id'].toString(), // Usar el ID de la categoría
                      child: Text(categoria['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSeleccionada = value;
                    });
                  },
                  validator: (value) => value == null ? "Seleccione una categoría" : null,
                ),
                const SizedBox(height: 10),

                // Botón para seleccionar archivo PDF
                ElevatedButton(
                  onPressed: _seleccionarArchivo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bordes redondeados
                    ),
                  ),
                  child: const Text("📄 Seleccionar Archivo PDF", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                if (_archivoPdf != null) Text("Archivo seleccionado: $_archivoPdf"),

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
                  child: const Text("Guardar Recurso", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
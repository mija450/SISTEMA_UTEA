import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarBibliotecaScreen extends StatefulWidget {
  final Map<String, dynamic> recurso; // Recurso a editar

  const EditarBibliotecaScreen({Key? key, required this.recurso}) : super(key: key);

  @override
  _EditarBibliotecaScreenState createState() => _EditarBibliotecaScreenState();
}

class _EditarBibliotecaScreenState extends State<EditarBibliotecaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _enlaceController = TextEditingController();
  final TextEditingController _archivoPdfController = TextEditingController();
  final TextEditingController _fechaPublicacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar los valores actuales del recurso en los controladores
    _codigoController.text = widget.recurso['codigo'];
    _tituloController.text = widget.recurso['titulo'];
    _descripcionController.text = widget.recurso['descripcion'];
    _autorController.text = widget.recurso['autor'];
    _tipoController.text = widget.recurso['tipo'];
    _enlaceController.text = widget.recurso['enlace'] ?? '';
    _archivoPdfController.text = widget.recurso['archivo_pdf'] ?? '';
    _fechaPublicacionController.text = widget.recurso['fecha_publicacion'] ?? '';
  }

  void _confirmarGuardado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("¿Desea guardar los cambios realizados?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
              _guardarEdicion(); // Llamar a la función para guardar la edición
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarEdicion() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/editar_biblioteca.php");

    try {
      final response = await http.post(url, body: {
        'id': widget.recurso['id'].toString(), // Asegúrate de que el id esté presente
        'codigo': _codigoController.text,
        'titulo': _tituloController.text,
        'descripcion': _descripcionController.text,
        'autor': _autorController.text,
        'tipo': _tipoController.text,
        'enlace': _enlaceController.text,
        'archivo_pdf': _archivoPdfController.text,
        'fecha_publicacion': _fechaPublicacionController.text, // Incluir fecha de publicación
      });

      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recurso editado con éxito")),
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
      appBar: AppBar(title: const Text("Editar Recurso")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: "Código"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
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
                controller: _autorController,
                decoration: const InputDecoration(labelText: "Autor"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: "Tipo"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: _enlaceController,
                decoration: const InputDecoration(labelText: "Enlace (opcional)"),
              ),
              TextFormField(
                controller: _archivoPdfController,
                decoration: const InputDecoration(labelText: "Archivo PDF (opcional)"),
              ),
              TextFormField(
                controller: _fechaPublicacionController,
                decoration: const InputDecoration(labelText: "Fecha de Publicación (YYYY-MM-DD)"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _confirmarGuardado(); // Mostrar el diálogo de confirmación
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
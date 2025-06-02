import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EliminarBibliotecaScreen extends StatelessWidget {
  final String recursoId; // ID del recurso a eliminar

  const EliminarBibliotecaScreen({Key? key, required this.recursoId}) : super(key: key);

  Future<void> _eliminarRecurso(BuildContext context) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_biblioteca.php");

    try {
      final response = await http.post(url, body: {'id': recursoId});

      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recurso eliminado con éxito")),
        );
        Navigator.pop(context, true); // Regresar a la pantalla anterior
      } else {
        final errorMsg = data['error'] ?? "Error desconocido";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: $errorMsg")),
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
    return AlertDialog(
      title: const Text("Confirmar Eliminación"),
      content: const Text("¿Estás seguro de que deseas eliminar este recurso?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo sin eliminar
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () => _eliminarRecurso(context), // Elimina el recurso
          child: const Text("Confirmar"),
        ),
      ],
    );
  }
}
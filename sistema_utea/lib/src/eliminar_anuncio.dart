import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class EliminarAnuncioScreen extends StatefulWidget {
  const EliminarAnuncioScreen({Key? key}) : super(key: key);

  @override
  _EliminarAnuncioScreenState createState() => _EliminarAnuncioScreenState();
}

class _EliminarAnuncioScreenState extends State<EliminarAnuncioScreen> {
  List<dynamic> anuncios = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAnuncios();
  }

  Future<void> _fetchAnuncios() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/comunicacion.php");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            anuncios = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiempo de espera excedido. Verifica tu conexión.")),
      );
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      debugPrint("Error al obtener anuncios: $e");
    }
  }

  Future<void> _deleteAnuncio(String id) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_anuncio.php");
    try {
      final response = await http.delete(url, 
        body: json.encode({"id": id}), 
        headers: {
          "Content-Type": "application/json" // Asegúrate de enviar el contenido como JSON
        }
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anuncio eliminado con éxito")),
        );
        Navigator.pop(context, true); // Regresa a la pantalla anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar anuncio: ${data["error"] ?? ""}"),
          ),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tiempo de espera excedido. Verifica tu conexión."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _confirmDeletion(Map<String, dynamic> anuncio) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar este anuncio?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo sin eliminar
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteAnuncio(anuncio["id"].toString()); // Cambiado a 'id'
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnuncioItem(Map<String, dynamic> anuncio) {
    final title = anuncio["nombre"] ?? "Sin título";
    final details = "Fecha: ${anuncio["fecha"]}\n"
        "Hora: ${anuncio["hora"]}\n"
        "Detalles: ${anuncio["detalles"]}";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(details),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeletion(anuncio),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eliminar Anuncio"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar anuncios"))
              : ListView.builder(
                  itemCount: anuncios.length,
                  itemBuilder: (context, index) {
                    return _buildAnuncioItem(anuncios[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, false);
        },
      ),
    );
  }
}
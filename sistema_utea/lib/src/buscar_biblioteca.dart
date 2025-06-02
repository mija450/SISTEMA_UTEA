import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuscarBibliotecaScreen extends StatefulWidget {
  const BuscarBibliotecaScreen({Key? key}) : super(key: key);

  @override
  _BuscarBibliotecaScreenState createState() => _BuscarBibliotecaScreenState();
}

class _BuscarBibliotecaScreenState extends State<BuscarBibliotecaScreen> {
  List<dynamic> recursos = [];
  bool isLoading = false;
  bool hasError = false;
  String searchQuery = '';

  Future<void> _buscarRecursos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/buscar_biblioteca.php");

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.post(url, body: {'query': searchQuery});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            recursos = data['data'];
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
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar Recursos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Ingrese el título o palabra clave",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _buscarRecursos,
              child: const Text("Buscar"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? const Center(child: Text("Error al buscar recursos"))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: recursos.length,
                          itemBuilder: (context, index) {
                            final recurso = recursos[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(recurso['titulo'] ?? "Sin título"),
                                subtitle: Text(recurso['descripcion'] ?? "Sin descripción"),
                                trailing: const Icon(Icons.book, color: Colors.green),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
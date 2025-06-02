import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CofScreen extends StatefulWidget {
  const CofScreen({Key? key}) : super(key: key);

  @override
  _CofScreenState createState() => _CofScreenState();
}

class _CofScreenState extends State<CofScreen> {
  Map<String, List<dynamic>> _data = {};
  Map<String, bool> _isExpanded = {};

  Future<void> fetchData(String action) async {
    final url = Uri.parse('http://127.0.0.1/ProyectoColegio/Colegio/cof.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            _data[action] = jsonResponse['data'];
            _isExpanded[action] = !_isExpanded[action]!;
          });
        } else {
          setState(() {
            _data[action] = [];
            _isExpanded[action] = !_isExpanded[action]!;
          });
        }
      } else {
        throw Exception('Error al cargar los datos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _data[action] = [];
        _isExpanded[action] = !_isExpanded[action]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Personas'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de imagen
            Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner3.png'), // Ruta de tu imagen
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lista',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  _buildOptionTile('👩‍🎓 Ver Alumnos', 'getAlumnos'),
                  _buildOptionTile('👨‍🏫 Ver Docentes', 'getDocentes'),
                  _buildOptionTile('🏢 Oficina de Dirección', 'getDireccion'),
                  _buildOptionTile('📚 Ver Cursos', 'getCursos'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, String action) {
    _isExpanded.putIfAbsent(action, () => false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(_isExpanded[action]! ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              fetchData(action);
            },
          ),
          if (_isExpanded[action]!)
            _data.containsKey(action) && _data[action]!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _data[action]!.map((item) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item['nombre'] ?? item['descripcion'] ?? 'Sin información',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text("No hay datos disponibles."),
                  ),
        ],
      ),
    );
  }
}
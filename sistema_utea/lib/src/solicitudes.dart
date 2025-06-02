import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  _SolicitudesScreenState createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  List<dynamic> _solicitudes = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSolicitudes();
  }

  Future<void> _fetchSolicitudes() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/solicitudes.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _solicitudes = data['data'];
            isLoading = false;
            hasError = false;
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
    }
  }

  // Aprobar usuario
  Future<void> _aprobarUsuario(int idUsuario) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/aprobar_usuario.php");
    try {
      final response = await http.post(url, body: {
        'idUsuario': idUsuario.toString(),
      });
      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario aprobado con éxito")),
        );
        setState(() {
          _solicitudes.removeWhere((user) => int.parse(user['idUsuario']) == idUsuario);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Eliminar usuario
  Future<void> _eliminarUsuario(int idUsuario) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_usuario.php");
    try {
      final response = await http.post(url, body: {
        'idUsuario': idUsuario.toString(),
      });
      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado con éxito")),
        );
        setState(() {
          _solicitudes.removeWhere((user) => int.parse(user['idUsuario']) == idUsuario);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Confirmar aprobación
  void _confirmarAprobacion(int idUsuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Aprobar Usuario"),
        content: const Text("¿Deseas aprobar este usuario?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _aprobarUsuario(idUsuario);
            },
            child: const Text("Aprobar"),
          ),
        ],
      ),
    );
  }

  // Confirmar eliminación
  void _confirmarEliminacion(int idUsuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Usuario"),
        content: const Text("¿Deseas eliminar este usuario?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarUsuario(idUsuario);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
      ),
      body: Column(
        children: [
          // Banner de imagen
          Container(
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banner2.png'), // Ruta de tu imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? const Center(child: Text("Error al cargar solicitudes"))
                    : _solicitudes.isEmpty
                        ? const Center(child: Text("No hay solicitudes pendientes"))
                        : ListView.builder(
                            itemCount: _solicitudes.length,
                            itemBuilder: (context, index) {
                              final user = _solicitudes[index];
                              final int idUsuario = int.parse(user['idUsuario']);
                              final nombre = user['nombre'] ?? "";
                              final correo = user['correo'] ?? "";
                              final rol = user['rol'] ?? "";
                              return Card(
                                child: ListTile(
                                  title: Text(nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("Correo: $correo\nRol: $rol"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _confirmarAprobacion(idUsuario),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _confirmarEliminacion(idUsuario),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
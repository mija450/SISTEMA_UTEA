import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'solicitudes.dart';
import 'editar_perfil.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilScreen extends StatefulWidget {
  final String name;
  final String role;

  const PerfilScreen({Key? key, required this.name, required this.role}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String nombre = "";
  String correo = "";
  String rol = "";
  File? _imagenSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
    _validarSesion();
  }

  Future<void> _cargarPerfil() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/perfil.php");
    try {
      final response = await http.post(url, body: {'nombre': widget.name});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            nombre = data['data']['nombre'] ?? 'Desconocido';
            correo = data['data']['correo'] ?? 'No disponible';
            rol = data['data']['rol'] ?? 'No asignado';
          });
        } else {
          _mostrarSnackbar(data['message']);
        }
      } else {
        _mostrarSnackbar("Error al obtener perfil: ${response.reasonPhrase}");
      }
    } catch (e) {
      _mostrarSnackbar("Error de conexión: $e");
    }
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _irEditarPerfil() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditarPerfilScreen(nombreActual: nombre, correoActual: correo)))
        .then((resultado) {
      if (mounted && resultado == true) {
        _cargarPerfil();
      }
    });
  }

  Future<void> _validarSesion() async {
    final sessionActive = await _verificarSesion();
    if (!sessionActive) {
      _logout();
    }
  }

  Future<bool> _verificarSesion() async {
    return true; // Suponiendo que la sesión está activa
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
      await _subirImagen();
    } else {
      _mostrarSnackbar("No se seleccionó ninguna imagen.");
    }
  }

  Future<void> _subirImagen() async {
    if (_imagenSeleccionada == null) {
      _mostrarSnackbar("No hay imagen seleccionada.");
      return;
    }

    final uri = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/upload_image.php");

    var request = http.MultipartRequest('POST', uri);
    request.fields['nombre'] = widget.name;

    var imagen = await http.MultipartFile.fromPath('imagen', _imagenSeleccionada!.path);
    request.files.add(imagen);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        _mostrarSnackbar("Imagen de perfil actualizada.");
        _cargarPerfil();
      } else {
        _mostrarSnackbar("Error al subir la imagen.");
      }
    } catch (e) {
      _mostrarSnackbar("Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 8),
            const Text('Perfil'),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        color: Colors.white, // Cambiar el fondo a blanco
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _seleccionarImagen,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _imagenSeleccionada != null
                        ? FileImage(_imagenSeleccionada!)
                        : NetworkImage('http://127.0.0.1/ProyectoColegio/Colegio/images/${widget.name}.png') as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.camera_alt, color: Colors.black.withOpacity(0.7)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'PERFIL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileContainer(),
                const SizedBox(height: 20),
                // Aviso de mensajes pendientes
                _buildMessageNotification(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _irEditarPerfil,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👤 Información del Usuario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text('Nombre: ${_formatearTexto(nombre)}', style: const TextStyle(color: Colors.black)),
          const SizedBox(height: 5),
          Text('Correo Electrónico: ${_formatearTexto(correo)}', style: const TextStyle(color: Colors.black)),
          const SizedBox(height: 5),
          Text('Rol: ${_formatearTexto(rol)}', style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildMessageNotification() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text('Tienes mensajes pendientes y notificaciones.', style: TextStyle(color: Colors.black))),
        ],
      ),
    );
  }

  String _formatearTexto(String? texto) {
    return texto?.isEmpty ?? true ? '-' : texto!;
  }
}
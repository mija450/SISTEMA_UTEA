import 'package:flutter/material.dart';

// Pantalla Principal de Configuración
class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  List<Color> backgroundColors = [Colors.blue, Colors.pink];

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seleccionar Degradado"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGradientOption("Azul a Amarillo", [Colors.blueAccent, Colors.yellowAccent]),
                _buildGradientOption("Verde a Azul", [Colors.green, Colors.blue]),
                _buildGradientOption("Morado a Rosa", [Colors.purple, Colors.pink]),
                _buildGradientOption("Azul a Negro", [Colors.blue, Colors.black]),
                _buildGradientOption("Rojo a Amarillo", [Colors.red, Colors.yellow]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOption(String title, List<Color> colors) {
    return GestureDetector(
      onTap: () {
        setState(() {
          backgroundColors = colors;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _navigateToDetail(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Configuración ⚙️', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showColorDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120.0,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner10.png'), // Banner completo
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Opciones de Configuración',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildConfiguracionOption('Perfil', 'Modificar datos personales', Icons.person),
                    _buildConfiguracionOption('Notificaciones', 'Gestionar alertas y avisos', Icons.notifications),
                    _buildConfiguracionOption('Privacidad', 'Ajustes de seguridad y privacidad', Icons.lock),
                    _buildConfiguracionOption('Idioma', 'Seleccionar idioma de la app', Icons.language),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfiguracionOption(String title, String description, IconData icon) {
    return GestureDetector(
      onTap: () {
        _navigateToDetail(title);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de Detalle para cada opción
class DetailScreen extends StatelessWidget {
  final String title;
  const DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Text(
          'Aquí puedes modificar la configuración de: $title',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

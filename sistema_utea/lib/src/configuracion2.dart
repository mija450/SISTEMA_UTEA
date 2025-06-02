import 'package:flutter/material.dart';

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
          title: const Text("🎨 Seleccionar Degradado"),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _navigateToDetail(String option) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(option: option),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('⚙️ Configuración', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette, color: Colors.white),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/banner10.png',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Opciones de Configuración',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
      ),
    );
  }

  Widget _buildConfiguracionOption(String title, String subtitle, IconData icon) {
    return Card(
      color: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
        onTap: () => _navigateToDetail(title),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String option;
  const DetailScreen({super.key, required this.option});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool notificationsEnabled = true;
  bool isPrivate = false;
  String selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (widget.option) {
      case 'Perfil':
        content = Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user.png'), // Imagen de usuario
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
        break;
      case 'Notificaciones':
        content = Column(
          children: [
            SwitchListTile(
              title: const Text('Habilitar Notificaciones'),
              value: notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Guardar'),
            ),
          ],
        );
        break;
      case 'Privacidad':
        content = Column(
          children: [
            SwitchListTile(
              title: const Text('Cuenta Privada'),
              value: isPrivate,
              onChanged: (bool value) {
                setState(() {
                  isPrivate = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Actualizar Privacidad'),
            ),
          ],
        );
        break;
      case 'Idioma':
        content = Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Selecciona tu idioma',
                border: OutlineInputBorder(),
              ),
              items: ['Español', 'Inglés', 'Francés', 'Alemán']
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Aplicar Idioma'),
            ),
          ],
        );
        break;
      default:
        content = const Center(
          child: Text('Sin contenido disponible'),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.option),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(child: content),
      ),
    );
  }
}

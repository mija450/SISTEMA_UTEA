import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  List<Color> backgroundColors = [Colors.white];

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("🎨 Seleccionar Color de Fondo"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildGradientOption("Blanco", [Colors.white]),
                _buildGradientOption("Gris Claro", [Colors.grey.shade200]),
                _buildGradientOption("Beige", [Colors.amber.shade100]),
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
          color: colors[0],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
        color: backgroundColors[0],
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3, // Three columns
                    padding: const EdgeInsets.all(4), // Reduced padding
                    childAspectRatio: 1.0, // Adjust aspect ratio for a square fit
                    children: [
                      _buildConfiguracionButton('Perfil', Icons.person),
                      _buildConfiguracionButton('Notificaciones', Icons.notifications),
                      _buildConfiguracionButton('Privacidad', Icons.lock),
                      _buildConfiguracionButton('Idioma', Icons.language),
                      _buildConfiguracionButton('Tema', Icons.brightness_4),
                      _buildConfiguracionButton('Sincronización', Icons.sync),
                      _buildConfiguracionButton('Acerca de', Icons.info_outline),
                      _buildConfiguracionButton('Ayuda', Icons.help_outline),
                      SizedBox.shrink(), // Add an empty widget to fill the 3x3 grid
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

  Widget _buildConfiguracionButton(String title, IconData icon) {
    return Card(
      color: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Reduced border radius
      elevation: 4,
      margin: const EdgeInsets.all(4), // Reduced margin
      child: InkWell(
        onTap: () => _navigateToDetail(title),
        borderRadius: BorderRadius.circular(8), // Match border radius
        child: Container(
          padding: const EdgeInsets.all(8), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24), // Smaller icon
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Smaller font size
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- DETALLE --------------------

class DetailScreen extends StatefulWidget {
  final String option;
  const DetailScreen({Key? key, required this.option}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool notificationsEnabled = true;
  bool isPrivate = false;
  String selectedLanguage = 'Español';
  bool darkMode = false;
  bool syncEnabled = true;
  String name = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (widget.option) {
      case 'Perfil':
        content = Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user.png'),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => name = val,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => email = val,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSnackBar("Cambios guardados para $name");
              },
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
              onChanged: (val) => setState(() => notificationsEnabled = val),
            ),
            ElevatedButton(
              onPressed: () {
                _showSnackBar("Preferencias de notificaciones actualizadas");
              },
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
              onChanged: (val) => setState(() => isPrivate = val),
            ),
            ElevatedButton(
              onPressed: () => _showSnackBar("Configuración de privacidad actualizada"),
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
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (lang) => setState(() => selectedLanguage = lang!),
            ),
            ElevatedButton(
              onPressed: () => _showSnackBar("Idioma cambiado a $selectedLanguage"),
              child: const Text('Aplicar Idioma'),
            ),
          ],
        );
        break;

      case 'Tema':
        content = Column(
          children: [
            SwitchListTile(
              title: const Text('Modo Oscuro'),
              value: darkMode,
              onChanged: (val) => setState(() => darkMode = val),
            ),
            ElevatedButton(
              onPressed: () => _showSnackBar(darkMode ? "Modo oscuro activado" : "Modo claro activado"),
              child: const Text('Guardar Tema'),
            ),
          ],
        );
        break;

      case 'Sincronización':
        content = Column(
          children: [
            SwitchListTile(
              title: const Text('Habilitar Sincronización'),
              value: syncEnabled,
              onChanged: (val) => setState(() => syncEnabled = val),
            ),
            ElevatedButton(
              onPressed: () => _showSnackBar(syncEnabled ? "Sincronización activada" : "Sincronización desactivada"),
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
        break;

      case 'Acerca de':
        content = const Column(
          children: [
            Icon(Icons.info_outline, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text("Versión 1.0.0", style: TextStyle(fontSize: 18)),
            Text("App de Configuración Personalizada", textAlign: TextAlign.center),
          ],
        );
        break;

      case 'Ayuda':
        content = const Column(
          children: [
            Icon(Icons.help_outline, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text("Centro de Ayuda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("¿Necesitas asistencia? Visita nuestro sitio web o contáctanos."),
          ],
        );
        break;

      default:
        content = const Center(child: Text('Sin contenido disponible'));
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
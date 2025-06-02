import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  List<Color> backgroundColors = [Colors.white];
  bool notificationsEnabled = true;
  bool darkMode = false;
  String selectedLanguage = 'Español';
  bool privacyEnabled = false;
  bool syncEnabled = true;
  String name = '';
  String email = '';

  // Para controlar qué panel está abierto
  int _expandedPanelIndex = -1;

  final List<String> languages = ['Español', 'Inglés', 'Francés', 'Alemán'];

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎨 Seleccionar Color de Fondo"),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _colorOption("Blanco", [Colors.white]),
            _colorOption("Gris Claro", [Colors.grey.shade200]),
            _colorOption("Beige", [Colors.amber.shade100]),
            _colorOption("Azul Claro", [Colors.lightBlue.shade100]),
            _colorOption("Lavanda", [Color(0xffe0c3fc)]),
            _colorOption("Turquesa", [Color(0xff8ec5fc)]),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _colorOption(String name, List<Color> colors) {
    return GestureDetector(
      onTap: () {
        setState(() {
          backgroundColors = colors;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Color de fondo cambiado a $name')),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: 1),
        ),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors.length == 1 ? backgroundColors[0] : null,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('⚙️ Configuración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar color de fondo',
            onPressed: _showColorDialog,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundColors.length > 1
              ? LinearGradient(
                  colors: backgroundColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Opciones de Configuración",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.zero,
                    elevation: 0,
                    expansionCallback: (panelIndex, isExpanded) {
                      setState(() {
                        _expandedPanelIndex = isExpanded ? -1 : panelIndex;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: Icon(Icons.person_outline,
                                color: Colors.blueAccent),
                            title: Text('Perfil'),
                          );
                        },
                        body: _perfilPanel(),
                        isExpanded: _expandedPanelIndex == 0,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: Icon(Icons.notifications_outlined,
                                color: Colors.deepPurple),
                            title: Text('Notificaciones'),
                          );
                        },
                        body: _notificacionesPanel(),
                        isExpanded: _expandedPanelIndex == 1,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading:
                                Icon(Icons.lock_outline, color: Colors.orange),
                            title: Text('Privacidad'),
                          );
                        },
                        body: _privacidadPanel(),
                        isExpanded: _expandedPanelIndex == 2,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: Icon(Icons.language_outlined,
                                color: Colors.teal),
                            title: Text('Idioma'),
                          );
                        },
                        body: _idiomaPanel(),
                        isExpanded: _expandedPanelIndex == 3,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: Icon(Icons.brightness_6_outlined,
                                color: Colors.indigo),
                            title: Text('Tema'),
                          );
                        },
                        body: _temaPanel(),
                        isExpanded: _expandedPanelIndex == 4,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: Icon(Icons.sync_outlined,
                                color: Colors.green),
                            title: Text('Sincronización'),
                          );
                        },
                        body: _sincronizacionPanel(),
                        isExpanded: _expandedPanelIndex == 5,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: Icon(Icons.info_outline,
                                color: Colors.blueGrey),
                            title: Text('Acerca de'),
                          );
                        },
                        body: _acercaDePanel(),
                        isExpanded: _expandedPanelIndex == 6,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading:
                                Icon(Icons.help_outline, color: Colors.orange),
                            title: Text('Ayuda'),
                          );
                        },
                        body: _ayudaPanel(),
                        isExpanded: _expandedPanelIndex == 7,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _perfilPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: const AssetImage('assets/images/user.png'),
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (val) => setState(() => name = val),
            controller: TextEditingController(text: name),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            onChanged: (val) => setState(() => email = val),
            controller: TextEditingController(text: email),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: const Text("Guardar Cambios"),
          ),
        ],
      ),
    );
  }

  Widget _notificacionesPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Habilitar Notificaciones'),
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() => notificationsEnabled = val);
              _saveSettings();
            },
            activeColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _privacidadPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Cuenta Privada'),
            value: privacyEnabled,
            onChanged: (val) => setState(() => privacyEnabled = val),
            activeColor: Colors.orange,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Privacidad actualizada')),
              );
            },
            child: const Text('Actualizar Privacidad'),
          ),
        ],
      ),
    );
  }

  Widget _idiomaPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'Selecciona tu idioma',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.language),
            ),
            items: languages
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedLanguage = val);
                _saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Idioma cambiado a $val')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Aplicar Idioma'),
          ),
        ],
      ),
    );
  }

  Widget _temaPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Modo Oscuro'),
            value: darkMode,
            onChanged: (val) {
              setState(() => darkMode = val);
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        val ? "Modo oscuro activado" : "Modo claro activado")),
              );
            },
            activeColor: Colors.indigo,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Guardar Tema'),
          ),
        ],
      ),
    );
  }

  Widget _sincronizacionPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Habilitar Sincronización'),
            value: syncEnabled,
            onChanged: (val) => setState(() => syncEnabled = val),
            activeColor: Colors.green,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sincronización actualizada')),
              );
            },
            child: const Text('Sincronizar Ahora'),
          ),
        ],
      ),
    );
  }

  Widget _acercaDePanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: const Text(
        "Aplicación de ejemplo para configuración avanzada.\n\n"
        "Versión: 2.0.1\n"
        "Desarrollador: Tu Nombre\n"
        "Email: soporte@tuempresa.com\n"
        "© 2025 Todos los derechos reservados.",
        style: TextStyle(fontSize: 16, height: 1.4),
      ),
    );
  }

  Widget _ayudaPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "¿Necesitas ayuda?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            "• Visita nuestro sitio web: www.tuempresa.com/ayuda\n"
            "• Contáctanos vía email: soporte@tuempresa.com\n"
            "• Preguntas frecuentes disponibles en la app\n"
            "• Soporte 24/7 vía chat",
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Simular acción de abrir FAQ o chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abriendo soporte...')),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Contactar Soporte"),
          )
        ],
      ),
    );
  }
}

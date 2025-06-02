import 'package:flutter/material.dart';

class SoporteScreen extends StatefulWidget {
  const SoporteScreen({super.key});

  @override
  _SoporteScreenState createState() => _SoporteScreenState();
}

class _SoporteScreenState extends State<SoporteScreen> {
  List<Color> backgroundColors = [Colors.blue, Colors.pink];
  List<Map<String, dynamic>> soporteOptions = [
    {"icon": Icons.support_agent, "title": "Contacto", "description": "Soporte técnico y consultas", "route": "contacto"},
    {"icon": Icons.help_outline, "title": "FAQ", "description": "Preguntas frecuentes", "route": "faq"},
    {"icon": Icons.bug_report, "title": "Reportar un problema", "description": "Informar un error", "route": "reportar"},
    {"icon": Icons.lightbulb_outline, "title": "Sugerencias", "description": "Enviar tus ideas y mejoras", "route": "sugerencias"},
    {"icon": Icons.email, "title": "Soporte por correo", "description": "Envíanos un correo", "route": "correo"},
    {"icon": Icons.chat, "title": "Chat en vivo", "description": "Habla con un asistente", "route": "chat"},
    {"icon": Icons.phone, "title": "Soporte Telefónico", "description": "Llama para ayuda", "route": "telefono"},
    {"icon": Icons.video_library, "title": "Videos Tutoriales", "description": "Aprende visualmente", "route": "tutoriales"},
    {"icon": Icons.update, "title": "Actualizaciones", "description": "Novedades y noticias", "route": "actualizaciones"},
  ];

  String searchQuery = "";

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Seleccionar Degradado", style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _openAssistant() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          String assistantResponse = "¿Tienes alguna duda? Estos son los temas más preguntados:";

          void _handleAssistantQuestionTap(String question, String answer) {
            setState(() {
              assistantResponse = answer;
            });
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                assistantResponse = "¿Tienes alguna duda? Estos son los temas más preguntados:";
              });
            });
          }

          return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) => Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  const Text('🤖 Asistente Automático', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(assistantResponse),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text("¿Cómo contacto con soporte?"),
                    subtitle: const Text("Puedes usar el botón de contacto o enviarnos un correo."),
                    onTap: () => _handleAssistantQuestionTap(
                      "¿Cómo contacto con soporte?",
                      "Para contactar con soporte, puedes usar el botón de 'Contacto' en la pantalla principal o enviarnos un correo a [tu_correo_de_soporte].",
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("¿Cómo recupero mi contraseña?"),
                    subtitle: const Text("En la pantalla de inicio, pulsa '¿Olvidaste tu contraseña?'."),
                    onTap: () => _handleAssistantQuestionTap(
                      "¿Cómo recupero mi contraseña?",
                      "Para recuperar tu contraseña, ve a la pantalla de inicio e intenta iniciar sesión. Allí encontrarás la opción '¿Olvidaste tu contraseña?'. Sigue los pasos indicados.",
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("¿Cómo actualizo mi app?"),
                    subtitle: const Text("Busca actualizaciones en Google Play o App Store."),
                    onTap: () => _handleAssistantQuestionTap(
                      "¿Cómo actualizo mi app?",
                      "Para actualizar la aplicación, busca '[Nombre de tu App]' en Google Play Store (Android) o App Store (iOS) y selecciona la opción 'Actualizar' si está disponible.",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("¿No encontraste tu respuesta? Contacta con un agente 💬"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🆘 Centro de Soporte 🆘', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[900],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorDialog,
            tooltip: "Cambiar fondo",
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _openAssistant,
            tooltip: "Asistente automático",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Opciones de Soporte', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contacto'),
              onTap: () { /* Lógica de contacto */ },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Acerca de'),
              onTap: () { /* Lógica de acerca de */ },
            ),
          ],
        ),
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
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Buscar en soporte...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.white.withOpacity(0.8),
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: soporteOptions.length,
                  itemBuilder: (context, index) {
                    var option = soporteOptions[index];
                    if (option['title'].toLowerCase().contains(searchQuery)) {
                      return _buildSoporteOption(option['icon'], option['title'], option['description'], option['route']);
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAssistant,
        child: const Icon(Icons.question_answer),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Ayuda Rápida',
      ),
    );
  }

  Widget _buildSoporteOption(IconData icon, String title, String description, String route) {
    return GestureDetector(
      onTap: () => _navigateToSupportDetail(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSupportDetail(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportDetailScreen(route: route),
      ),
    );
  }
}

class SupportDetailScreen extends StatelessWidget {
  final String route;
  const SupportDetailScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de $route"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Ayuda para: $route', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Aquí puedes incluir información detallada o formularios interactivos para cada opción.'),
          ],
        ),
      ),
    );
  }
}
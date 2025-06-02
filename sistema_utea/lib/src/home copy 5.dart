import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Importación de pantallas
import 'calendario.dart';
import 'login.dart';
import 'perfil.dart';
import 'actividades.dart';
import 'docentes.dart';
import 'cursos.dart';
import 'aulas.dart';
import 'asistencia.dart';
import 'soporte.dart';
import 'configuracion.dart';
import 'notificaciones.dart';
import 'mensajes.dart';
import 'biblioteca.dart'; // Importa la pantalla de la biblioteca
import 'repositorio.dart'; // Importa la pantalla del repositorio

class HomeScreen extends StatefulWidget {
  final String name;
  final String role;

  const HomeScreen({Key? key, required this.name, required this.role})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Colores de fondo predeterminados relacionados con la universidad
  List<Color> backgroundColors = [
    const Color(0xFF005EB8), // Azul fuerte
    const Color(0xFFFFC107), // Amarillo dorado
  ];

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _mainHomeScreen(),
      const NotificacionesScreen(),
      const MensajesScreen(),
      PerfilScreen(name: widget.name, role: widget.role),
      const ConfiguracionScreen(), // Agregar la pantalla de configuración
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ----------------- APP BAR -------------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        'MENU PRINCIPAL',
        style: GoogleFonts.poppins(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.black),
          onPressed: () {
            _showExitConfirmationDialog(); // Muestra el diálogo de confirmación
          },
        ),
      ],
    );
  }

  // ----------------- DIALOGO DE CONFIRMACIÓN -------------------
  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Salida"),
          content: const Text("¿Estás seguro de que deseas salir?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  // Navegar a la pantalla de inicio
                );
              },
              child: const Text("Salir"),
            ),
          ],
        );
      },
    );
  }

  // ----------------- BOTTOM NAV -------------------
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() {
        _selectedIndex = index;
      }),
      selectedItemColor: Colors.orange, // Color de selección
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.bell), label: 'Notificaciones'),
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageSquare), label: 'Mensajes'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Perfil'),
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings), label: 'Configuración'),
        // Ícono de configuración
      ],
    );
  }

  // ----------------- HOME PRINCIPAL -------------------
  Widget _mainHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildBannerLinks(),
          const SizedBox(height: 20),
          _buildSectionTitle('Accesos rápidos'),
          _buildQuickAccess(),
          const SizedBox(height: 20),
          _buildUpcomingEvents(),
          const SizedBox(height: 20),
          _buildAcademicResources(),
        ],
      ),
    );
  }

  // ----------------- HEADER -------------------
  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.orange,
          child: Icon(Icons.person, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.orange, Colors.yellow],
              ).createShader(bounds),
              child: Text(
                '¡Hola, ${widget.name}!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.role == 'docente'
                  ? 'Bienvenido Docente'
                  : 'Bienvenido Estudiante',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  // ----------------- ACCESOS RÁPIDOS -------------------
  Widget _buildQuickAccess() {
    final options = [
      _buildMenuCard(LucideIcons.user, 'Perfil',
          PerfilScreen(name: widget.name, role: widget.role)),
      _buildMenuCard(
          LucideIcons.clipboardList, 'Actividades', const ActividadesScreen()),
      _buildMenuCard(LucideIcons.users, 'Docentes', const DocentesScreen()),
      _buildMenuCard(LucideIcons.bookOpen, 'Cursos', const CursosScreen()),
      _buildMenuCard(LucideIcons.layoutGrid, 'Aulas', const AulasScreen()),
      _buildMenuCard(
          LucideIcons.checkSquare, 'Asistencia', const AsistenciaScreen()),
      _buildMenuCard(LucideIcons.helpCircle, 'Soporte', const SoporteScreen()),
      _buildMenuCard(
          LucideIcons.settings, 'Configuración', const ConfiguracionScreen()),
      _buildMenuCard(
          LucideIcons.calendar, 'Calendario', const CalendarioScreen()),
    ];

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: options,
    );
  }

  Widget _buildMenuCard(IconData icon, String label, Widget screen) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.orangeAccent),
              const SizedBox(height: 12),
              Text(label,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- ENLACES RÁPIDOS -------------------
  Widget _buildBannerLinks() {
    final links = [
      _buildBannerButton("UTEA ERP", "https://utea.edu.pe/"),
      _buildBannerButton("Moodle UTEA", "https://aulavirtual.utea.edu.pe/"),
      _buildBannerButton("Correo", "https://mail.google.com/"),
      // _buildBannerButton(
      //     "Biblioteca Virtual", "https://utea.edu.pe/biblioteca-virtual/"), // Original URL
      _buildRouteButton("Biblioteca Virtual", const BibliotecaScreen()),
       _buildRouteButton("Repositorio Institucional", const RepositorioScreen()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Enlaces rápidos"),
        Wrap(spacing: 10, runSpacing: 10, children: links),
      ],
    );
  }

  Widget _buildBannerButton(String label, String url) {
    return ElevatedButton.icon(
      onPressed: () => launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication),
      icon: const Icon(Icons.link),
      label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  // New method for routing to a screen
  Widget _buildRouteButton(String label, Widget screen) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      icon: const Icon(Icons.arrow_forward), // Or any other suitable icon
      label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  // ----------------- EVENTOS -------------------
  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Próximos Eventos"),
        const SizedBox(height: 10),
        _buildEventCard(
            "Charla de innovación", "Miércoles 3 PM", LucideIcons.calendarClock),
        _buildEventCard("Entrega de prácticas", "Viernes 11:59 PM",
            LucideIcons.clipboardCheck),
      ],
    );
  }

  Widget _buildEventCard(String title, String subtitle, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle:
            Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey[600])),
      ),
    );
  }

  // ----------------- RECURSOS ACADÉMICOS -------------------
  Widget _buildAcademicResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Recursos Académicos"),
        const SizedBox(height: 10),
        _buildResourceCard("Biblioteca Virtual", "Accede a libros y recursos en línea",
            LucideIcons.library, const BibliotecaScreen()),
        _buildResourceCard("Repositorio Institucional",
            "Investigaciones y documentos académicos", LucideIcons.archive, const RepositorioScreen()),
      ],
    );
  }

  Widget _buildResourceCard(String title, String description, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text(description, style: GoogleFonts.poppins(color: Colors.grey[600])),
        ),
      ),
    );
  }

  // ----------------- UTILIDADES -------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Seleccionar Tema"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildGradientOption("Azul Profesional",
                  [const Color(0xFF0D47A1), const Color(0xFF42A5F5)]),
              _buildGradientOption(
                  "Verde Moderno", [Colors.teal, Colors.green]),
              _buildGradientOption(
                  "Oscuro Elegante", [Colors.black87, Colors.blueGrey]),
              _buildGradientOption(
                  "Rojo Vibrante", [Colors.redAccent, Colors.orangeAccent]),
              _buildGradientOption("Morado Futurista",
                  [Colors.deepPurple, Colors.purpleAccent]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOption(String name, List<Color> colors) {
    return ListTile(
      title: Text(name),
      onTap: () {
        setState(() => backgroundColors = colors);
        Navigator.pop(context);
      },
    );
  }
}

// Pantalla de Biblioteca Virtual
class BibliotecaScreen extends StatelessWidget {
  const BibliotecaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca Virtual'),
      ),
      body: const Center(
        child: Text('Accede a la Biblioteca Virtual'),
      ),
    );
  }
}

// Pantalla de Repositorio Institucional
class RepositorioScreen extends StatelessWidget {
  const RepositorioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositorio Institucional'),
      ),
      body: const Center(
        child: Text('Explora el Repositorio Institucional'),
      ),
    );
  }
}
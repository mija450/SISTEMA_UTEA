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
import 'biblioteca.dart';
import 'repositorio.dart';

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

  // Color de fondo personalizado
  Color backgroundColor = const Color(0xFF1B2A49); // Color de fondo azul oscuro

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _mainHomeScreen(),
      const NotificacionesScreen(),
      const MensajesScreen(),
      PerfilScreen(name: widget.name, role: widget.role),
      const ConfiguracionScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'MENU PRINCIPAL',
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: _showExitConfirmationDialog,
        ),
      ],
    );
  }

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
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("Salir"),
            ),
          ],
        );
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() {
        _selectedIndex = index;
      }),
      selectedItemColor: Colors.greenAccent, // Color de selección
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: _buildIcon(LucideIcons.home, 'Inicio'),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(LucideIcons.bell, 'Notificaciones'),
          label: 'Notificaciones',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(LucideIcons.messageSquare, 'Mensajes'),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(LucideIcons.user, 'Perfil'),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(LucideIcons.settings, 'Configuración'),
          label: 'Configuración',
        ),
      ],
    );
  }

  Widget _buildIcon(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _selectedIndex == (['Inicio', 'Notificaciones', 'Mensajes', 'Perfil', 'Configuración'].indexOf(label))
              ? Colors.greenAccent
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Icon(icon, color: _selectedIndex == (['Inicio', 'Notificaciones', 'Mensajes', 'Perfil', 'Configuración'].indexOf(label))
          ? Colors.greenAccent
          : Colors.white),
    );
  }

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
          _buildSectionTitle('Accesos Rápidos'),
          _buildQuickAccess(),
          const SizedBox(height: 20),
          _buildUpcomingEvents(),
          const SizedBox(height: 20),
          _buildAcademicResources(),
        ],
      ),
    );
  }

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
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.role == 'docente' ? 'Bienvenido Docente' : 'Bienvenido Estudiante',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccess() {
    final options = [
      _buildMenuCard(LucideIcons.user, 'Perfil', PerfilScreen(name: widget.name, role: widget.role)),
      _buildMenuCard(LucideIcons.clipboardList, 'Actividades', const ActividadesScreen()),
      _buildMenuCard(LucideIcons.users, 'Docentes', const DocentesScreen()),
      _buildMenuCard(LucideIcons.bookOpen, 'Cursos', const CursosScreen()),
      _buildMenuCard(LucideIcons.layoutGrid, 'Aulas', const AulasScreen()),
      _buildMenuCard(LucideIcons.checkSquare, 'Asistencia', const AsistenciaScreen()),
      _buildMenuCard(LucideIcons.helpCircle, 'Soporte', const SoporteScreen()),
      _buildMenuCard(LucideIcons.settings, 'Configuración', const ConfiguracionScreen()),
      _buildMenuCard(LucideIcons.calendar, 'Calendario', const CalendarioScreen()),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF2A3A60), // Color de fondo de los botones
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent, width: 2), // Borde verde neón
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.orangeAccent),
              const SizedBox(height: 12),
              Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerLinks() {
    final links = [
      _buildBannerButton("UTEA ERP", "https://utea.edu.pe/"),
      _buildBannerButton("Moodle UTEA", "https://aulavirtual.utea.edu.pe/"),
      _buildBannerButton("Correo", "https://mail.google.com/"),
      _buildRouteButton("Biblioteca Virtual", const BibliotecaScreen()),
      _buildRouteButton("Repositorio Institucional", const RepositorioScreen()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Enlaces Rápidos"),
        Wrap(spacing: 10, runSpacing: 10, children: links),
      ],
    );
  }

  Widget _buildBannerButton(String label, String url) {
    return ElevatedButton.icon(
      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
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

  Widget _buildRouteButton(String label, Widget screen) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      icon: const Icon(Icons.arrow_forward),
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

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Próximos Eventos"),
        const SizedBox(height: 10),
        _buildEventCard("Charla de Innovación", "Miércoles 3 PM", LucideIcons.calendarClock),
        _buildEventCard("Entrega de Prácticas", "Viernes 11:59 PM", LucideIcons.clipboardCheck),
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
        subtitle: Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey[600])),
      ),
    );
  }

  Widget _buildAcademicResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Recursos Académicos"),
        const SizedBox(height: 10),
        _buildResourceCard("Biblioteca Virtual", "Accede a libros y recursos en línea", LucideIcons.library, const BibliotecaScreen()),
        _buildResourceCard("Repositorio Institucional", "Investigaciones y documentos académicos", LucideIcons.archive, const RepositorioScreen()),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
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
// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

import 'animated_bubble_background.dart';

// Importar tus pantallas
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

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(name: 'Usuario', role: 'estudiante'),
  ));
}

class HomeScreen extends StatefulWidget {
  final String name;
  final String role;

  const HomeScreen({required this.name, required this.role});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late List<Offset> _particles;

  final int _particleCount = 100;
  final Color _backgroundColor = const Color(0xFF0F111A);

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _mainScreen(),
      const NotificacionesScreen(),
      const MensajesScreen(),
      PerfilScreen(name: widget.name, role: widget.role),
      const ConfiguracionScreen(),
    ]);
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _generateParticles();
  }

  void _generateParticles() {
    final random = Random();
    _particles = List.generate(_particleCount, (index) {
      return Offset(random.nextDouble(), random.nextDouble());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: ParticlePainter(_particles, _controller.value),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(child: _screens[_selectedIndex]),
                _buildBottomNavigationBar(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bienvenido, ${widget.name}',
            style: GoogleFonts.poppins(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _showExitConfirmationDialog,
          )
        ],
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar salida'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Salir'),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1C1E2A),
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.bell),
          label: 'Notificaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.messageSquare),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.user),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }

  Widget _mainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickAccess(),
          const SizedBox(height: 20),
          _buildExternalLinks(),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    final options = [
      _menuTile("Perfil", LucideIcons.user, PerfilScreen(name: widget.name, role: widget.role)),
      _menuTile("Actividades", LucideIcons.clipboardList, const ActividadesScreen()),
      _menuTile("Docentes", LucideIcons.users, const DocentesScreen()),
      _menuTile("Cursos", LucideIcons.bookOpen, const CursosScreen()),
      _menuTile("Aulas", LucideIcons.layoutGrid, const AulasScreen()),
      _menuTile("Asistencia", LucideIcons.checkSquare, const AsistenciaScreen()),
      _menuTile("Soporte", LucideIcons.helpCircle, const SoporteScreen()),
      _menuTile("Configuración", LucideIcons.settings, const ConfiguracionScreen()),
      _menuTile("Calendario", LucideIcons.calendar, const CalendarioScreen()),
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: options,
    );
  }

  Widget _menuTile(String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2233),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.greenAccent, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.orangeAccent),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enlaces Externos',
          style: GoogleFonts.poppins(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _externalLink("UTEA ERP", "https://utea.edu.pe"),
            _externalLink("Moodle UTEA", "https://aulavirtual.utea.edu.pe"),
            _externalLink("Correo UTEA", "https://mail.google.com"),
          ],
        )
      ],
    );
  }

  Widget _externalLink(String title, String url) {
    return ElevatedButton.icon(
      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      icon: const Icon(Icons.link),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent.withOpacity(0.3);
    for (var p in particles) {
      final dx = (p.dx * size.width + progress * 50) % size.width;
      final dy = (p.dy * size.height + progress * 50) % size.height;
      canvas.drawCircle(Offset(dx, dy), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

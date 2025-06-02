import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<Map<String, String>> todasLasNotificaciones = [
    {
      'titulo': 'Nueva tarea disponible',
      'mensaje': 'Tienes una nueva tarea en el curso de Matemática.',
      'fecha': '2025-05-01',
      'categoria': 'Importante'
    },
    {
      'titulo': 'Recordatorio de asistencia',
      'mensaje': 'Recuerda marcar tu asistencia hoy antes de las 10:00 am.',
      'fecha': '2025-05-01',
      'categoria': 'Recordatorio'
    },
    {
      'titulo': 'Reunión programada',
      'mensaje': 'Tienes una reunión virtual con el docente de Historia mañana.',
      'fecha': '2025-04-30',
      'categoria': 'Eventos'
    },
    {
      'titulo': 'Nueva clase agregada',
      'mensaje': 'Se ha añadido una nueva clase en el curso de Biología.',
      'fecha': '2025-04-29',
      'categoria': 'Importante'
    },
    {
      'titulo': 'Cambios en el horario',
      'mensaje': 'Tu clase de Química ha sido reprogramada.',
      'fecha': '2025-04-28',
      'categoria': 'Eventos'
    },
  ];

  List<Map<String, String>> notificacionesFiltradas = [];
  String categoriaSeleccionada = 'Todas';
  String textoBusqueda = '';

  @override
  void initState() {
    super.initState();
    notificacionesFiltradas = List.from(todasLasNotificaciones);
  }

  void _filtrarNotificaciones() {
    setState(() {
      notificacionesFiltradas = todasLasNotificaciones.where((notificacion) {
        final matchesCategoria = categoriaSeleccionada == 'Todas' ||
            notificacion['categoria'] == categoriaSeleccionada;
        final matchesTexto = notificacion['titulo']!
            .toLowerCase()
            .contains(textoBusqueda.toLowerCase());
        return matchesCategoria && matchesTexto;
      }).toList();
    });
  }

  Future<void> _recargar() async {
    await Future.delayed(const Duration(seconds: 1));
    _filtrarNotificaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _recargar,
              child: notificacionesFiltradas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: notificacionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final item = notificacionesFiltradas[index];
                        return _buildNotificationCard(item);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar notificaciones...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          textoBusqueda = value;
          _filtrarNotificaciones();
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categorias = ['Todas', 'Importante', 'Recordatorio', 'Eventos'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: categorias.map((cat) {
          final selected = categoriaSeleccionada == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  categoriaSeleccionada = cat;
                  _filtrarNotificaciones();
                });
              },
              selectedColor: Colors.blueAccent,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, String> item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(
            Icons.notifications_active,
            color: _getColorPorCategoria(item['categoria']),
            size: 32,
          ),
          title: Text(
            item['titulo'] ?? '',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            item['mensaje'] ?? '',
            style: GoogleFonts.poppins(),
          ),
          trailing: Text(
            item['fecha'] ?? '',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Color _getColorPorCategoria(String? categoria) {
    switch (categoria) {
      case 'Importante':
        return Colors.redAccent;
      case 'Recordatorio':
        return Colors.orangeAccent;
      case 'Eventos':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, color: Colors.grey[400], size: 80),
            const SizedBox(height: 20),
            Text(
              'No hay notificaciones',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Text(
              'Prueba cambiando la categoría o buscando otro texto.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MensajesScreen extends StatefulWidget {
  const MensajesScreen({super.key});

  @override
  State<MensajesScreen> createState() => _MensajesScreenState();
}

class _MensajesScreenState extends State<MensajesScreen> {
  List<Map<String, String>> todosLosMensajes = [
    {
      'remitente': 'Profesor Juan',
      'asunto': 'Revisión de tarea',
      'mensaje': 'Por favor revisa los comentarios que dejé en tu tarea.',
      'fecha': '2025-05-01',
      'categoria': 'Docente'
    },
    {
      'remitente': 'Secretaría',
      'asunto': 'Pago de matrícula',
      'mensaje': 'Recuerda que el plazo para el pago es hasta el viernes.',
      'fecha': '2025-04-30',
      'categoria': 'Secretaría'
    },
    {
      'remitente': 'Dirección',
      'asunto': 'Reunión general',
      'mensaje': 'Hay una reunión general el lunes a las 9:00 am.',
      'fecha': '2025-04-29',
      'categoria': 'Dirección'
    },
    {
      'remitente': 'Profesor Ana',
      'asunto': 'Entrega de práctica',
      'mensaje': 'La entrega será el martes sin falta.',
      'fecha': '2025-04-28',
      'categoria': 'Docente'
    },
  ];

  List<Map<String, String>> mensajesFiltrados = [];
  String textoBusqueda = '';
  String categoriaSeleccionada = 'Todas';

  @override
  void initState() {
    super.initState();
    mensajesFiltrados = List.from(todosLosMensajes);
  }

  void _filtrarMensajes() {
    setState(() {
      mensajesFiltrados = todosLosMensajes.where((msg) {
        final matchesCategoria = categoriaSeleccionada == 'Todas' ||
            msg['categoria'] == categoriaSeleccionada;
        final matchesTexto = msg['remitente']!.toLowerCase().contains(textoBusqueda.toLowerCase()) ||
            msg['asunto']!.toLowerCase().contains(textoBusqueda.toLowerCase());
        return matchesCategoria && matchesTexto;
      }).toList();
    });
  }

  Future<void> _recargarMensajes() async {
    await Future.delayed(const Duration(seconds: 1));
    _filtrarMensajes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recargarMensajes,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _recargarMensajes,
              child: mensajesFiltrados.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: mensajesFiltrados.length,
                      itemBuilder: (context, index) {
                        final msg = mensajesFiltrados[index];
                        return _buildMessageTile(msg);
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
          hintText: 'Buscar por remitente o asunto...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          textoBusqueda = value;
          _filtrarMensajes();
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categorias = ['Todas', 'Docente', 'Secretaría', 'Dirección'];
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
                  _filtrarMensajes();
                });
              },
              selectedColor: Colors.teal,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageTile(Map<String, String> msg) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.mail_outline, color: Colors.teal, size: 30),
        title: Text(
          msg['asunto'] ?? '',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${msg['remitente']} - ${msg['mensaje']}',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        trailing: Text(
          msg['fecha'] ?? '',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        onTap: () => _mostrarDialogoDetalle(msg),
      ),
    );
  }

  void _mostrarDialogoDetalle(Map<String, String> msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          msg['asunto'] ?? '',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('De: ${msg['remitente']}', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(msg['mensaje'] ?? '', style: GoogleFonts.poppins()),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined, color: Colors.grey[400], size: 80),
            const SizedBox(height: 20),
            Text(
              'No hay mensajes',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Text(
              'Prueba buscando con otras palabras o cambiando la categoría.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

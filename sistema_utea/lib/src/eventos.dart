import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'configuraciones_eventos.dart';

class EventosScreen extends StatefulWidget {
  final String role;
  final String name;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const EventosScreen({
    Key? key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _EventosScreenState createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  List<dynamic> eventos = [];
  List<dynamic> eventosFiltrados = [];
  bool isLoading = true;
  bool hasError = false;
  String searchText = "";
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eventos.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            eventos = data['data'];
            _filtrarEventos();
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  void _filtrarEventos() {
    setState(() {
      eventosFiltrados = eventos
          .where((e) =>
              e['titulo'].toLowerCase().contains(searchText.toLowerCase()) ||
              e['descripcion'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();

      eventosFiltrados.sort((a, b) {
        final fechaA = DateTime.tryParse(a['fecha'] ?? '') ?? DateTime(2000);
        final fechaB = DateTime.tryParse(b['fecha'] ?? '') ?? DateTime(2000);
        return ascending ? fechaA.compareTo(fechaB) : fechaB.compareTo(fechaA);
      });
    });
  }

  Future<void> _addOrEditEvento({
    String? id,
    required String titulo,
    required String descripcion,
    required DateTime fecha,
    required String hora,
    required String lugar,
  }) async {
    final url = Uri.parse(
        id == null
            ? "http://127.0.0.1/ProyectoColegio/Colegio/agregar_evento.php"
            : "http://127.0.0.1/ProyectoColegio/Colegio/editar_evento.php");

    final body = {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'lugar': lugar,
    };

    if (id != null) body['id'] = id;

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        _fetchEventos();
      } else {
        print("Error en evento: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _deleteEvento(String id) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eliminar_evento.php");
    try {
      final response = await http.post(url, body: {'id': id});
      if (response.statusCode == 200) _fetchEventos();
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showEventoDialog({Map<String, dynamic>? evento}) {
    String titulo = evento?['titulo'] ?? '';
    String descripcion = evento?['descripcion'] ?? '';
    DateTime? fecha = evento != null ? DateTime.tryParse(evento['fecha']) : null;
    String hora = evento?['hora'] ?? '';
    String lugar = evento?['lugar'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(evento == null ? 'Agregar Evento' : 'Editar Evento'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: titulo),
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (value) => titulo = value,
              ),
              TextField(
                controller: TextEditingController(text: descripcion),
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (value) => descripcion = value,
              ),
              GestureDetector(
                onTap: () async {
                  fecha = await _selectDate(context, fecha);
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      hintText: fecha != null ? DateFormat.yMd().format(fecha!) : 'Seleccionar fecha',
                    ),
                  ),
                ),
              ),
              TextField(
                controller: TextEditingController(text: hora),
                decoration: const InputDecoration(labelText: 'Hora (HH:MM)'),
                onChanged: (value) => hora = value,
              ),
              TextField(
                controller: TextEditingController(text: lugar),
                decoration: const InputDecoration(labelText: 'Lugar'),
                onChanged: (value) => lugar = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(evento == null ? 'Agregar' : 'Guardar'),
            onPressed: () {
              if (titulo.isNotEmpty && descripcion.isNotEmpty && fecha != null && hora.isNotEmpty && lugar.isNotEmpty) {
                _addOrEditEvento(
                  id: evento?['id'],
                  titulo: titulo,
                  descripcion: descripcion,
                  fecha: fecha!,
                  hora: hora,
                  lugar: lugar,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initial) async {
    return await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "docente"
        ? "Sesión activa del docente: ${widget.name}"
        : "Sesión activa del alumno: ${widget.name}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: "Ordenar por fecha",
            onPressed: () {
              ascending = !ascending;
              _filtrarEventos();
            },
          ),
          if (widget.role.toLowerCase() == "docente")
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: "Configuraciones",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionesEventosScreen(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: widget.role.toLowerCase() == "docente"
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _showEventoDialog(),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar eventos"))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/comunicados_portada.png'),
                      const SizedBox(height: 10),
                      Text(sessionText, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar eventos...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          searchText = value;
                          _filtrarEventos();
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: eventosFiltrados.isEmpty
                            ? const Center(child: Text('No se encontraron eventos.'))
                            : ListView.separated(
                                itemCount: eventosFiltrados.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final evento = eventosFiltrados[index];
                                  return ListTile(
                                    title: Text(
                                      evento['titulo'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "${evento['descripcion']}\nFecha: ${evento['fecha']}\nHora: ${evento['hora']}\nLugar: ${evento['lugar']}",
                                    ),
                                    trailing: widget.role.toLowerCase() == "docente"
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.orange),
                                                onPressed: () => _showEventoDialog(evento: evento),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _deleteEvento(evento['id']),
                                              ),
                                            ],
                                          )
                                        : null,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

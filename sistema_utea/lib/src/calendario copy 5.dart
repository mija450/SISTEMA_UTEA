import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Evento {
  final int? id;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final Color color;

  Evento({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.color,
  });

factory Evento.fromJson(Map<String, dynamic> json) {
  int colorValue = 0xFF2196F3; // azul por defecto

  return Evento(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
    titulo: json['title'] ?? '', // <- corregido
    descripcion: json['description'] ?? '', // <- corregido
    fechaInicio: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(), // <- corregido
    fechaFin: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now().add(const Duration(hours: 1)), // <- corregido
    color: Color(colorValue),
  );
}


Map<String, dynamic> toJson() => {
  if (id != null) 'id': id,
  'title': titulo,          // <- corregido
  'description': descripcion, // <- corregido
  'start_date': fechaInicio.toIso8601String(), // <- corregido
  'end_date': fechaFin.toIso8601String(),     // <- corregido
  'color': color.value,
};

}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({Key? key}) : super(key: key);

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  static const String baseUrl = 'http://127.0.0.1/ProyectoColegio/Sistema_Utea/calendario.php';

  List<Evento> eventos = [];
  bool isLoading = false;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  final List<int> years = List.generate(5, (i) => DateTime.now().year - 2 + i);
  final List<int> months = List.generate(12, (i) => i + 1);

  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
    setState(() => isLoading = true);
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'year': selectedYear.toString(),
        'month': selectedMonth.toString(),
      });
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          eventos = data.map((e) => Evento.fromJson(e)).toList();
        });
      } else {
        throw Exception('Error al cargar eventos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar eventos: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _addOrUpdateEvento({Evento? evento}) async {
    final result = await showDialog<Evento>(
      context: context,
      builder: (_) => EventoDialog(evento: evento),
    );
    if (result != null) {
      setState(() => isLoading = true);
      try {
        final isNew = result.id == null;
        final uri = isNew ? Uri.parse(baseUrl) : Uri.parse('$baseUrl?id=${result.id}');
        final response = isNew
            ? await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(result.toJson()))
            : await http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(result.toJson()));

        if (response.statusCode == 200) {
          await _fetchEventos();
        } else {
          throw Exception(isNew ? 'Error al agregar evento' : 'Error al actualizar evento');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteEvento(Evento evento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Deseas eliminar el evento "${evento.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        final uri = Uri.parse('$baseUrl?id=${evento.id}');
        final response = await http.delete(uri);
        if (response.statusCode == 200) {
          await _fetchEventos();
        } else {
          throw Exception('Error al eliminar evento');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  void _changeBackgroundColor(Color color) {
    setState(() => backgroundColor = color);
  }

  String _monthName(int month) => DateFormat.MMMM('es').format(DateTime(0, month));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Eventos'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            tooltip: 'Cambiar color de fondo',
            onPressed: () async {
              final color = await showDialog<Color>(
                context: context,
                builder: (_) => BackgroundColorPickerDialog(initialColor: backgroundColor),
              );
              if (color != null) _changeBackgroundColor(color);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar eventos',
            onPressed: _fetchEventos,
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedYear,
                  items: years
                      .map((year) => DropdownMenuItem(value: year, child: Text(year.toString())))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedYear = value);
                      _fetchEventos();
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: months
                      .map((month) => DropdownMenuItem(value: month, child: Text(_monthName(month))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMonth = value);
                      _fetchEventos();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : eventos.isEmpty
                      ? Center(
                          child: Text(
                            'No hay eventos para ${_monthName(selectedMonth)} $selectedYear',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        )
                      : ListView.builder(
                          itemCount: eventos.length,
                          itemBuilder: (context, i) {
                            final e = eventos[i];
                            return Card(
                              color: e.color.withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              child: ListTile(
                                title: Text(
                                  e.titulo,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: e.color.withOpacity(0.8)),
                                ),
                                subtitle: Text(
                                  '${DateFormat('dd/MM/yyyy HH:mm').format(e.fechaInicio)} - ${DateFormat('dd/MM/yyyy HH:mm').format(e.fechaFin)}\n${e.descripcion}',
                                  style: const TextStyle(height: 1.3),
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 12,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _addOrUpdateEvento(evento: e),
                                      tooltip: 'Editar evento',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _deleteEvento(e),
                                      tooltip: 'Eliminar evento',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateEvento(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar nuevo evento',
      ),
    );
  }
}

class EventoDialog extends StatefulWidget {
  final Evento? evento;
  const EventoDialog({Key? key, this.evento}) : super(key: key);

  @override
  State<EventoDialog> createState() => _EventoDialogState();
}

class _EventoDialogState extends State<EventoDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  Color _color = Colors.blue;

  @override
  void initState() {
    super.initState();
    final e = widget.evento;
    _tituloController = TextEditingController(text: e?.titulo ?? '');
    _descripcionController = TextEditingController(text: e?.descripcion ?? '');
    _fechaInicio = e?.fechaInicio ?? DateTime.now();
    _fechaFin = e?.fechaFin ?? DateTime.now().add(const Duration(hours: 1));
    _color = e?.color ?? Colors.blue;
  }

  Future<void> _pickDateTime({
    required DateTime initialDate,
    required ValueChanged<DateTime> onDateTimePicked,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onDateTimePicked(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.evento == null ? 'Agregar Evento' : 'Editar Evento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un título' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(_fechaInicio)}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDateTime(
                      initialDate: _fechaInicio,
                      onDateTimePicked: (dateTime) {
                        setState(() => _fechaInicio = dateTime);
                        if (_fechaFin.isBefore(_fechaInicio)) {
                          setState(() => _fechaFin = _fechaInicio.add(const Duration(hours: 1)));
                        }
                      },
                    ),
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(_fechaFin)}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDateTime(
                      initialDate: _fechaFin,
                      onDateTimePicked: (dateTime) {
                        if (dateTime.isAfter(_fechaInicio)) {
                          setState(() => _fechaFin = dateTime);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('La fecha de fin debe ser posterior a la de inicio')),
                          );
                        }
                      },
                    ),
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Color: '),
                  GestureDetector(
                    onTap: () async {
                      final color = await showDialog<Color>(
                        context: context,
                        builder: (_) => BackgroundColorPickerDialog(initialColor: _color),
                      );
                      if (color != null) setState(() => _color = color);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final nuevoEvento = Evento(
                id: widget.evento?.id,
                titulo: _tituloController.text.trim(),
                descripcion: _descripcionController.text.trim(),
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
                color: _color,
              );
              Navigator.pop(context, nuevoEvento);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class BackgroundColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const BackgroundColorPickerDialog({Key? key, required this.initialColor}) : super(key: key);

  @override
  State<BackgroundColorPickerDialog> createState() => _BackgroundColorPickerDialogState();
}

class _BackgroundColorPickerDialogState extends State<BackgroundColorPickerDialog> {
  late Color pickedColor;

  @override
  void initState() {
    super.initState();
    pickedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    // Solo un selector simple con algunos colores comunes
    final colors = [
      Colors.white,
      Colors.grey.shade300,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.yellow.shade50,
      Colors.red.shade50,
      Colors.purple.shade50,
      Colors.orange.shade50,
      Colors.black12,
    ];
    return AlertDialog(
      title: const Text('Selecciona color de fondo'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: colors
            .map(
              (c) => GestureDetector(
                onTap: () => setState(() => pickedColor = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: pickedColor == c ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context, pickedColor), child: const Text('Aceptar')),
      ],
    );
  }
}

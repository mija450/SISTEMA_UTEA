import 'dart:convert';
import 'dart:html' as html; // Para soporte web (descarga de CSV)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

// Modelo de datos para un evento
class Evento {
  int? id;
  String titulo;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFin;
  Color color;

  Evento({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.color,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: int.tryParse(json['id']?.toString() ?? ''),
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      color: Color(json['color'] is int ? json['color'] : int.tryParse(json['color']?.toString() ?? '4281558689') ?? 4281558689),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'color': color.value.toString(),
    };
  }
}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({Key? key}) : super(key: key);

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  static const String baseUrl = "http://127.0.0.1/ProyectoColegio/Sistema_Utea/calendario.php";

  List<Evento> eventos = [];
  bool isLoading = false;
  Color backgroundColor = Colors.white;

  // Filtros
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  // Listas para dropdown
  final List<int> years = List.generate(5, (i) => DateTime.now().year - 2 + i);
  final List<int> months = List.generate(12, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Pasamos filtros al backend por query params
      final response = await http.get(Uri.parse('$baseUrl?year=$selectedYear&month=$selectedMonth'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Evento> loadedEventos = data.map((e) => Evento.fromJson(e)).toList();
        setState(() {
          eventos = loadedEventos;
        });
      } else {
        throw Exception('Error al cargar eventos');
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar eventos: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateEvento({Evento? evento}) async {
    final result = await showDialog<Evento>(
      context: context,
      builder: (_) => EventoDialog(evento: evento),
    );
    if (result != null) {
      setState(() {
        isLoading = true;
      });
      try {
        if (result.id == null) {
          // POST
          final response = await http.post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(result.toJson()),
          );
          if (response.statusCode == 200) {
            await _fetchEventos();
          } else {
            throw Exception('Error al agregar evento');
          }
        } else {
          // PUT
          final response = await http.put(
            Uri.parse('$baseUrl?id=${result.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(result.toJson()),
          );
          if (response.statusCode == 200) {
            await _fetchEventos();
          } else {
            throw Exception('Error al actualizar evento');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
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
      setState(() {
        isLoading = true;
      });
      try {
        final response = await http.delete(Uri.parse('$baseUrl?id=${evento.id}'));
        if (response.statusCode == 200) {
          await _fetchEventos();
        } else {
          throw Exception('Error al eliminar evento');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _changeBackgroundColor(Color color) {
    setState(() {
      backgroundColor = color;
    });
  }

  String _monthName(int month) {
    return DateFormat.MMMM('es').format(DateTime(0, month));
  }

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
            // Filtros
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedYear,
                  items: years
                      .map((year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear = value;
                      });
                      _fetchEventos();
                    }
                  },
                  hint: const Text('Año'),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: months
                      .map((month) => DropdownMenuItem<int>(
                            value: month,
                            child: Text(_monthName(month)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMonth = value;
                      });
                      _fetchEventos();
                    }
                  },
                  hint: const Text('Mes'),
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
                          itemBuilder: (context, index) {
                            final evento = eventos[index];
                            return Card(
                              color: evento.color.withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              child: ListTile(
                                title: Text(evento.titulo,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: evento.color.withOpacity(0.8))),
                                subtitle: Text(
                                    '${DateFormat('dd MMM yyyy HH:mm').format(evento.fechaInicio)} - ${DateFormat('dd MMM yyyy HH:mm').format(evento.fechaFin)}\n${evento.descripcion}'),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Editar evento',
                                      onPressed: () => _addOrUpdateEvento(evento: evento),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Eliminar evento',
                                      onPressed: () => _deleteEvento(evento),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Agregar Evento'),
              onPressed: () => _addOrUpdateEvento(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Diálogo para agregar o editar evento
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
  Color _colorEvento = Colors.blue;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.evento?.titulo ?? '');
    _descripcionController = TextEditingController(text: widget.evento?.descripcion ?? '');
    _fechaInicio = widget.evento?.fechaInicio ?? DateTime.now();
    _fechaFin = widget.evento?.fechaFin ?? DateTime.now().add(const Duration(hours: 1));
    _colorEvento = widget.evento?.color ?? Colors.blue;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _fechaInicio : _fechaFin),
    );
    if (time == null) return;

    final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        _fechaInicio = newDateTime;
        if (_fechaFin.isBefore(_fechaInicio)) {
          _fechaFin = _fechaInicio.add(const Duration(hours: 1));
        }
      } else {
        _fechaFin = newDateTime;
        if (_fechaFin.isBefore(_fechaInicio)) {
          _fechaInicio = _fechaFin.subtract(const Duration(hours: 1));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.evento == null ? 'Agregar Evento' : 'Editar Evento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(_fechaInicio)}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDateTime(isStart: true),
                    child: const Text('Seleccionar'),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(_fechaFin)}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDateTime(isStart: false),
                    child: const Text('Seleccionar'),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Color: '),
                  GestureDetector(
                    onTap: () async {
                      final selected = await showDialog<Color>(
                        context: context,
                        builder: (_) => ColorPickerDialog(initialColor: _colorEvento),
                      );
                      if (selected != null) {
                        setState(() {
                          _colorEvento = selected;
                        });
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _colorEvento,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                  )
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
            if (_formKey.currentState!.validate()) {
              final newEvento = Evento(
                id: widget.evento?.id,
                titulo: _tituloController.text.trim(),
                descripcion: _descripcionController.text.trim(),
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
                color: _colorEvento,
              );
              Navigator.pop(context, newEvento);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Diálogo para seleccionar color de fondo
class BackgroundColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const BackgroundColorPickerDialog({Key? key, required this.initialColor}) : super(key: key);

  @override
  State<BackgroundColorPickerDialog> createState() => _BackgroundColorPickerDialogState();
}

class _BackgroundColorPickerDialogState extends State<BackgroundColorPickerDialog> {
  late Color selectedColor;

  final List<Color> colors = [
    Colors.white,
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.yellow.shade50,
    Colors.orange.shade50,
    Colors.pink.shade50,
    Colors.grey.shade200,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar color de fondo'),
      content: Wrap(
        spacing: 12,
        children: colors
            .map((color) => GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                          color: selectedColor == color ? Colors.black : Colors.transparent,
                          width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ))
            .toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context, selectedColor), child: const Text('Aceptar')),
      ],
    );
  }
}

/// Diálogo para seleccionar color (para evento)
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const ColorPickerDialog({Key? key, required this.initialColor}) : super(key: key);

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color selectedColor;

  final List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar color'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: colors
            .map((color) => GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                          color: selectedColor == color ? Colors.black : Colors.transparent,
                          width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ))
            .toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context, selectedColor), child: const Text('Aceptar')),
      ],
    );
  }
}

extension ColorBrightness on Color {
  /// Darken a color por [amount] (0.0 a 1.0)
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Lighten a color por [amount] (0.0 a 1.0)
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
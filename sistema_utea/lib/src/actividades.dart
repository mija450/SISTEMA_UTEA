import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Actividad {
  int id;
  String titulo;
  DateTime fecha;
  TimeOfDay hora;
  String descripcion;

  Actividad({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.descripcion,
  });

  // Método para copiar con modificaciones (útil en edición)
  Actividad copyWith({
    int? id,
    String? titulo,
    DateTime? fecha,
    TimeOfDay? hora,
    String? descripcion,
  }) {
    return Actividad(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}

// Estado y lógica de negocio
class ActividadesProvider extends ChangeNotifier {
  List<Actividad> _allActividades = [];
  List<Actividad> _filteredActividades = [];
  String _searchQuery = '';
  bool _loading = false;
  bool _error = false;
  String _errorMessage = '';
  bool _darkTheme = false;

  // Orden y filtro
  String _ordenCampo = 'fecha'; // fecha o titulo
  bool _ordenAscendente = true;
  DateTime? _fechaInicioFiltro;
  DateTime? _fechaFinFiltro;

  int _nextId = 1;

  ActividadesProvider() {
    _loadInitialData();
  }

  List<Actividad> get actividades => _filteredActividades;
  bool get loading => _loading;
  bool get error => _error;
  String get errorMessage => _errorMessage;
  bool get darkTheme => _darkTheme;
  String get ordenCampo => _ordenCampo;
  bool get ordenAscendente => _ordenAscendente;
  DateTime? get fechaInicioFiltro => _fechaInicioFiltro;
  DateTime? get fechaFinFiltro => _fechaFinFiltro;
  String get searchQuery => _searchQuery;

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    notifyListeners();
  }

  // Carga inicial simulada
  Future<void> _loadInitialData() async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulando fetch
    try {
      // Datos ejemplo
      _allActividades = List.generate(15, (i) {
        return Actividad(
          id: _nextId++,
          titulo: 'Actividad #${i + 1}',
          fecha: DateTime.now().add(Duration(days: i - 7)),
          hora: TimeOfDay(hour: 9 + i % 8, minute: 0),
          descripcion: 'Descripción de la actividad número ${i + 1}',
        );
      });

      _applyFilters();
      _error = false;
    } catch (e) {
      _error = true;
      _errorMessage = 'Error al cargar actividades.';
    }
    _loading = false;
    notifyListeners();
  }

  // Búsqueda con debounce
  Timer? _debounceTimer;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _applyFilters();
      notifyListeners();
    });
  }

  // Ordenar por campo
  void setOrden(String campo) {
    if (_ordenCampo == campo) {
      _ordenAscendente = !_ordenAscendente;
    } else {
      _ordenCampo = campo;
      _ordenAscendente = true;
    }
    _applyFilters();
    notifyListeners();
  }

  // Filtrar por fechas
  void setFechaInicioFiltro(DateTime? fecha) {
    _fechaInicioFiltro = fecha;
    _applyFilters();
    notifyListeners();
  }

  void setFechaFinFiltro(DateTime? fecha) {
    _fechaFinFiltro = fecha;
    _applyFilters();
    notifyListeners();
  }

  // Aplicar filtros y orden
  void _applyFilters() {
    List<Actividad> temp = List.from(_allActividades);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      temp = temp
          .where((a) =>
              a.titulo.toLowerCase().contains(q) ||
              a.descripcion.toLowerCase().contains(q))
          .toList();
    }

    if (_fechaInicioFiltro != null) {
      temp = temp.where((a) => !a.fecha.isBefore(_fechaInicioFiltro!)).toList();
    }
    if (_fechaFinFiltro != null) {
      temp = temp.where((a) => !a.fecha.isAfter(_fechaFinFiltro!)).toList();
    }

    // Orden
    temp.sort((a, b) {
      int cmp = 0;
      if (_ordenCampo == 'fecha') {
        cmp = a.fecha.compareTo(b.fecha);
      } else if (_ordenCampo == 'titulo') {
        cmp = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
      }
      return _ordenAscendente ? cmp : -cmp;
    });

    _filteredActividades = temp;
  }

  // Agregar
  Future<void> agregarActividad(Actividad nueva) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500)); // Simula backend
    _allActividades.add(nueva.copyWith(id: _nextId++));
    _applyFilters();
    _loading = false;
    notifyListeners();
  }

  // Editar
  Future<void> editarActividad(Actividad editada) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    int idx = _allActividades.indexWhere((a) => a.id == editada.id);
    if (idx != -1) {
      _allActividades[idx] = editada;
      _applyFilters();
    }
    _loading = false;
    notifyListeners();
  }

  // Eliminar
  Future<void> eliminarActividad(int id) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _allActividades.removeWhere((a) => a.id == id);
    _applyFilters();
    _loading = false;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _fechaInicioFiltro = null;
    _fechaFinFiltro = null;
    _ordenCampo = 'fecha';
    _ordenAscendente = true;
    _applyFilters();
    notifyListeners();
  }
}

// Pantalla principal
class ActividadesScreen extends StatefulWidget {
  const ActividadesScreen({Key? key}) : super(key: key);

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  late ActividadesProvider _provider;

  final _formKey = GlobalKey<FormState>();

  // Controladores formulario agregar/editar
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  DateTime? _selectedFecha;
  TimeOfDay? _selectedHora;

  Actividad? _actividadEditando;

  @override
  void initState() {
    super.initState();
    _provider = ActividadesProvider();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _openForm({Actividad? editar}) {
    if (editar != null) {
      _actividadEditando = editar;
      _tituloController.text = editar.titulo;
      _descripcionController.text = editar.descripcion;
      _selectedFecha = editar.fecha;
      _selectedHora = editar.hora;
    } else {
      _actividadEditando = null;
      _tituloController.clear();
      _descripcionController.clear();
      _selectedFecha = null;
      _selectedHora = null;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(editar == null ? 'Agregar Actividad' : 'Editar Actividad'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'El título es obligatorio';
                      }
                      if (v.trim().length < 3) {
                        return 'Debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      if (v.trim().length < 5) {
                        return 'Debe tener al menos 5 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(_selectedFecha == null
                        ? 'Seleccionar fecha'
                        : DateFormat('dd/MM/yyyy').format(_selectedFecha!)),
                    trailing: TextButton(
                      child: const Text('Elegir'),
                      onPressed: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: _selectedFecha ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (fecha != null) {
                          setState(() {
                            _selectedFecha = fecha;
                          });
                        }
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text(_selectedHora == null
                        ? 'Seleccionar hora'
                        : _selectedHora!.format(context)),
                    trailing: TextButton(
                      child: const Text('Elegir'),
                      onPressed: () async {
                        final hora = await showTimePicker(
                          context: context,
                          initialTime: _selectedHora ?? TimeOfDay.now(),
                        );
                        if (hora != null) {
                          setState(() {
                            _selectedHora = hora;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _guardarActividad,
              child: Text(editar == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _guardarActividad() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFecha == null) {
      _showSnackBar('Debes seleccionar una fecha');
      return;
    }
    if (_selectedHora == null) {
      _showSnackBar('Debes seleccionar una hora');
      return;
    }

    final nueva = Actividad(
      id: _actividadEditando?.id ?? 0,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fecha: _selectedFecha!,
      hora: _selectedHora!,
    );

    Navigator.of(context).pop();

    if (_actividadEditando == null) {
      await _provider.agregarActividad(nueva);
      _showSnackBar('Actividad agregada');
    } else {
      await _provider.editarActividad(nueva);
      _showSnackBar('Actividad editada');
    }
    setState(() {});
  }

  void _confirmarEliminar(Actividad actividad) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            Text('¿Seguro que deseas eliminar la actividad "${actividad.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _provider.eliminarActividad(actividad.id);
              setState(() {});
              _showSnackBar('Actividad eliminada');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  final TextEditingController _searchController = TextEditingController();

  // Para filtrar fechas en la pantalla
  Future<void> _seleccionarFiltroFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _provider.fechaInicioFiltro ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      _provider.setFechaInicioFiltro(fecha);
    }
  }

  Future<void> _seleccionarFiltroFechaFin() async {
    final fecha = await showDatePicker(
            context: context,
      initialDate: _provider.fechaFinFiltro ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      _provider.setFechaFinFiltro(fecha);
    }
  }

  void _limpiarFiltros() {
    _searchController.clear();
    _provider.clearFilters();
    setState(() {});
  }

  void _mostrarOpcionesOrden() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Ordenar por Fecha'),
                trailing: _provider.ordenCampo == 'fecha'
                    ? Icon(_provider.ordenAscendente
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                    : null,
                onTap: () {
                  _provider.setOrden('fecha');
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('Ordenar por Título'),
                trailing: _provider.ordenCampo == 'titulo'
                    ? Icon(_provider.ordenAscendente
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                    : null,
                onTap: () {
                  _provider.setOrden('titulo');
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
@override
Widget build(BuildContext context) {
  final themeData = _provider.darkTheme
      ? ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          cardColor: const Color(0xFF2C2C2C),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF2C2C2C),
          ),
        )
      : ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.transparent, // Cambiado a transparente
          cardColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
          ),
        );

  return AnimatedBuilder(
    animation: _provider,
    builder: (context, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: Scaffold(
          body: Container( // Nuevo Container para el fondo
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  title: const Text('Actividades'),
                  actions: [
                    IconButton(
                      tooltip: 'Cambiar tema',
                      icon: Icon(
                        _provider.darkTheme ? Icons.wb_sunny : Icons.nights_stay,
                      ),
                      onPressed: _provider.toggleTheme,
                    ),
                    IconButton(
                      tooltip: 'Filtros',
                      icon: const Icon(Icons.filter_list),
                      onPressed: _mostrarFiltros,
                    ),
                    IconButton(
                      tooltip: 'Ordenar',
                      icon: const Icon(Icons.sort),
                      onPressed: _mostrarOpcionesOrden,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar actividades...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _provider.setSearchQuery('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: (v) => _provider.setSearchQuery(v),
                  ),
                ),
                Expanded(
                  child: _provider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : _provider.error
                          ? Center(
                              child: Text(
                                _provider.errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : _provider.actividades.isEmpty
                              ? const Center(
                                  child: Text('No hay actividades.'),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    await _provider._loadInitialData();
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    itemCount: _provider.actividades.length,
                                    itemBuilder: (context, index) {
                                      final act = _provider.actividades[index];
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(12),
                                          title: Text(
                                            act.titulo,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            '${DateFormat('dd/MM/yyyy').format(act.fecha)} - ${act.hora.format(context)}\n${act.descripcion}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          isThreeLine: true,
                                          trailing: PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'editar') {
                                                _openForm(editar: act);
                                              } else if (value == 'eliminar') {
                                                _confirmarEliminar(act);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'editar',
                                                child: Text('Editar'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'eliminar',
                                                child: Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Nueva Actividad'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    },
  );
}


  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtros de fecha',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(_provider.fechaInicioFiltro == null
                              ? 'Fecha inicio'
                              : DateFormat('dd/MM/yyyy')
                                  .format(_provider.fechaInicioFiltro!)),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate:
                                    _provider.fechaInicioFiltro ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (fecha != null) {
                                setModalState(() {
                                  _provider.setFechaInicioFiltro(fecha);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(_provider.fechaFinFiltro == null
                              ? 'Fecha fin'
                              : DateFormat('dd/MM/yyyy')
                                  .format(_provider.fechaFinFiltro!)),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate:
                                    _provider.fechaFinFiltro ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (fecha != null) {
                                setModalState(() {
                                  _provider.setFechaFinFiltro(fecha);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar filtros'),
                    onPressed: () {
                      setModalState(() {
                        _provider.clearFilters();
                        _searchController.clear();
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

import 'package:flutter/material.dart';

// Clase Aula para almacenar los datos de cada aula
class Aula {
  String nombre;
  String capacidad;
  String foto;
  bool favorito;

  Aula({required this.nombre, required this.capacidad, required this.foto, this.favorito = false});
}

class FavoritosAulasPage extends StatelessWidget {
  final List<Aula> aulas; // Lista de aulas

  const FavoritosAulasPage({Key? key, required this.aulas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrar aulas que son favoritas
    List<Aula> favoritos = aulas.where((aula) => aula.favorito).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aulas Favoritas'),
        backgroundColor: Colors.blue[800],
      ),
      body: favoritos.isEmpty
          ? const Center(
              child: Text(
                'No tienes aulas favoritas aún.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Container(
              color: Colors.white, // Fondo blanco
              child: ListView.builder(
                itemCount: favoritos.length,
                itemBuilder: (context, index) {
                  final aula = favoritos[index];
                  return GestureDetector(
                    onTap: () => _showAulaDetails(context, aula),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(aula.foto, height: 50, width: 50, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aula.nombre,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Capacidad: ${aula.capacidad}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Función para mostrar los detalles de un aula
  void _showAulaDetails(BuildContext context, Aula aula) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aula.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(aula.foto, height: 100),
            const SizedBox(height: 10),
            Text('Capacidad: ${aula.capacidad}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))
        ],
      ),
    );
  }
}

class AulasScreen extends StatefulWidget {
  const AulasScreen({Key? key}) : super(key: key);

  @override
  _AulasScreenState createState() => _AulasScreenState();
}

class _AulasScreenState extends State<AulasScreen> {
  List<Color> backgroundColors = [Colors.white]; // Inicializado con fondo blanco
  List<Aula> aulas = [
    Aula(nombre: 'Aula 101', capacidad: '30', foto: 'assets/images/curso2.png'),
    Aula(nombre: 'Aula 102', capacidad: '25', foto: 'assets/images/curso2.png'),
    Aula(nombre: 'Laboratorio A', capacidad: '20', foto: 'assets/images/curso2.png'),
    Aula(nombre: 'Aula Magna', capacidad: '100', foto: 'assets/images/curso2.png'),
    Aula(nombre: 'Aula Virtual', capacidad: '50', foto: 'assets/images/curso2.png'),
  ];

  String searchQuery = '';
  bool sortByName = true;
  int? editingIndex;

  TextEditingController nombreController = TextEditingController();
  TextEditingController capacidadController = TextEditingController();

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seleccionar Color de Fondo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGradientOption("Blanco", [Colors.white]),
                _buildGradientOption("Gris Claro", [Colors.grey.shade200]),
                _buildGradientOption("Beige", [Colors.amber.shade100]),
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
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: colors[0], // Usar el primer color para el fondo
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(title, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  void _showAddAulaDialog() {
    nombreController.text = '';
    capacidadController.text = '';
    editingIndex = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nueva Aula'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Aula'),
              ),
              TextField(
                controller: capacidadController,
                decoration: const InputDecoration(labelText: 'Capacidad'),
                keyboardType: TextInputType.number, // Asegura que solo se ingresen números
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Agregar'),
              onPressed: () {
                if (nombreController.text.isNotEmpty && capacidadController.text.isNotEmpty) {
                  setState(() {
                    aulas.add(Aula(
                      nombre: nombreController.text,
                      capacidad: capacidadController.text,
                      foto: 'assets/images/aula1.png', // Puedes cambiar esto
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditAulaDialog(int index) {
    nombreController.text = aulas[index].nombre;
    capacidadController.text = aulas[index].capacidad;
    editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Aula'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Aula'),
              ),
              TextField(
                controller: capacidadController,
                decoration: const InputDecoration(labelText: 'Capacidad'),
                keyboardType: TextInputType.number, // Asegura que solo se ingresen números
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (nombreController.text.isNotEmpty && capacidadController.text.isNotEmpty) {
                  setState(() {
                    aulas[index].nombre = nombreController.text;
                    aulas[index].capacidad = capacidadController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAula(int index) {
    setState(() {
      aulas.removeAt(index);
    });
  }

  void _toggleFavorito(Aula aula) {
    setState(() {
      aula.favorito = !aula.favorito;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Aula> filteredAulas = aulas.where((a) {
      return a.nombre.toLowerCase().contains(searchQuery.toLowerCase()) ||
             a.capacidad.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filteredAulas.sort((a, b) => sortByName
        ? a.nombre.compareTo(b.nombre)
        : a.capacidad.compareTo(b.capacidad));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏫 Aulas 👨‍🏫', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritosAulasPage(aulas: aulas),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddAulaDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort_by_alpha, color: Colors.white),
            onPressed: () {
              setState(() {
                sortByName = !sortByName;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.white), // Cambiado a icono de color
            onPressed: _showColorDialog,
          ),
        ],
      ),
      body: Container(
        color: backgroundColors[0], // Fondo blanco
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120.0,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner7.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '🏫 Lista de Aulas 🏫',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar aula o capacidad...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredAulas.length,
                  itemBuilder: (context, index) {
                    final aula = filteredAulas[index];
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmar"),
                                content: const Text("¿Estás seguro de que quieres eliminar esta aula?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteAula(index);
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          _showEditAulaDialog(index);
                          return false;
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${aula.nombre} eliminada')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Editar ${aula.nombre}')));
                        }
                      },
                      child: GestureDetector(
                        onTap: () => _showAulaDetails(context, aula),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(aula.foto, height: 50, width: 50, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      aula.nombre,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Capacidad: ${aula.capacidad}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  aula.favorito ? Icons.favorite : Icons.favorite_border,
                                  color: aula.favorito ? Colors.red : Colors.white,
                                ),
                                onPressed: () => _toggleFavorito(aula),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAulaDetails(BuildContext context, Aula aula) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aula.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(aula.foto, height: 100),
            const SizedBox(height: 10),
            Text('Capacidad: ${aula.capacidad}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    capacidadController.dispose();
    super.dispose();
  }
}
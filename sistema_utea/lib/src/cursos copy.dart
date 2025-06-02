import 'package:flutter/material.dart';

// Clase Curso para almacenar los datos de cada curso
class Curso {
  String nombre;
  String descripcion;
  String foto;
  bool favorito;

  Curso({required this.nombre, required this.descripcion, required this.foto, this.favorito = false});
}

class FavoritosCursosPage extends StatelessWidget {
  final List<Curso> cursos; // Lista de cursos

  const FavoritosCursosPage({Key? key, required this.cursos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrar cursos que son favoritos
    List<Curso> favoritos = cursos.where((curso) => curso.favorito).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos Favoritos'),
        backgroundColor: Colors.blue[800],
      ),
      body: favoritos.isEmpty
          ? const Center(
              child: Text(
                'No tienes cursos favoritos aún.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Container(
              color: Colors.white, // Fondo blanco
              child: ListView.builder(
                itemCount: favoritos.length,
                itemBuilder: (context, index) {
                  final curso = favoritos[index];
                  return GestureDetector(
                    onTap: () => _showCursoDetails(context, curso),
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
                            child: Image.asset(curso.foto, height: 50, width: 50, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  curso.nombre,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  curso.descripcion,
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

  // Función para mostrar los detalles de un curso
  void _showCursoDetails(BuildContext context, Curso curso) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(curso.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(curso.foto, height: 100),
            const SizedBox(height: 10),
            Text('Descripción: ${curso.descripcion}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))
        ],
      ),
    );
  }
}

class CursosScreen extends StatefulWidget {
  const CursosScreen({Key? key}) : super(key: key);

  @override
  _CursosScreenState createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  List<Color> backgroundColors = [Colors.white]; // Inicializado con fondo blanco
  List<Curso> cursos = [
    Curso(nombre: 'Matemáticas I', descripcion: 'Curso básico de matemáticas', foto: 'assets/images/cursos1.png'),
    Curso(nombre: 'Programación I', descripcion: 'Introducción a la programación', foto: 'assets/images/cursos1.png'),
    Curso(nombre: 'Inglés I', descripcion: 'Curso básico de inglés', foto: 'assets/images/cursos1.png'),
    Curso(nombre: 'Física I', descripcion: 'Curso básico de física', foto: 'assets/images/cursos1.png'),
    Curso(nombre: 'Química I', descripcion: 'Curso básico de química', foto: 'assets/images/cursos1.png'),
  ];

  String searchQuery = '';
  bool sortByName = true;
  int? editingIndex;

  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();

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

  void _showAddCursoDialog() {
    nombreController.text = '';
    descripcionController.text = '';
    editingIndex = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Curso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Curso'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
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
                if (nombreController.text.isNotEmpty && descripcionController.text.isNotEmpty) {
                  setState(() {
                    cursos.add(Curso(
                      nombre: nombreController.text,
                      descripcion: descripcionController.text,
                      foto: 'assets/images/docente1.png', // Puedes cambiar esto
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

  void _showEditCursoDialog(int index) {
    nombreController.text = cursos[index].nombre;
    descripcionController.text = cursos[index].descripcion;
    editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Curso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Curso'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
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
                if (nombreController.text.isNotEmpty && descripcionController.text.isNotEmpty) {
                  setState(() {
                    cursos[index].nombre = nombreController.text;
                    cursos[index].descripcion = descripcionController.text;
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

  void _deleteCurso(int index) {
    setState(() {
      cursos.removeAt(index);
    });
  }

  void _toggleFavorito(Curso curso) {
    setState(() {
      curso.favorito = !curso.favorito;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Curso> filteredCursos = cursos.where((c) {
      return c.nombre.toLowerCase().contains(searchQuery.toLowerCase()) ||
             c.descripcion.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filteredCursos.sort((a, b) => sortByName
        ? a.nombre.compareTo(b.nombre)
        : a.descripcion.compareTo(b.descripcion));

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Cursos 👨‍🏫', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritosCursosPage(cursos: cursos),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddCursoDialog,
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
                    image: AssetImage('assets/images/banner11.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '📚 Lista de Cursos 📚',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar curso o descripción...',
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
                  itemCount: filteredCursos.length,
                  itemBuilder: (context, index) {
                    final curso = filteredCursos[index];
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
                                content: const Text("¿Estás seguro de que quieres eliminar este curso?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteCurso(index);
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          _showEditCursoDialog(index);
                          return false;
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${curso.nombre} eliminado')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Editar ${curso.nombre}')));
                        }
                      },
                      child: GestureDetector(
                        onTap: () => _showCursoDetails(context, curso),
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
                                child: Image.asset(curso.foto, height: 50, width: 50, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      curso.nombre,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      curso.descripcion,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  curso.favorito ? Icons.favorite : Icons.favorite_border,
                                  color: curso.favorito ? Colors.red : Colors.white,
                                ),
                                onPressed: () => _toggleFavorito(curso),
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

  void _showCursoDetails(BuildContext context, Curso curso) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(curso.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(curso.foto, height: 100),
            const SizedBox(height: 10),
            Text('Descripción: ${curso.descripcion}'),
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
    descripcionController.dispose();
    super.dispose();
  }
}
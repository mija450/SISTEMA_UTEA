import 'package:flutter/material.dart';
import 'agregar_tarea.dart';
import 'eliminar_tarea.dart';
import 'editar_tarea.dart'; // Asegúrate de importar la pantalla de editar tarea

class ConfiguracionesTareasScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ConfiguracionesTareasScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _ConfiguracionesTareasScreenState createState() =>
      _ConfiguracionesTareasScreenState();
}

class _ConfiguracionesTareasScreenState extends State<ConfiguracionesTareasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones de Tareas"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Estilo de color consistente
      ),
      body: Container(
        color: Colors.grey[200], // Fondo gris claro
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📚 Gestión de Tareas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Administra tus tareas de manera eficiente. Selecciona una de las opciones a continuación:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              _buildActionButton(
                context,
                icon: Icons.add,
                label: "Agregar Tarea",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarTareaScreen(),
                    ),
                  ).then((result) {
                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tarea agregada con éxito")),
                      );
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.delete,
                label: "Eliminar Tarea",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EliminarTareaScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                icon: Icons.edit,
                label: "Editar Tarea",
                onPressed: () {
                  _navigateToEditTasks();
                },
              ),
              const SizedBox(height: 30),
              const Divider(), // Línea divisoria
              const SizedBox(height: 20),
              const Text(
                '💡 Nota para Docentes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text(
                  'Recuerda revisar las tareas asignadas y su progreso.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Método para navegar a la pantalla de editar tareas
  void _navigateToEditTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditarTareaScreen(), // Solo navega a la pantalla de editar tareas
      ),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tarea editada con éxito")),
        );
      }
    });
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.blue), // Color del icono consistente
        title: Text(label, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onPressed,
      ),
    );
  }
}
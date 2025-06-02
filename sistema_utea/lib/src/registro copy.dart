import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // Datos de registro
  String _rol = "";
  String _nombre = "";
  String _correo = "";
  String _codigo = "";

  // Control de pasos y estado de registro
  int _currentStep = 0;
  final _stepperKey = GlobalKey<FormState>();
  bool _isRegistering = false;

  // Controladores para campos de texto
  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController codigoController = TextEditingController();

  // Gradientes de fondo (personalizados)
  List<List<Color>> gradients = [
    [Color(0xFF005EB8), Color(0xFFFFC107)], // Azul fuerte y dorado
    [Colors.purpleAccent, Colors.tealAccent],
    [Colors.orange, Colors.pink],
    [Colors.indigo, Colors.greenAccent],
  ];
  int gradientIndex = 0;

  // Cambia el fondo
  void _changeGradient() {
    setState(() {
      gradientIndex = (gradientIndex + 1) % gradients.length;
    });
  }

  // Avanzar un paso
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Retroceder un paso
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Función para registrar usuario
  Future<void> _registrar() async {
    if (_isRegistering) return;
    // Confirmación antes de enviar
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmación"),
        content: const Text("¿Estás seguro de que deseas guardar este registro?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Aceptar")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isRegistering = true;
    });

    // Asegúrate de usar HTTPS en producción (ajusta la URL según tu entorno)
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/registro.php");

    try {
      final response = await http.post(url, body: {
        'rol': _rol,
        'nombre': _nombre,
        'correo': _correo,
        'codigo': _codigo,
      });

      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Registro exitoso"))
        );
        // Redirige o cierra la pantalla (por ejemplo, vuelve atrás)
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error al registrar"))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Color(0xFF005EB8), // Azul fuerte
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Cambiar Fondo",
            onPressed: _changeGradient,
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradients[gradientIndex],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Registro de Usuarios",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _stepperKey,
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    // Al último paso se llama al registro
                    if (_currentStep == 3) {
                      if (_validateStep(_currentStep)) _registrar();
                    } else {
                      if (_validateStep(_currentStep)) _nextStep();
                    }
                  },
                  onStepCancel: _previousStep,
                  controlsBuilder: (context, details) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text("Atrás", style: TextStyle(color: Colors.white)),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isRegistering ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            backgroundColor: Color(0xFFFFC107), // Amarillo dorado
                            side: const BorderSide(color: Color(0xFF005EB8)), // Azul fuerte
                          ),
                          child: _isRegistering
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _currentStep == 3 ? "Finalizar" : "Continuar",
                                  style: const TextStyle(color: Color(0xFF005EB8)),
                                ),
                        ),
                      ],
                    );
                  },
                  steps: _buildSteps(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validación por paso, mostrando SnackBar en caso de error
  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_rol.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Seleccione Docente o Alumno")));
          return false;
        }
        return true;
      case 1:
        if (nombreController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Ingrese su nombre")));
          return false;
        }
        _nombre = nombreController.text.trim();
        return true;
      case 2:
        if (correoController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Ingrese su correo")));
          return false;
        }
        // Valida correos de Gmail o Hotmail
        if (!RegExp(r'^[\w-\.]+@(gmail\.com|hotmail\.com)$')
            .hasMatch(correoController.text.trim())) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Correo no válido (solo Gmail o Hotmail)")));
          return false;
        }
        _correo = correoController.text.trim();
        return true;
      case 3:
        if (codigoController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Ingrese su código")));
          return false;
        }
        // Ejemplo de validación adicional para el código (mínimo 6 caracteres)
        if (codigoController.text.trim().length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("El código debe tener al menos 6 caracteres")));
          return false;
        }
        _codigo = codigoController.text.trim();
        return true;
      default:
        return true;
    }
  }

  // Construcción de los pasos del Stepper
  List<Step> _buildSteps() {
    return [
      Step(
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Text("Rol", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: _stepRol(),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Row(
          children: [
            Icon(Icons.text_fields, color: Colors.white),
            SizedBox(width: 8),
            Text("Nombre", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: _stepNombre(),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.white),
            SizedBox(width: 8),
            Text("Correo", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: _stepCorreo(),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.white),
            SizedBox(width: 8),
            Text("Código", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: _stepCodigo(),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  // Widget para seleccionar rol
  Widget _stepRol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Selecciona tu Rol",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        RadioListTile<String>(
          title: const Text("Docente", style: TextStyle(color: Colors.white)),
          value: "docente",
          groupValue: _rol,
          onChanged: (value) => setState(() => _rol = value!),
        ),
        RadioListTile<String>(
          title: const Text("Alumno", style: TextStyle(color: Colors.white)),
          value: "alumno",
          groupValue: _rol,
          onChanged: (value) => setState(() => _rol = value!),
        ),
      ],
    );
  }

  // Widgets para los demás pasos utilizando un helper para los TextFormField
  Widget _stepNombre() =>
      _buildInputField(nombreController, "Nombre completo", "Ingresa tu Nombre");
  Widget _stepCorreo() => _buildInputField(
      correoController, "Correo Electrónico", "Ingresa tu Correo",
      keyboardType: TextInputType.emailAddress);
  Widget _stepCodigo() => _buildInputField(
      codigoController, "Código (contraseña)", "Crea tu Código",
      obscureText: true);

  // Función que construye un TextFormField con estilo personalizado
  Widget _buildInputField(TextEditingController controller, String label, String hint,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}

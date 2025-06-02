import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Asegúrate de tener tu clase _BubblePainter definida y tu lista bubbles y controller.

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> with SingleTickerProviderStateMixin {
  // Datos y estados (igual que antes)
  String _rol = "";
  String _nombre = "";
  String _correo = "";
  String _codigo = "";
  int _currentStep = 0;
  final _stepperKey = GlobalKey<FormState>();
  bool _isRegistering = false;

  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController codigoController = TextEditingController();

  // Variables para animación de burbujas
  late AnimationController _controller;
  // Aquí tu lista de burbujas
  List<dynamic> bubbles = []; // Ajusta según tu implementación

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Inicializa tu lista bubbles aquí si es necesario
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    codigoController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Color(0xFF1B2A49), // Azul oscuro para el AppBar que combine
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Cambiar Fondo",
            onPressed: () {
              // Aquí puedes poner alguna acción o quitar este botón si no usas _changeGradient
            },
          ),
        ],
      ),
      body: CustomPaint(
        painter: _BubblePainter(bubbles, _controller.value),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B2A49), Color(0xFF244D6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Registro de Usuarios",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Form(
                  key: _stepperKey,
                  child: Stepper(
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepContinue: () {
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
    backgroundColor: const Color(0xFF00e676),       // Fondo amarillo dorado
    side: const BorderSide(color: Color(0xFF1B2A49)), // Borde azul oscuro
    shadowColor: Colors.greenAccent.shade200,         // Sombra verde
    elevation: 8,                                      // Elevación para que la sombra sea visible
  ),
  child: _isRegistering
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text(
          _currentStep == 3 ? "Finalizar" : "Continuar",
          style: const TextStyle(color: Color(0xFF1B2A49)),
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
      ),
    );
  }

  // Métodos _nextStep, _previousStep, _registrar, _validateStep y _buildSteps aquí (igual que tu código original)
  // ...

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _registrar() async {
    if (_isRegistering) return;

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
          const SnackBar(content: Text("✅ Registro exitoso")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error al registrar")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ingrese su nombre")));
          return false;
        }
        _nombre = nombreController.text.trim();
        return true;
      case 2:
        if (correoController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ingrese su correo")));
          return false;
        }
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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ingrese su código")));
          return false;
        }
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
            Icon(Icons.code, color: Colors.white),
            SizedBox(width: 8),
            Text("Código", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: _stepCodigo(),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  Widget _stepRol() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text("Docente", style: TextStyle(color: Colors.white)),
          value: "docente",
          groupValue: _rol,
          onChanged: (value) {
            setState(() {
              _rol = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text("Alumno", style: TextStyle(color: Colors.white)),
          value: "alumno",
          groupValue: _rol,
          onChanged: (value) {
            setState(() {
              _rol = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _stepNombre() {
    return TextFormField(
      controller: nombreController,
      decoration: const InputDecoration(
        labelText: "Nombre completo",
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _stepCorreo() {
    return TextFormField(
      controller: correoController,
      decoration: const InputDecoration(
        labelText: "Correo electrónico",
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _stepCodigo() {
    return TextFormField(
      controller: codigoController,
      decoration: const InputDecoration(
        labelText: "Código",
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
    );
  }
}

// Debes definir tu _BubblePainter aquí, por ejemplo:
class _BubblePainter extends CustomPainter {
  final List<dynamic> bubbles;
  final double animationValue;

  _BubblePainter(this.bubbles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);
    // Aquí pintas las burbujas según bubbles y animationValue
    // Ejemplo simple:
    for (var bubble in bubbles) {
      // Asumamos bubble tiene posición y radio
      // canvas.drawCircle(bubble.position, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

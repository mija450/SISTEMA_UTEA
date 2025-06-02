import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'registro.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _animation;

  // Colores de fondo adaptados a la universidad
  List<Color> backgroundColors = [Color(0xFF005EB8), Color(0xFFFFC107)]; // Azul fuerte y dorado
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog(); // Mostrar el diálogo de confirmación
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Inicio de Sesión"),
          content: Text("¿Estás seguro de que deseas iniciar sesión con estas credenciales?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _performLogin(); // Realizar el inicio de sesión
              },
              child: Text("Iniciar Sesión"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogin() async {
    setState(() => _isLoading = true);
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/login.php");

    try {
      final response = await http.post(url, body: {
        'correo': email,
        'codigo': password,
      });

      final data = json.decode(response.body);
      _handleLoginResponse(data);
    } catch (e) {
      _showErrorSnackbar("Error de conexión. Intenta más tarde.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleLoginResponse(Map<String, dynamic> data) {
    if (data['success'] == true) {
      final String userRole = data['data']['rol'] ?? '';
      final String userName = data['data']['nombre'] ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(role: userRole, name: userName),
        ),
      );
    } else {
      _showErrorSnackbar(data['message'] ?? "Error en el inicio de sesión");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLogo(),
                        SizedBox(height: 20),
                        _buildAppTitle(),
                        SizedBox(height: 30),
                        _buildTextField(emailController, "Correo Electrónico", Icons.email),
                        SizedBox(height: 15),
                        _buildTextField(passwordController, "Password (Código)", Icons.lock,
                          obscureText: _obscurePassword, toggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        }),
                        SizedBox(height: 20),
                        _buildLoginButton(),
                        SizedBox(height: 20),
                        _buildRegistrationPrompt(),
                        SizedBox(height: 30),
                        Divider(color: const Color.fromARGB(60, 255, 255, 255)),
                        SizedBox(height: 10),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      child: Hero(
        tag: "logoHero",
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 25,
                spreadRadius: 2,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Icon(Icons.school, size: 100, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return ScaleTransition(
      scale: _animation,
      child: Text(
        "UTEA GO!",
        style: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 20,
              color: Colors.white.withOpacity(0.8),
              offset: Offset(0, 0),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: const Color.fromARGB(60, 255, 255, 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa $label';
        }
        if (label.contains("Correo") && !value.contains("@")) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: (_isLoading ||
              emailController.text.isEmpty ||
              passwordController.text.isEmpty)
          ? null
          : _login,
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Ingresar", style: TextStyle(fontSize: 18, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        backgroundColor: const Color.fromARGB(255, 35, 201, 137), // Azul fuerte
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
    );
  }

  Widget _buildRegistrationPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("¿No tienes una cuenta?", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistroScreen()),
            );
          },
          child: Text(
            "Registrarse",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFFC107)), // Amarillo dorado
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      "© 2025 EducaPeru. Todos los derechos reservados.",
      style: TextStyle(color: Colors.white60, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }
}
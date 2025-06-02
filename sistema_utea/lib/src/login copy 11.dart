import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'registro.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'animated_bubble_background.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog();
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogin();
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
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailRecoveryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Recuperar Contraseña"),
          content: TextFormField(
            controller: emailRecoveryController,
            decoration: InputDecoration(
              labelText: "Correo Electrónico",
              icon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Enviar"),
              onPressed: () async {
                Navigator.pop(context);
                final email = emailRecoveryController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  _showErrorSnackbar("Ingresa un correo válido.");
                  return;
                }
                await _sendRecoveryEmail(email);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendRecoveryEmail(String email) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/recuperar_contraseña.php");
    try {
      final response = await http.post(url, body: {'correo': email});
      final data = json.decode(response.body);
      _showErrorSnackbar(data['message'] ?? "Revisa tu bandeja de entrada.");
    } catch (e) {
      _showErrorSnackbar("Error al enviar el correo. Inténtalo de nuevo.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _AnimatedBubbleBackground(),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(),
                        SizedBox(height: 20),
                        _buildAppTitle(),
                        SizedBox(height: 30),
                        _buildTextField(emailController, "Correo Electrónico", Icons.email),
                        SizedBox(height: 15),
                        _buildTextField(passwordController, "Contraseña", Icons.lock,
                            obscureText: _obscurePassword,
                            toggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            }),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildLoginButton(),
                        SizedBox(height: 25),
                        _buildMotivationalText(),
                        SizedBox(height: 30),
                        _buildRegistrationPrompt(),
                        SizedBox(height: 20),
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

  Widget _buildLogo() {
    return Column(
      children: [
        Text(
          "UTEA GO!",
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 6,
                offset: Offset(2, 2),
              )
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Universidad Tecnológica de los Andes",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAppTitle() {
    return Text(
      "",
      style: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 8,
            color: Colors.black54,
            offset: Offset(0, 3),
          ),
        ],
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
        fillColor: Colors.white.withOpacity(0.15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.greenAccent.shade400, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa $label';
        }
        if (label == "Correo Electrónico" && !value.contains('@')) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 6,
          shadowColor: Colors.greenAccent.shade200,
        ),
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Text(
                "Iniciar Sesión",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildMotivationalText() {
    return Text(
      "¡Aprende y crece con UTEA GO!",
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.85),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿No tienes cuenta? ",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => RegistroScreen()));
          },
          child: Text(
            "Regístrate",
            style: TextStyle(
              color: Colors.greenAccent.shade400,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      "© 2025 UTEA - Todos los derechos reservados",
      style: TextStyle(color: Colors.white38, fontSize: 12),
    );
  }
}

class _AnimatedBubbleBackground extends StatefulWidget {
  @override
  __AnimatedBubbleBackgroundState createState() => __AnimatedBubbleBackgroundState();
}

class __AnimatedBubbleBackgroundState extends State<_AnimatedBubbleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;
  final int numberOfBubbles = 40;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    _bubbles = List.generate(numberOfBubbles, (index) => Bubble(random));

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 20))
      ..addListener(() {
        _updateBubbles();
      })
      ..repeat();
  }

  void _updateBubbles() {
    for (var bubble in _bubbles) {
      bubble.update();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00121A),  // Azul muy oscuro
            Color(0xFF000000),  // Negro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(
        painter: BubblePainter(_bubbles),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}


class Bubble {
  late Offset position;
  late double radius;
  late double speed;
  late Color color;
  late double opacity;
  late Random random;

  Bubble(this.random) {
    reset();
  }

  void reset() {
    position = Offset(random.nextDouble() * 1200, random.nextDouble() * 800);
    radius = random.nextDouble() * 25 + 5;
    speed = random.nextDouble() * 0.5 + 0.1;
    opacity = random.nextDouble() * 0.4 + 0.15;
    color = Colors.greenAccent.withOpacity(opacity);
  }

  void update() {
    position = Offset(position.dx, position.dy - speed);
    if (position.dy + radius < 0) {
      position = Offset(random.nextDouble() * 1200, 820);
      reset();
    }
  }
}

class BubblePainter extends CustomPainter {
  List<Bubble> bubbles;

  BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (var bubble in bubbles) {
      paint.color = bubble.color;
      canvas.drawCircle(bubble.position, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
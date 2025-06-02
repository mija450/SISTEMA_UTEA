import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'registro.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Confirmar Inicio de Sesión"),
        content: Text("¿Estás seguro de que deseas iniciar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            onPressed: () {
              Navigator.pop(context);
              _performLogin();
            },
            child: Text("Iniciar Sesión"),
          ),
        ],
      ),
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
      _showSnackbar("Error de conexión. Intenta más tarde.");
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
          builder: (_) => HomeScreen(role: userRole, name: userName),
        ),
      );
    } else {
      _showSnackbar(data['message'] ?? "Error en el inicio de sesión");
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailRecoveryController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
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
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final email = emailRecoveryController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                _showSnackbar("Ingresa un correo válido.");
                return;
              }
              await _sendRecoveryEmail(email);
            },
            child: Text("Enviar"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRecoveryEmail(String email) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/recuperar_contraseña.php");
    try {
      final response = await http.post(url, body: {'correo': email});
      final data = json.decode(response.body);
      _showSnackbar(data['message'] ?? "Revisa tu correo.");
    } catch (e) {
      _showSnackbar("Error al enviar el correo.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildLoginCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 10,
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),
              SizedBox(height: 15),
              _buildTitle(),
              SizedBox(height: 25),
              _buildInputField(emailController, "Correo Electrónico", Icons.email),
              SizedBox(height: 20),
              _buildInputField(passwordController, "Contraseña", Icons.lock,
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
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildLoginButton(),
              SizedBox(height: 15),
              _buildRegisterLink(),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              Text("© 2025 EducaPeru", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset("assets/images/logo_utea_go.png", width: 90, height: 90);
  }

  Widget _buildTitle() {
    return Text(
      "UTEA GO!",
      style: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [Colors.teal, Colors.cyan],
          ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo requerido';
        if (label.contains("Correo") && !value.contains("@"))
          return 'Correo inválido';
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text("Ingresar", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("¿No tienes cuenta?", style: TextStyle(fontSize: 14)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegistroScreen()),
            );
          },
          child: Text("Registrarse", style: TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }
}

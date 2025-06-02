import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'login.dart';
import 'home.dart';
import 'comunicacion.dart';
import 'aprendizaje.dart';
import 'tareas.dart';
import 'eventos.dart';
import 'recursos.dart';
import 'perfil.dart';
import 'cof.dart'; // Configuración

void main() {
  runApp(const ColegioApp());
}

class ColegioApp extends StatefulWidget {
  const ColegioApp({super.key});

  @override
  State<ColegioApp> createState() => _ColegioAppState();
}

class _ColegioAppState extends State<ColegioApp> {
  bool _isDarkMode = false;

  // Simulando datos de usuario para navegación
  String userRole = "docente";
  String userName = "Juan Pérez";

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: _isDarkMode ? Colors.white : Colors.black,
        ),
        bodyMedium: TextStyle(
          color: _isDarkMode ? Colors.white70 : Colors.black54,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      iconTheme: IconThemeData(
        color: _isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Comunicación y Aprendizaje 🚀',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(
              name: userName,
              role: userRole,
            ),
        '/comunicacion': (context) => ComunicacionScreen(
              name: userName,
              role: userRole,
            ),
        '/aprendizaje': (context) => AprendizajeScreen(
              name: userName,
              role: userRole,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/tareas': (context) => TareasScreen(
              name: userName,
              role: userRole,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/eventos': (context) => EventosScreen(
              name: userName,
              role: userRole,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/recursos': (context) => RecursosScreen(
              name: userName,
              role: userRole,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/configuracion': (context) => CofScreen(),
        '/perfil': (context) => PerfilScreen(
              name: userName,
              role: userRole,
            ),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
    );
  }
}

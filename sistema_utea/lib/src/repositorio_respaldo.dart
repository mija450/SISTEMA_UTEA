import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArchivoRepositorio {
  final int id;
  final String nombreArchivo;
  final String tipoArchivo;
  final String rutaArchivo;
  final DateTime fechaSubida;
  final String? descripcion;
  final String? categoria;
  final int tamanoArchivo;
  final int? usuarioSubida;
  final String nombreOriginal;

  ArchivoRepositorio({
    required this.id,
    required this.nombreArchivo,
    required this.tipoArchivo,
    required this.rutaArchivo,
    required this.fechaSubida,
    this.descripcion,
    this.categoria,
    required this.tamanoArchivo,
    this.usuarioSubida,
    required this.nombreOriginal,
  });

  factory ArchivoRepositorio.fromJson(Map<String, dynamic> json) {
    return ArchivoRepositorio(
      id: int.parse(json['id'].toString()),
      nombreArchivo: json['nombre_archivo'],
      tipoArchivo: json['tipo_archivo'],
      rutaArchivo: json['ruta_archivo'],
      fechaSubida: DateTime.parse(json['fecha_subida']),
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      tamanoArchivo: int.parse(json['tamano_archivo'].toString()),
      usuarioSubida: json['usuario_subida'] != null ? int.parse(json['usuario_subida'].toString()) : null,
      nombreOriginal: json['nombre_original'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre_archivo': nombreArchivo,
    'tipo_archivo': tipoArchivo,
    'ruta_archivo': rutaArchivo,
    'fecha_subida': fechaSubida.toIso8601String(),
    'descripcion': descripcion,
    'categoria': categoria,
    'tamano_archivo': tamanoArchivo,
    'usuario_subida': usuarioSubida,
    'nombre_original': nombreOriginal,
  };
}

class RepositorioProvider with ChangeNotifier {
  List<ArchivoRepositorio> _archivos = [];

  List<ArchivoRepositorio> get archivos => [..._archivos];

  final String apiUrl = 'http://127.0.0.1/ProyectoColegio/Sistema_Utea/repositorio.php'; // Replace with your actual API URL

  Future<void> fetchArchivos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> archivoData = jsonData['data'];
          _archivos = archivoData.map((archivo) => ArchivoRepositorio.fromJson(archivo)).toList();
          notifyListeners();
        } else {
          print('Failed to load archivos: ${jsonData['message']}');
          _archivos = []; // Clear archivos on failure
          notifyListeners();
        }
      } else {
        print('Failed to load archivos. Status code: ${response.statusCode}');
        _archivos = []; // Clear archivos on failure
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching archivos: $error');
      _archivos = []; // Clear archivos on error
      notifyListeners();
    }
  }

  Future<bool> addArchivo(ArchivoRepositorio archivo) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(archivo.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          fetchArchivos(); // Refresh the archivo list
          return true;
        } else {
          print('Failed to add archivo: ${jsonData['message']}');
          return false;
        }
      } else {
        print('Failed to add archivo. Status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error adding archivo: $error');
      return false;
    }
  }

  Future<bool> updateArchivo(ArchivoRepositorio archivo) async {
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(archivo.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          fetchArchivos(); // Refresh the archivo list
          return true;
        } else {
          print('Failed to update archivo: ${jsonData['message']}');
          return false;
        }
      } else {
        print('Failed to update archivo. Status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error updating archivo: $error');
      return false;
    }
  }

  Future<bool> deleteArchivo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          fetchArchivos(); // Refresh the archivo list
          return true;
        } else {
          print('Failed to delete archivo: ${jsonData['message']}');
          return false;
        }
      } else {
        print('Failed to delete archivo. Status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error deleting archivo: $error');
      return false;
    }
  }
}
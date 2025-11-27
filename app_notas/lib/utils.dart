import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const String baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

  static Future<void> saveUser(String name, String email, String password, String? photoPath) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'photoPath': photoPath,
      }),
    );
    if (response.statusCode != 200) throw Exception('Error al registrar');
  }

  //actualizar usuario
  static Future<void> updateUser(String oldEmail, String name, String email, String password, String photoPath) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/$oldEmail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'photoPath': photoPath,
      }),
    );
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedInEmail', email); // Actualiza email logueado si cambi
    } else {
      throw Exception('Error al actualizar usuario');
    }
  }

  // eliminar usuario
  static Future<void> deleteUser(String email) async {
    final response = await http.delete(Uri.parse('$baseUrl/user/$email'));
    if (response.statusCode != 200) throw Exception('Error al eliminar usuario');
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail');
    if (email != null) {
      final response = await http.get(Uri.parse('$baseUrl/user/$email'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'name': data['name'],
          'email': data['email'],
          'password': data['password'],
          'photoPath': data['photoPath'],
        };
      }
    }
    return {};
  }

  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedInEmail', email);
    } else {
      throw Exception('Credenciales incorrectas');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInEmail');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInEmail') != null;
  }

  // historial movido a api
  static Future<void> addToHistory(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail');
    if (email != null) {
      await http.post(
        Uri.parse('$baseUrl/history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'action': action}),
      );
    }
  }

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail');
    if (email != null) {
      final response = await http.get(Uri.parse('$baseUrl/history/$email'));
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
    }
    return [];
  }

  //obtener email logueado
  static Future<String?> getLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInEmail');
  }
}

class NotesDatabase {
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final email = await UserPrefs.getLoggedInEmail();
    if (email != null) {
      final response = await http.get(Uri.parse('${UserPrefs.baseUrl}/notes/$email'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    }
    return [];
  }

  static Future<void> insertNote(String title, String content) async {
    final email = await UserPrefs.getLoggedInEmail();
    final date = DateTime.now().toIso8601String();
    await http.post(
      Uri.parse('${UserPrefs.baseUrl}/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'content': content, 'date': date, 'userId': email}),
    );
  }

  static Future<void> updateNote(String id, String title, String content) async {
    await http.put(
      Uri.parse('${UserPrefs.baseUrl}/notes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'content': content}),
    );
  }

  static Future<void> deleteNote(String id) async {
    await http.delete(Uri.parse('${UserPrefs.baseUrl}/notes/$id'));
  }
}

class PhotosDatabase {
  static Future<List<Map<String, dynamic>>> getPhotos() async {
    final email = await UserPrefs.getLoggedInEmail();
    if (email != null) {
      final response = await http.get(Uri.parse('${UserPrefs.baseUrl}/photos/$email'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    }
    return [];
  }

  static Future<void> insertPhoto(String pathOrBase64) async {
    final email = await UserPrefs.getLoggedInEmail();
    await http.post(
      Uri.parse('${UserPrefs.baseUrl}/photos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'path': pathOrBase64, 'userId': email}),
    );
  }

  static Future<void> deletePhoto(String id) async {
    await http.delete(Uri.parse('${UserPrefs.baseUrl}/photos/$id'));
  }
}

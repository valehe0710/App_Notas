import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils.dart';
import 'package:flutter/foundation.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String?> _user = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    try {
      final u = await UserPrefs.getUser();
      setState(() => _user = u);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar perfil')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  ImageProvider _imageProvider() {
    final photo = _user['photoPath'];
    if (photo == null || photo.isEmpty) return AssetImage('assets/images/default_profile.png');
    if (photo.startsWith('data:image')) {
      final bytes = base64Decode(photo.split(',').last);
      return MemoryImage(bytes);
    }
    if (!kIsWeb && File(photo).existsSync()) {
      return FileImage(File(photo));
    }
    return AssetImage('assets/images/default_profile.png');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFFFF2E6),
      appBar: AppBar(title: Text('Mi Perfil')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: 360,
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(radius: 60, backgroundImage: _imageProvider()),
                      SizedBox(height: 12),
                      Text(
                        'Nombre: ${_user['name'] ?? 'No disponible'}',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Correo: ${_user['email'] ?? 'No disponible'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/edit_profile').then((_) => _load()), child: Text('Editar información')),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirmar'),
                              content: Text('¿Estas seguro que deseas borrar tu cuenta?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await UserPrefs.deleteUser(_user['email']!);
                                      await UserPrefs.logout();
                                      await UserPrefs.addToHistory('Borro cuenta');
                                      Navigator.pushReplacementNamed(context, '/login');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al borrar cuenta')));
                                    }
                                  },
                                  child: Text('Sí'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Borrar cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  XFile? _picked;
  Uint8List? _pickedBytes;  
  final ImagePicker _picker = ImagePicker();
  Map<String, String?> _user = {}; 

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    _user = await UserPrefs.getUser();
    _nameController.text = _user['name'] ?? '';
    _emailController.text = _user['email'] ?? '';
    _passwordController.text = _user['password'] ?? '';
    setState(() {});
  }

  void _pickImage() async {
    final p = await _picker.pickImage(source: ImageSource.gallery);
    if (p != null) {
      _picked = p;
      if (kIsWeb) {
        _pickedBytes = await p.readAsBytes();
      }
      setState(() {});
    }
  }

  void _save() async {
    String photoPath = _user['photoPath'] ?? 'assets/images/default_profile.png';
  if (_picked != null) {
    if (kIsWeb) {
      final bytes = _pickedBytes ?? await _picked!.readAsBytes();
      photoPath = 'data:image/png;base64,' + base64Encode(bytes);
    } else {
      photoPath = _picked!.path;
    }
  }

  String oldEmail = _user['email'] ?? '';
  await UserPrefs.updateUser(oldEmail, _nameController.text, _emailController.text, _passwordController.text, photoPath);
  await UserPrefs.addToHistory('Edito perfil');
  Navigator.pop(context);
  }

  ImageProvider _imageProviderFor(String? path) {
    if (path == null || path.isEmpty) return AssetImage('assets/images/default_profile.png');
    if (path.startsWith('data:image')) {
      final base64Str = path.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    }
    if (kIsWeb && path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ImageProvider provider;
    if (_picked != null) {
      if (kIsWeb && _pickedBytes != null) {
        provider = MemoryImage(_pickedBytes!);
      } else if (!kIsWeb) {
        provider = FileImage(File(_picked!.path));
      } else {
        provider = _imageProviderFor(_user['photoPath']);  
      }
    } else {
      provider = _imageProviderFor(_user['photoPath']);
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFFFF2E6),
      appBar: AppBar(title: Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 360,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                CircleAvatar(radius: 56, backgroundImage: provider),
                SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                ElevatedButton(onPressed: _pickImage, child: Text('Seleccionar foto')),
                SizedBox(height: 8),
                ElevatedButton(onPressed: _save, child: Text('Guardar cambios')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
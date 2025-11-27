import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils.dart';

bool isValidEmail(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  XFile? _picked;
  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _picked = picked);
  }

  void _register() async {
     if (!_formKey.currentState!.validate()) return;

  String photoPath = 'assets/images/default_profile.png';
  if (_picked != null) {
    photoPath = _picked!.path;  // O convierte a base64 
  }

  try {
    await UserPrefs.saveUser(_nameController.text, _emailController.text, _passwordController.text, photoPath);
    await UserPrefs.login(_emailController.text, _passwordController.text);  // Loguea 
    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar')));
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF2E6),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            width: 360,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Registro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Ingresa nombre' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Correo'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa correo';
                      if (!isValidEmail(v)) return 'Correo no valido';
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Ingresa contraseña' : null,
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(onPressed: _pickImage, child: Text('Seleccionar foto')),
                  if (_picked != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Image.network(_picked!.path, height: 80, errorBuilder: (_, __, ___) {
                        return Text('Imagen seleccionada');
                      }),
                    ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _register,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Text('Registrarme'),
                    ),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

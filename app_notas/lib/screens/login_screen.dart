import 'package:flutter/material.dart';
import '../utils.dart';

bool isValidEmail(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await UserPrefs.login(_emailController.text, _passwordController.text);  //valida contra la api
      await UserPrefs.addToHistory('Inicio sesión');  
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Correo o contraseña incorrectos o no registrado')));
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 80),
                  SizedBox(height: 12),
                  Text('Iniciar Sesión', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Correo'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Ingresa correo';
                      if (!isValidEmail(val)) return 'Correo no valido';
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (val) => (val == null || val.isEmpty) ? 'Ingresa contraseña' : null,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Text('Entrar'),
                    ),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: Text('Crear cuenta')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
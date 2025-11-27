import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  SettingsScreen({required this.toggleTheme}); 

  @override
  _SettingsScreenState createState() => _SettingsScreenState(); 
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _changeTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    prefs.setBool('isDarkMode', value);
    widget.toggleTheme(); // Llama al toggle global
  }

  @override
  Widget build(BuildContext context) {
   final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Scaffold(
    backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFFFF2E6),
    appBar: AppBar(
      title: Text(
        'Ajustes',
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
    ),
    body: ListView(
      children: [
        SwitchListTile(
          title: Text(
            'Modo Oscuro',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          value: _isDarkMode,
          onChanged: _changeTheme,
        ),
      ],
    ),
  );
  }
}
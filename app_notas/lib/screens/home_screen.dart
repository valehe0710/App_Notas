import 'package:flutter/material.dart';
import '../utils.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  HomeScreen({required this.toggleTheme});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final notes = await NotesDatabase.getNotes();
    setState(() => _notes = List<Map<String, dynamic>>.from(notes));
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nueva nota'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Título')),
              TextField(controller: contentController, decoration: InputDecoration(labelText: 'Contenido')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final t = titleController.text.trim();
              final c = contentController.text.trim();
              if (t.isEmpty && c.isEmpty) return;
              await NotesDatabase.insertNote(t, c);
              try {
                await UserPrefs.addToHistory('Creo una nota');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar en historial')));
              }
              Navigator.pop(context);
              _loadNotes();
            },
            child: Text('Guardar'),
          )
        ],
      ),
    );
  }

  void _showEditDialog(String id, String currentTitle, String currentContent) {
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar nota'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Título')),
              TextField(controller: contentController, decoration: InputDecoration(labelText: 'Contenido')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await NotesDatabase.updateNote(id, titleController.text, contentController.text);
                try {
                  await UserPrefs.addToHistory('Edito una nota');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar en historial')));
                }
                Navigator.pop(context);
                _loadNotes();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al editar nota')));
              }
            },
            child: Text('Guardar'),
          )
        ],
      ),
    );
  }

  void _deleteNote(String id) async {
    try {
      await NotesDatabase.deleteNote(id);
      try {
        await UserPrefs.addToHistory('Borro una nota');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar en historial')));
      }
      _loadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al borrar nota')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFFFF2E6),  // Adaptar fondo al modo oscuro
      appBar: AppBar(title: Text('Home')),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(title: Text('Mi Perfil'), onTap: () => Navigator.pushNamed(context, '/profile')),
            ListTile(title: Text('Mis Fotos'), onTap: () => Navigator.pushNamed(context, '/photos')),
            ListTile(title: Text('Historial'), onTap: () => Navigator.pushNamed(context, '/history')),
            ListTile(title: Text('Ajustes'), onTap: () => Navigator.pushNamed(context, '/settings')),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirmar'),
                    content: Text('¿Deseas cerrar sesión?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sí')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await UserPrefs.logout();
                  try {
                    await UserPrefs.addToHistory('Cerro sesión');
                  } catch (e) {}
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: _notes.isEmpty
          ? Center(
              child: Text(
                'No hay notas, agrega una.',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),  
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _notes.length,
              itemBuilder: (context, i) {
                final note = _notes[i];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      note['title'] ?? '',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), 
                    ),
                    subtitle: Text(
                      '${note['content'] ?? ''}\n${note['date'] ?? ''}',
                      style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black54),  
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditDialog(note['id'], note['title'] ?? '', note['content'] ?? '')),
                        IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteNote(note['id'])),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
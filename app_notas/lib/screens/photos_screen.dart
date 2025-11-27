import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils.dart';
import 'package:flutter/foundation.dart';

class PhotosScreen extends StatefulWidget {
  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  List<Map<String, dynamic>> _photos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() async {
    final photos = await PhotosDatabase.getPhotos();
    setState(() => _photos = List<Map<String, dynamic>>.from(photos));
  }

  void _pickAndUploadPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      final base64Str = 'data:image/png;base64,' + base64Encode(bytes);
      await PhotosDatabase.insertPhoto(base64Str);
    } else {
      await PhotosDatabase.insertPhoto(picked.path);
    }

    try {
      await UserPrefs.addToHistory('Subio una foto');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar en historial')));
    }
    _loadPhotos();
  }

  void _deletePhoto(String id) async {
    try {
      await PhotosDatabase.deletePhoto(id);
      try {
        await UserPrefs.addToHistory('Borro una foto');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar en historial')));
      }
      _loadPhotos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al borrar foto')));
    }
  }

  Widget _buildImageFromPath(String path) {
    if (path.startsWith('data:image')) {
      final bytes = base64Decode(path.split(',').last);
      return Image.memory(bytes, fit: BoxFit.cover);
    } else if (!kIsWeb && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover);
    } else {
      return Image.asset('assets/images/default_profile.png', fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFFFF2E6),  
      appBar: AppBar(
        title: Text(
          'Mis Fotos',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),  
        ),
      ),
      body: _photos.isEmpty
          ? Center(
              child: Text(
                'No hay fotos, agrega una.',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),  
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Stack(
                  children: [
                    Positioned.fill(child: _buildImageFromPath(photo['path'])),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePhoto(photo['id']),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadPhoto,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
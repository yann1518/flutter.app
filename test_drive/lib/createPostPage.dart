import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostPage extends StatefulWidget {
  final String token;
  const CreatePostPage({super.key, required this.token});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String content = '';
  String category = '';
  String imageFilename = '';
  String slug = '';
  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  static const String uploadUrl = 'https://std29.beaupeyrat.com/api/upload';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        imageFilename = pickedFile.path.split('/').last;
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(uploadUrl),
    );
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    request.headers['Authorization'] = 'Bearer ${widget.token}';
    var response = await request.send();
    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      var jsonResp = jsonDecode(respStr);
      return jsonResp['filename'];
    } else {
      var respStr = await response.stream.bytesToString();
      print('Erreur upload: \n${response.statusCode} - $respStr');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de l\'upload: \n${response.statusCode} - $respStr')),
      );
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    // Générer le slug à partir du titre
    slug = title.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+'), '')
        .replaceAll(RegExp(r'-+$'), '');
    
    setState(() => isLoading = true);
    try {
      String? finalImageFilename = imageFilename;

      if (_selectedImage != null) {
        final uploaded = await _uploadImage(_selectedImage!);
        if (uploaded == null) {
          setState(() => isLoading = false);
          return;
        }
        finalImageFilename = uploaded;
      }

      final response = await http.post(
        Uri.parse('https://std29.beaupeyrat.com/api/posts'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/ld+json',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category,
          'imageFilename': finalImageFilename,
          'slug': slug,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post créé avec succès')),
        );
        Navigator.pop(context, true);
      } else {
        print(
            'Erreur création post: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur création post: ${response.statusCode}\n${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Titre'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                  onSaved: (value) => title = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contenu'),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                  onSaved: (value) => content = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                  onSaved: (value) => category = value ?? '',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Sélectionner une image'),
                    ),
                    const SizedBox(width: 12),
                    if (_selectedImage != null)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Créer'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// lib/features/text_recognition/text_recognition_page.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/TextRecognition/TextRecognitionService.dart';


class TextRecognitionWidget extends StatefulWidget {
  const TextRecognitionWidget({super.key});

  @override
  State<TextRecognitionWidget> createState() => _TextRecognitionWidgetState();
}

class _TextRecognitionWidgetState extends State<TextRecognitionWidget> {
  final TextRecognitionService _textService = TextRecognitionService();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  String _recognizedText = '';
  bool _isProcessing = false;

  @override
  void dispose() {
    _textService.dispose();
    super.dispose();
  }

  // Choisir une image depuis la galerie
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _recognizedText = '';
        });
        
        await _recognizeText();
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    }
  }

  // Prendre une photo avec la caméra
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _recognizedText = '';
        });
        
        await _recognizeText();
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la capture: $e');
    }
  }

  // Reconnaître le texte de l'image sélectionnée
  Future<void> _recognizeText() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _recognizedText = '';
    });

    try {
      final text = await _textService.recognizeTextFromFile(_selectedImage!);
      
      setState(() {
        _recognizedText = text.isNotEmpty ? text : 'Aucun texte détecté';
      });
    } catch (e) {
      _showErrorSnackBar('Erreur de reconnaissance: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconnaissance de texte'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zone d'affichage de l'image
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sélectionnez une image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Caméra'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Bouton pour ré-analyser
            if (_selectedImage != null)
              Center(
                child: TextButton.icon(
                  onPressed: _recognizeText,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Ré-analyser'),
                ),
              ),

            const SizedBox(height: 20),

            // Zone d'affichage du texte reconnu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.text_fields, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Texte reconnu :',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isProcessing)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Analyse en cours...'),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _recognizedText.isNotEmpty
                            ? _recognizedText
                            : 'Le texte reconnu apparaîtra ici',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informations supplémentaires
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Image: ${_selectedImage != null ? 'Sélectionnée' : 'Aucune'}'),
                    if (_selectedImage != null)
                      Text('Taille: ${_selectedImage!.lengthSync()} bytes'),
                    Text('Statut: ${_isProcessing ? 'En cours' : 'Prêt'}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
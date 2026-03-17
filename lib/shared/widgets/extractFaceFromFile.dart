  
  
  
////////////////supprimer cette page //////////////////////////  
/// Cette page est un widget de test pour extraire le visage d'une image scannée. Elle utilise la caméra pour scanner un document, puis utilise le service de détection de visage pour extraire le visage de l'image scannée.
import 'dart:io';
  import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
  import 'package:pfe_flutter/shared/services/face_detection_service.dart';
  import 'package:pfe_flutter/shared/widgets/document_scanner.dart';

  class ExtractFaceFromFilePage extends StatefulWidget {
    const ExtractFaceFromFilePage({super.key});

    @override
    State<ExtractFaceFromFilePage> createState() => _ExtractFaceFromFilePageState();
  }

  class _ExtractFaceFromFilePageState extends State<ExtractFaceFromFilePage> {
    final FaceDetectionService _faceService = FaceDetectionService();
    File? _selectedImage;
    File? _faceImage;
    bool _isProcessing = false;

    Future<void> _scanDocument() async {
  final cameras = await availableCameras();

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CardScannerPage(
        camera: cameras.first,
        onPictureTaken: (File scannedFile) async {
          setState(() {
            _selectedImage = scannedFile;
            _faceImage = null;
          });

          await _extractFace();
        },
      ),
    ),
  );
}

    Future<void> _extractFace() async {
      if (_selectedImage == null) return;
      setState(() => _isProcessing = true);
      final faceFile = await _faceService.extractFaceFromFile(_selectedImage!);
      setState(() {
        _faceImage = faceFile;
        _isProcessing = false;
      });
      if (faceFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun visage détecté'), backgroundColor: Colors.red),
        );
      }
    }

    @override
    void dispose() {
      _faceService.dispose();
      super.dispose();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extraction du visage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scanner un document'),
              onPressed: _isProcessing ? null : _scanDocument,
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              Column(
                children: [
                  const Text('Image scannée :'),
                  const SizedBox(height: 8),
                  Image.file(_selectedImage!, height: 150),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.face),
                    label: const Text('Extraire le visage'),
                    onPressed: _isProcessing ? null : _extractFace,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator()),
            if (_faceImage != null)
              Column(
                children: [
                  const Text('Visage extrait :'),
                  const SizedBox(height: 8),
                  Image.file(_faceImage!, height: 150),
                ],
              ),
          ],
        ),
      ),
    );
  }
  }
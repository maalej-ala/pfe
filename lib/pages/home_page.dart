
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:pfe_flutter/features/face_detection/camera_service.dart';
import 'package:pfe_flutter/features/face_detection/face_detection_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceService = FaceDetectionService();

  bool _isDetecting = false;
  String _faceDirection = '';

  String? _facePhotoPath;
  String? _gauchePhotoPath;
  String? _droitePhotoPath;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    await _cameraService.initializeCamera(camera);
    _cameraService.startImageStream(_processCameraImage);

    setState(() {});
  }

  void _processCameraImage(InputImage inputImage) async {
  if (_isDetecting) return;
  _isDetecting = true;

  try {
    final faces = await _faceService.getFaces(inputImage);
    if (faces.isNotEmpty) {
      final face = faces.first;
      final faceRect = face.boundingBox;

      // Récupère taille réelle de l'image MLKit
      final imageWidth = inputImage.metadata?.size.width ?? 300;
      final imageHeight = inputImage.metadata?.size.height ?? 400;

      // Calcul du facteur de scale vers le widget preview
      final scaleX = 300 / imageWidth;
      final scaleY = 400 / imageHeight;

      final faceCenterX = faceRect.center.dx * scaleX;
      final faceCenterY = faceRect.center.dy * scaleY;

      final circleCenterX = 300 / 2;
      final circleCenterY = 400 / 2;
      final circleRadius = 150 / 2;

      final distance = sqrt(pow(faceCenterX - circleCenterX, 2) + pow(faceCenterY - circleCenterY, 2));

      if (distance <= circleRadius) {
        final direction = await _faceService.detectFaceDirection(inputImage);

        if (mounted) setState(() => _faceDirection = direction);

        if (direction == 'Front' && _facePhotoPath == null) _capturePhotoForDirection('Front');
        if (direction == 'Gauche' && _gauchePhotoPath == null) _capturePhotoForDirection('Gauche');
        if (direction == 'Droite' && _droitePhotoPath == null) _capturePhotoForDirection('Droite');
      }
    } else {
      if (mounted) setState(() => _faceDirection = 'Aucun visage');
    }
  } catch (e) {
    debugPrint("Erreur MLKit: $e");
  } finally {
    _isDetecting = false;
  }
}

  Future<void> _capturePhotoForDirection(String direction) async {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();

      setState(() {
        if (direction == 'Front') {
          _facePhotoPath = file.path;
        } else if (direction == 'Gauche') {
          _gauchePhotoPath = file.path;
        } else if (direction == 'Droite') {
          _droitePhotoPath = file.path;
        }
      });

      debugPrint('Photo prise pour $direction: ${file.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo prise pour $direction!')),
      );
    } catch (e) {
      debugPrint('Erreur lors de la capture: $e');
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceService.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final controller = _cameraService.controller;

  return Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera + overlay cercle
            controller != null && controller.value.isInitialized
                ? SizedBox(
                    width: 300,
                    height: 400,
                    child: Stack(
                      children: [
                        CameraPreview(controller),
                        // Cercle centré
                        Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.greenAccent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),

            // Direction du visage
            Text(
              'Direction du visage : $_faceDirection',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),

            // Affichage des photos
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                if (_facePhotoPath != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Photo Face'),
                      Image.file(File(_facePhotoPath!), width: 100, height: 100),
                    ],
                  ),
                if (_gauchePhotoPath != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Photo Gauche'),
                      Image.file(File(_gauchePhotoPath!), width: 100, height: 100),
                    ],
                  ),
                if (_droitePhotoPath != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Photo Droite'),
                      Image.file(File(_droitePhotoPath!), width: 100, height: 100),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}
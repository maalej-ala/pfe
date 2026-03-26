import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:pfe_flutter/shared/services/camera_service.dart';
import 'package:pfe_flutter/shared/services/face_detection_service.dart';

import '../models/face_capture_state.dart';

class FaceCaptureViewModel extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceService = FaceDetectionService();

  FaceCaptureState _state = const FaceCaptureState();
  FaceCaptureState get state => _state;

  CameraController? get controller => _cameraService.controller;

  bool _isDetecting = false;
  bool _isCapturing = false;


  Future<void> initialize() async {
    await _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    await _cameraService.initializeCamera(camera);
    _cameraService.startImageStream(_processCameraImage);
    notifyListeners();
  }

  void _processCameraImage(InputImage inputImage) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final faces = await _faceService.getFaces(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final faceRect = face.boundingBox;

        final imageWidth = inputImage.metadata?.size.width ?? 0;
        final imageHeight = inputImage.metadata?.size.height ?? 0;
        const previewWidth = 300.0;
        const previewHeight = 400.0;

        if (imageWidth == 0 || imageHeight == 0) {
          _isDetecting = false;
          return;
        }

        final scaleX = previewWidth / imageWidth;
        final scaleY = previewHeight / imageHeight;

        final faceCenterX = faceRect.center.dx * scaleX;
        final faceCenterY = faceRect.center.dy * scaleY;

        const circleCenterX = previewWidth / 2;
        const circleCenterY = previewHeight / 2;
        const circleRadius = 100.0;

        final distance = sqrt(
          pow(faceCenterX - circleCenterX, 2) +
              pow(faceCenterY - circleCenterY, 2),
        );

        final faceWidth = faceRect.width * scaleX;
        final faceHeight = faceRect.height * scaleY;
        final faceRadius = (faceWidth + faceHeight) / 4;

        final isInCircle = faceWidth > circleRadius * 1.5
            ? distance <= circleRadius * 0.8
            : distance <= circleRadius + faceRadius * 0.5;

        if (isInCircle) {
          final direction = await _faceService.detectFaceDirection(inputImage);

          // Capture automatique
          if (direction == 'Front' && _state.facePhotoPath == null) {
            await _capturePhotoForDirection('Front');
          } else if (direction == 'Gauche' && _state.gauchePhotoPath == null) {
            await _capturePhotoForDirection('Gauche');
          } else if (direction == 'Droite' && _state.droitePhotoPath == null) {
            await _capturePhotoForDirection('Droite');
          }

          _updateState(_state.copyWith(faceDirection: direction));
        } else {
          _updateState(_state.copyWith(faceDirection: 'Positionnez le visage dans le cercle'));
        }
      } else {
        _updateState(_state.copyWith(faceDirection: 'Aucun visage détecté'));
      }
    } catch (e) {
      debugPrint("Erreur MLKit: $e");
      _updateState(_state.copyWith(faceDirection: 'Erreur de détection'));
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _capturePhotoForDirection(String direction) async {
  final ctrl = _cameraService.controller;
  if (ctrl == null || !ctrl.value.isInitialized) return;

  // 🔥 Bloque uniquement si capture en cours
  if (_isCapturing) return;

  _isCapturing = true;

  try {
    await Future.delayed(const Duration(milliseconds: 300));

    final file = await ctrl.takePicture();

    File? extractedFace;

    if (direction == 'Front') {
      extractedFace =
          await _faceService.extractFaceFromFile(File(file.path));
    }

    // 🔥 Remplacement DIRECT (pas de vérification)
    switch (direction) {
      case 'Front':
        _updateState(_state.copyWith(
          facePhotoPath: file.path,
          frontFaceExtracted: extractedFace,
        ));
        break;

      case 'Gauche':
        _updateState(_state.copyWith(
          gauchePhotoPath: file.path,
        ));
        break;

      case 'Droite':
        _updateState(_state.copyWith(
          droitePhotoPath: file.path,
        ));
        break;
    }

    debugPrint('Photo remplacée pour $direction: ${file.path}');
  } catch (e) {
    debugPrint('Erreur lors de la capture: $e');
  } finally {
    _isCapturing = false;
  }
}
Future<void> capturePhotoForCurrentDirection() async {
  final direction = _state.faceDirection;

  if (direction == null ||
      direction == 'Aucun visage détecté' ||
      direction == 'Positionnez le visage dans le cercle' ||
      direction == 'Erreur de détection') {
    debugPrint("Direction invalide");
    return;
  }

  await _capturePhotoForDirection(direction);
}
  void _updateState(FaceCaptureState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceService.dispose();
    super.dispose();
  }
}
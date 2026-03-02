import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FaceDetectionService {
  late FaceDetector _faceDetector;

  FaceDetectionService() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: true,
      ),
    );
  }

  Future<String> detectFaceDirection(Uint8List nv21Bytes, Size size, InputImageRotation rotation) async {
    final inputImage = InputImage.fromBytes(
      bytes: nv21Bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: size.width.toInt(),
      ),
    );

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) return 'Aucun visage';

    final headEulerY = faces.first.headEulerAngleY ?? 0.0;
    if (headEulerY < -15) return 'Gauche';
    if (headEulerY > 15) return 'Droite';
    return 'Front';
  }

  void dispose() {
    _faceDetector.close();
  }
}
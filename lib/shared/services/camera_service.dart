import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class CameraService {
  CameraController? controller;
  bool _isStreaming = false;

  /// Initialize camera
  Future<void> initializeCamera(CameraDescription camera) async {
    controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
      ? ImageFormatGroup.nv21
      : ImageFormatGroup.bgra8888,

    );

    await controller!.initialize();
  }

  /// Start image stream (cross-platform)
  void startImageStream(Function(InputImage, double) onImage) {
    if (_isStreaming || controller == null) return;

    _isStreaming = true;

    controller!.startImageStream((CameraImage image) {
      final brightness = computeBrightness(image);
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        onImage(inputImage, brightness);
      }
    });
  }
  ////////////// calculer si la lumiere est bon 
double computeBrightness(CameraImage image) {
  try {
    final yPlane = image.planes[0]; // plan Y (luminosité)
    final bytes = yPlane.bytes;

    int sum = 0;
    int count = 0;
    for (int i = 0; i < bytes.length; i += 16) { // échantillonnage 1 pixel sur 16
      sum += bytes[i];
      count++;
    }

    return count > 0 ? sum / count : 128.0;
  } catch (_) {
    return 128.0; // valeur neutre
  }
}
  /// Stop image stream
  Future<void> stopImageStream() async {
    if (!_isStreaming || controller == null) return;

    await controller!.stopImageStream();
    _isStreaming = false;
  }

  /// Dispose camera
  void dispose() {
    controller?.dispose();
  }

  /// Convert CameraImage to ML Kit InputImage (Android + iOS safe)
 InputImage? _convertCameraImage(CameraImage image) {
  if (controller == null) return null;

  final camera = controller!.description;

  final rotation = InputImageRotationValue.fromRawValue(
    camera.sensorOrientation,
  );

  if (rotation == null) return null;

  // ✅ Force correct format depending on platform
  final format = Platform.isAndroid
      ? InputImageFormat.nv21
      : InputImageFormat.bgra8888;

  final bytes = _concatenatePlanes(image.planes);

  final metadata = InputImageMetadata(
    size: Size(
      image.width.toDouble(),
      image.height.toDouble(),
    ),
    rotation: rotation,
    format: format,
    bytesPerRow: image.planes.first.bytesPerRow,
  );

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: metadata,
  );
}

  /// Combine image planes into one Uint8List
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();

    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }

    return allBytes.done().buffer.asUint8List();
  }
}
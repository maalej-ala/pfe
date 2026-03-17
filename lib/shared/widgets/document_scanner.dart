import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:pfe_flutter/shared/services/camera_service.dart';

class CardScannerPage extends StatefulWidget {
  // Callback SIMPLE : retourne uniquement l'image croppée
  final Function(File croppedImage) onPictureTaken;
  final CameraDescription camera;

  const CardScannerPage({
    super.key,
    required this.onPictureTaken,
    required this.camera,
  });

  @override
  State<CardScannerPage> createState() => _CardScannerPageState();
}

class _CardScannerPageState extends State<CardScannerPage> {
  final CameraService _cameraService = CameraService();

  bool _isInitialized = false;
  final double rectWidth = 320;
  final double rectHeight = 200;
  Size? _cameraPreviewSize;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraService.initializeCamera(widget.camera);
    if (mounted) setState(() => _isInitialized = true);
  }

  // Prend la photo + crop uniquement
  Future<void> _takePicture() async {
    try {
      final image = await _cameraService.controller!.takePicture();
      final cropped = await _cropCard(File(image.path));

      widget.onPictureTaken(cropped);           // ← Retourne seulement l'image croppée
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Erreur photo: $e");
    }
  }

  // Fonction de crop (identique à avant)
  Future<File> _cropCard(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return file;

    final previewSize = _cameraService.controller!.value.previewSize!;
    final previewWidth = previewSize.height;
    final previewHeight = previewSize.width;

    final screenSize = MediaQuery.of(context).size;
    double displayedWidth = screenSize.width;
    double displayedHeight = displayedWidth * previewHeight / previewWidth;
    double offsetY = (displayedHeight - screenSize.height) / 2;

    double left = (displayedWidth - rectWidth) / 2;
    double top = (screenSize.height - rectHeight) / 2 + offsetY;

    final scaleX = original.width / displayedWidth;
    final scaleY = original.height / displayedHeight;

    int cropX = (left * scaleX).round();
    int cropY = (top * scaleY).round();
    int cropWidth = (rectWidth * scaleX).round();
    int cropHeight = (rectHeight * scaleY).round();

    img.Image cropped = img.copyCrop(
      original,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    final croppedFile = File(file.path.replaceAll(".jpg", "_crop.jpg"));
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));
    return croppedFile;
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraService.controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final previewSize = Size(constraints.maxWidth, constraints.maxHeight);
            if (_cameraPreviewSize != previewSize) {
              setState(() => _cameraPreviewSize = previewSize);
            }
          });

          return Stack(
            children: [
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _cameraService.controller!.value.previewSize!.height,
                    height: _cameraService.controller!.value.previewSize!.width,
                    child: CameraPreview(_cameraService.controller!),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: rectWidth,
                  height: rectHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
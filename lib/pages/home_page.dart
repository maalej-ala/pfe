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

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);
    await _cameraService.initializeCamera(camera);

    _cameraService.startImageStream(_processCameraImage);
    setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final nv21Bytes = _cameraService.convertYUV420ToNV21(image);

      final size = Size(image.width.toDouble(), image.height.toDouble());
      final rotation = InputImageRotationValue.fromRawValue(
              _cameraService.controller!.description.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final direction =
          await _faceService.detectFaceDirection(nv21Bytes, size, rotation);

      if (mounted) {
        setState(() {
          _faceDirection = direction;
        });
      }
    } catch (e) {
      debugPrint("Erreur MLKit: $e");
    } finally {
      _isDetecting = false;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cameraService.controller != null &&
                    _cameraService.controller!.value.isInitialized
                ? SizedBox(
                    width: 300,
                    height: 400,
                    child: CameraPreview(_cameraService.controller!),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Direction du visage : $_faceDirection',
                style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
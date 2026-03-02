import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  String _faceDirection = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: true,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
    _cameraController = CameraController(
     camera,
     ResolutionPreset.medium,
     enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // ⭐ IMPORTANT
    );
    await _cameraController!.initialize();
    _cameraController!.startImageStream(_processCameraImage);
    setState(() {});
  }

 void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final Uint8List nv21Bytes = _yuv420ToNv21(image); // ⭐ Convert to NV21

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final imageRotation = InputImageRotationValue.fromRawValue(
            _cameraController!.description.sensorOrientation,
          ) ?? InputImageRotation.rotation0deg;

      final inputImageMetadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: InputImageFormat.nv21, // ⭐ Use nv21 for Android compatibility
        bytesPerRow: image.width, // ⭐ Packed row stride
      );

      final inputImage = InputImage.fromBytes(
        bytes: nv21Bytes,
        metadata: inputImageMetadata,
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final headEulerY = face.headEulerAngleY ?? 0.0;

        if (headEulerY < -15) {
          _faceDirection = 'Gauche';
        } else if (headEulerY > 15) {
          _faceDirection = 'Droite';
        } else {
          _faceDirection = 'Front';
        }
      } else {
        _faceDirection = 'Aucun visage';
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Erreur MLKit: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;
    final int yRowStride = image.planes[0].bytesPerRow;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final Uint8List nv21 = Uint8List(width * height * 3 ~/ 2);

    // Copy Y plane (packed, respecting stride)
    for (int y = 0; y < height; y++) {
      final int yOffset = y * yRowStride;
      final int nv21YIndex = y * width;
      nv21.setRange(nv21YIndex, nv21YIndex + width, yPlane, yOffset);
    }

    // Build interleaved VU plane for NV21 (V U V U...)
    int uvIndex = width * height;
    for (int y = 0; y < height ~/ 2; y++) {
      for (int x = 0; x < width ~/ 2; x++) {
        final int uvOffset = y * uvRowStride + x * uvPixelStride;
        nv21[uvIndex++] = vPlane[uvOffset]; // V (Cr)
        nv21[uvIndex++] = uPlane[uvOffset]; // U (Cb)
      }
    }

    return nv21;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cameraController != null && _cameraController!.value.isInitialized
                ? SizedBox(
                    width: 300,
                    height: 400,
                    child: CameraPreview(_cameraController!),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Direction du visage : $_faceDirection', style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

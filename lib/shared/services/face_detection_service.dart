import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  late final FaceDetector _faceDetector;

  FaceDetectionService() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: true,
      ),
    );
  }

  Future<String> detectFaceDirection(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) return 'Aucun visage';

    final headEulerY = faces.first.headEulerAngleY ?? 0.0;

    if (headEulerY < -15) return 'Gauche';
    if (headEulerY > 15) return 'Droite';
    return 'Front';
  }
  
  Future<List<Face>> getFaces(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    return faces;
  }

  /// Extrait le visage d'une image de carte d'identité (suppose un seul visage).
  /// Retourne un fichier temporaire contenant le visage recadré, ou null si aucun visage détecté.
  Future<File?> extractFaceFromFile(File imageFile) async {
  // Charger l'image en mémoire
  final bytes = await imageFile.readAsBytes();
  final original = img.decodeImage(bytes);
  if (original == null) return null;

  // ML Kit input
  final inputImage = InputImage.fromFile(imageFile);
  final faces = await getFaces(inputImage);
  if (faces.isEmpty) return null;

  final faceBox = faces.first.boundingBox;

  // 📌 dimensions visage
  final faceHeight = faceBox.height;
  final faceWidth = faceBox.width;

  // ================================
  // 🔥 PADDING (haut + bas)
  // ================================

  const double topPaddingFactor = 0.25;     // cheveux + front
  const double bottomPaddingFactor = 0.25;  // menton + cou (PLUS GRAND EN BAS)

  final topPadding = faceHeight * topPaddingFactor;
  final bottomPadding = faceHeight * bottomPaddingFactor;

  // ================================
  // 🔥 CALCUL COORDONNÉES SAFE
  // ================================

  final x = faceBox.left.clamp(0, original.width.toDouble());
  final y = (faceBox.top - topPadding).clamp(0, original.height.toDouble());

  final width = faceWidth
      .clamp(0, original.width.toDouble() - x);

  final height = (faceHeight + topPadding + bottomPadding)
      .clamp(0, original.height.toDouble() - y);

  // ================================
  // 🔥 CROP IMAGE
  // ================================

  final cropped = img.copyCrop(
    original,
    x: x.toInt(),
    y: y.toInt(),
    width: width.toInt(),
    height: height.toInt(),
  );

  // ================================
  // 🔥 SAVE TEMP FILE
  // ================================

  final tempDir = Directory.systemTemp;
  final outFile = File(
    '${tempDir.path}/face_crop_${DateTime.now().millisecondsSinceEpoch}.png',
  );

  await outFile.writeAsBytes(img.encodePng(cropped));

  return outFile;
}
  
  void dispose() {
    _faceDetector.close();
  }
}
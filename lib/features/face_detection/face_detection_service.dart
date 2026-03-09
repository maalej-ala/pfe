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

    // Créer un InputImage pour ML Kit
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await getFaces(inputImage);
    if (faces.isEmpty) return null;

    final faceBox = faces.first.boundingBox;
    
    // Calculer la hauteur du visage
    final faceHeight = faceBox.height;
    
    // AJOUTER 40% EN HAUT pour inclure les cheveux
    final newTop = faceBox.top - (faceHeight * 0.25);
    
    // S'assurer que les coordonnées sont dans les limites de l'image
    final x = faceBox.left < 0 ? 0 : faceBox.left.toInt();
    final y = newTop < 0 ? 0 : newTop.toInt();  // Nouveau y avec marge en haut
    final w = (faceBox.width + faceBox.left > original.width)
        ? (original.width - x)
        : faceBox.width.toInt();
    final h = (faceBox.height + newTop > original.height)  // Utiliser newTop pour le calcul
        ? (original.height - y)
        : (faceBox.height + (faceHeight * 0.25)).toInt();  // Ajouter la même hauteur en bas pour équilibrer

    // Recadrer le visage avec les cheveux
    final cropped = img.copyCrop(
      original,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    // Sauvegarder dans un fichier temporaire
    final tempDir = Directory.systemTemp;
    final outFile = await File('${tempDir.path}/face_crop_${DateTime.now().millisecondsSinceEpoch}.png').create();
    await outFile.writeAsBytes(img.encodePng(cropped));
    return outFile;
  }
  
  void dispose() {
    _faceDetector.close();
  }
}
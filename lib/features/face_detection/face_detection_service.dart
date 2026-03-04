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


  void dispose() {
    _faceDetector.close();
  }
}
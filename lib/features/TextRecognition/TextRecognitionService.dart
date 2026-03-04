// lib/features/text_recognition/text_recognition_service.dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class TextRecognitionService {
  // Instance du texteur
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  // Méthode pour reconnaître le texte à partir d'un fichier image
  Future<String> recognizeTextFromFile(File imageFile) async {
    try {
      // Créer une InputImage à partir du fichier
      final inputImage = InputImage.fromFile(imageFile);
      
      // Traiter l'image pour la reconnaissance de texte
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Extraire tout le texte reconnu
      String fullText = recognizedText.text;
      
      // Optionnel : parcourir les blocs de texte avec leurs coordonnées
      for (TextBlock block in recognizedText.blocks) {
        print('Bloc de texte: ${block.text}');
        print('Coordonnées: ${block.boundingBox}');
        
        // Parcourir les lignes dans chaque bloc
        for (TextLine line in block.lines) {
          print('Ligne: ${line.text}');
          
          // Parcourir les éléments (mots) dans chaque ligne
          for (TextElement element in line.elements) {
            print('Mot: ${element.text}');
          }
        }
      }
      
      return fullText;
    } catch (e) {
      print('Erreur lors de la reconnaissance: $e');
      return '';
    }
  }
  
  // // Méthode pour reconnaître le texte à partir d'une image de la caméra
  // Future<String> recognizeTextFromCameraImage(CameraImage cameraImage) async {
  //   try {
  //     // Convertir CameraImage en InputImage
  //     // Note: Cette conversion dépend de votre implémentation de caméra
  //     final inputImage = _convertCameraImageToInputImage(cameraImage);
      
  //     final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
  //     return recognizedText.text;
  //   } catch (e) {
  //     print('Erreur lors de la reconnaissance: $e');
  //     return '';
  //   }
  // }
  
  // // Méthode utilitaire pour convertir CameraImage en InputImage
  // InputImage _convertCameraImageToInputImage(CameraImage cameraImage) {
  //   // À implémenter selon votre cas d'usage
  //   // C'est plus complexe et dépend du format de l'image
  //   throw UnimplementedError();
  // }
  
  // Libérer les ressources
  void dispose() {
    _textRecognizer.close();
  }
}
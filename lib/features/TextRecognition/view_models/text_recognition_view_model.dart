import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pfe_flutter/shared/services/face_detection_service.dart';

class TextRecognitionViewModel extends ChangeNotifier {
  
  /// MLKit
final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  /// Image Picker
  final ImagePicker _imagePicker = ImagePicker();
    final FaceDetectionService _faceService = FaceDetectionService();
File? extractedFace;
  /// STATE
  File? selectedImage;
  RecognizedText? result;
  bool isProcessing = false;

  Future<void> processScannedImage(File file) async {
    selectedImage = file;
    result = null;
    extractedFace = null;
    notifyListeners();
    await _recognizeTextAndFace();
  }
  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      result = null;
      notifyListeners();

      await _recognizeTextAndFace();
    }
  }

 

  /// SERVICE : Text Recognition
  Future<void> _recognizeTextAndFace() async {

    if (selectedImage == null) return;
    isProcessing = true;
    notifyListeners();

    try {

      final inputImage = InputImage.fromFile(selectedImage!);

      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

 result = recognizedText;
 extractedFace =
        await _faceService.extractFaceFromFile(selectedImage!);

    } catch (e) {
      debugPrint("Error recognizing text: $e");
    } finally {

    isProcessing = false;
    notifyListeners();
  }}

  /// Lignes triées de haut en bas (lecture naturelle de la carte)
List<String> get extractedIdCardLines {
  if (result == null) return [];

  final List<Map<String, dynamic>> lineInfos = [];

  for (final block in result!.blocks) {
    for (final line in block.lines) {
      final text = line.text;
      final boundingBox = line.boundingBox;

      final yCenter = boundingBox.top + (boundingBox.height / 2);
      final xStart = boundingBox.left;

      lineInfos.add({
        'text': text,
        'yCenter': yCenter,
        'height': boundingBox.height,
        'xStart': xStart, // ✅ ajout
      });
    }
  }

  // Tri haut → bas
  lineInfos.sort((a, b) => a['yCenter'].compareTo(b['yCenter']));

  final List<String> mergedLines = [];
  String? current;
  double? lastY;
  double? lastHeight;
  double? lastX;

  for (final info in lineInfos) {
    final text = (info['text'] as String).trim();
    if (text.isEmpty) continue;

    final y = info['yCenter'] as double;
    final h = info['height'] as double;
    final x = info['xStart'] as double;

    if (current == null) {
      current = text;
      lastY = y;
      lastHeight = h;
      lastX = x;
    } else {
      final threshold = (lastHeight! + h) / 2 * 0.4;

      if ((y - lastY!).abs() < threshold) {
        // ✅ Même ligne → comparer gauche → droite
        if (x < lastX!) {
          // texte actuel est PLUS à gauche
          current = "$text    $current";
        } else {
          // texte actuel est PLUS à droite
          current = "$current    $text";
        }
      } else {
        mergedLines.add(current);
        current = text;
      }

      lastY = y;
      lastHeight = h;
      lastX = x;
    }
  }

  if (current != null && current.isNotEmpty) {
    mergedLines.add(current);
  }

  return mergedLines;
}

Map<String, String?> extractID(List<String> lines) {
  final Map<String, String?> data = {
    "numero": null,
    "nom": null,
    "prenom": null,
    "date_naissance": null,
    "sexe": null,
    "lieu_naissance": null,
    "profession": null,
    "date_etablissement": null,
    "date_expiration": null,
  };

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    // ── Numéro ──────────────────────────────────────────────
    if (data["numero"] == null) {
      final m = RegExp(r'\d{4}-\d{3}-\d{4}').firstMatch(line);
      if (m != null) {
        data["numero"] = m.group(0);
        continue;
      }
    }

    // ── Nom ─────────────────────────────────────────────────
    if (RegExp(r'^Nom\s*:?', caseSensitive: false).hasMatch(line)) {
      data["nom"] = _extractValue(line);
      continue;
    }

    // ── Prénom ──────────────────────────────────────────────
    if (RegExp(r'^Pr[eé]nom\s*:?', caseSensitive: false).hasMatch(line)) {
      data["prenom"] = _extractValue(line);
      continue;
    }

    // ── Date naissance + Sexe ────────────────────────────────
    // "N le: 26-06-1991 Sexe: F"
    if (RegExp(r'^N[eé]?\s*le\s*:?', caseSensitive: false).hasMatch(line)) {
      final dateMatch = RegExp(r'\d{2}-\d{2}-\d{4}').firstMatch(line);
      if (dateMatch != null) data["date_naissance"] = dateMatch.group(0);

      final sexeMatch = RegExp(r'Sexe\s*:\s*([MF])', caseSensitive: false)
          .firstMatch(line);
      if (sexeMatch != null) data["sexe"] = sexeMatch.group(1)?.toUpperCase();
      continue;
    }

    // ── Sexe seul (si sur ligne séparée) ────────────────────
    if (data["sexe"] == null &&
        RegExp(r'^Sexe\s*:?', caseSensitive: false).hasMatch(line)) {
      final m = RegExp(r'Sexe\s*:\s*([MF])', caseSensitive: false)
          .firstMatch(line);
      if (m != null) data["sexe"] = m.group(1)?.toUpperCase();
      continue;
    }

    // ── Lieu de naissance ────────────────────────────────────
    // "A KPALIME VILLE /KLOTO"
    if (RegExp(r'^A\s+[A-Z]').hasMatch(line) &&
        data["lieu_naissance"] == null) {
      data["lieu_naissance"] = line.replaceFirst(RegExp(r'^A\s+'), '').trim();
      continue;
    }

    // ── Profession ──────────────────────────────────────────
    if (RegExp(r'^Profession\s*:?', caseSensitive: false).hasMatch(line)) {
      data["profession"] = _extractValue(line);
      continue;
    }

    // ── Fait le (date établissement) ────────────────────────
    if (RegExp(r'^Fait\s*le\s*:?', caseSensitive: false).hasMatch(line)) {
      final m = RegExp(r'\d{2}-\d{2}-\d{4}').firstMatch(line);
      if (m != null) data["date_etablissement"] = m.group(0);
      continue;
    }

    // ── Expire le ───────────────────────────────────────────
    if (RegExp(r'^Expire\s*le\s*:?', caseSensitive: false).hasMatch(line)) {
      final m = RegExp(r'\d{2}-\d{2}-\d{4}').firstMatch(line);
      if (m != null) data["date_expiration"] = m.group(0);
      continue;
    }
  }

  return data;
}

/// Extrait la valeur après le "Label:" 
String? _extractValue(String line) {
  final idx = line.indexOf(':');
  if (idx == -1) return null;
  final value = line.substring(idx + 1).trim();
  return value.isEmpty ? null : value;
}

  /// Dispose
void disposeRecognizer() {
  _textRecognizer.close();
  _faceService.dispose();
}
}
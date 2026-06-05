  import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:image_picker/image_picker.dart';
  import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
  import 'package:pfe_flutter/features/TextRecognition/models/text_recognition_model.dart';
  import 'package:pfe_flutter/shared/constantes.dart';
  import 'package:pfe_flutter/shared/services/device_service.dart';
  import 'package:pfe_flutter/shared/services/face_detection_service.dart';

  class TextRecognitionViewModel extends ChangeNotifier {
    TextRecognitionModel? extractedModel;
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

      // 🔥 Face extraction
      extractedFace =
          await _faceService.extractFaceFromFile(selectedImage!);

      // 🔥 EXTRACTION DATA
Map<String, String?> extractedMap;

final lines = extractedIdCardLines;

// ✅ DETECTION PASSEPORT
if (isPassportMRZ(lines)) {

  debugPrint("===== PASSPORT DETECTED =====");

  extractedMap = extractPassportMRZ(lines);

} else {

  debugPrint("===== ID CARD DETECTED =====");

  extractedMap = extractID(lines);
}
      // 🔥 MODEL COMPLET
      extractedModel = TextRecognitionModel.fromMap(
        extractedMap,
        cinImage: selectedImage,   // ✅ image CIN
        faceImage: extractedFace,  // ✅ visage
      );

    } catch (e) {
      debugPrint("Error recognizing text: $e");
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

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

  String formatDate(String input) {
    final parts = input.split('/'); // 26/06/1991
    return "${parts[2]}-${parts[1]}-${parts[0]}"; // 1991-06-26
  }

  Map<String, String?> extractID(List<String> lines) {
    final Map<String, String?> data = {
      "numero": null,
      "nom": null,
      "prenom": null,
      "date_naissance": null,
      "date_expiration": null,
      "adresse_domicile": null,
      "sexe": null,
    };

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) continue;

      // =====================================================
      // NUMERO CIN
      // Exemple:
      // 1 02 19960101 00093 8
      // =====================================================
      if (data["numero"] == null) {
        final numeroMatch = RegExp(
          r'^\d+\s+\d+\s+\d{8}\s+\d+\s+\d+$',
        ).firstMatch(line);

        if (numeroMatch != null) {
          data["numero"] =
              line.replaceAll(RegExp(r'\s+'), ' ').trim();
          continue;
        }
      }

      // =====================================================
      // PRENOM
      // =====================================================
      if (RegExp(r'^Pr[eé]noms?', caseSensitive: false)
          .hasMatch(line)) {
        if (i + 1 < lines.length) {
          final value = lines[i + 1].trim();

          if (!_isLabel(value)) {
            data["prenom"] = value;
          }
        }
        continue;
      }

      // =====================================================
      // NOM
      // =====================================================
      if (RegExp(r'^Nom$', caseSensitive: false)
          .hasMatch(line)) {
        if (i + 1 < lines.length) {
          final value = lines[i + 1].trim();

          if (!_isLabel(value)) {
            data["nom"] = value;
          }
        }
        continue;
      }

      // =====================================================
      // DATE NAISSANCE + SEXE
      // Exemple:
      // 01/10/1996   M   172 cm
      // =====================================================
      if (data["date_naissance"] == null) {
        final dateMatch = RegExp(
          r'\d{2}/\d{2}/\d{4}',
        ).firstMatch(line);

        if (dateMatch != null) {
          data["date_naissance"] =
              formatDate(dateMatch.group(0)!);

          final sexeMatch = RegExp(
            r'\b(M|F)\b',
            caseSensitive: false,
          ).firstMatch(line);

          if (sexeMatch != null) {
            data["sexe"] =
                sexeMatch.group(1)?.toUpperCase();
          }
        }
      }

      // =====================================================
      // DATE EXPIRATION
      // Exemple:
      // 27/12/2017   26/12/2027
      // =====================================================
      final dates = RegExp(
        r'\d{2}/\d{2}/\d{4}',
      ).allMatches(line).map((e) => e.group(0)!).toList();

      if (dates.length >= 2) {
        data["date_expiration"] =
            formatDate(dates[1]);
      }

      // =====================================================
      // ADRESSE DOMICILE
      // =====================================================
      if (RegExp(r'Adresse du domicile',
              caseSensitive: false)
          .hasMatch(line)) {
        if (i + 1 < lines.length) {
          final value = lines[i + 1].trim();

          if (!_isLabel(value)) {
            data["adresse_domicile"] = value;
          }
        }
        continue;
      }
    }

    return data;
  }

  // =====================================================
  // Vérifie si la ligne est un label
  // =====================================================
  bool _isLabel(String text) {
    final labels = [
      'Nom',
      'Prénoms',
      'Prenom',
      'Date de naissance',
      'Sexe',
      'Lieu de naissance',
      'Adresse du domicile',
      'Date de délivrance',
      'Date d\'expiration',
    ];

    return labels.any(
      (e) => text.toLowerCase().contains(e.toLowerCase()),
    );
  }

  // =====================================================
  // Format date
  // 01/10/1996 -> 01-10-1996
  // =====================================================


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

bool isPassportMRZ(List<String> lines) {

  int mrzLines = 0;

  for (final line in lines) {

    final cleaned = line.replaceAll(' ', '');

    // contient beaucoup de <
    if (cleaned.contains('<<')) {

      mrzLines++;
    }
  }

  return mrzLines >= 2;
}

String? _convertMrzDate(String raw) {

  raw = _fixNumericMrzField(raw);

  if (!RegExp(r'^\d{6}$')
      .hasMatch(raw)) {

    return null;
  }

  try {

    final yy = raw.substring(0, 2);
    final mm = raw.substring(2, 4);
    final dd = raw.substring(4, 6);

    final month = int.parse(mm);
    final day = int.parse(dd);

    if (month < 1 || month > 12) {
      return null;
    }

    if (day < 1 || day > 31) {
      return null;
    }

    final year =
        int.parse(yy) >= 30
            ? '19$yy'
            : '20$yy';

    return '$year-$mm-$dd';

  } catch (_) {

    return null;
  }
}


Map<String, String?> extractPassportMRZ(
  List<String> lines,
) {

  // =========================
  // Nettoyage MRZ
  // =========================

  final cleaned = lines
      .map((e) => e
          .replaceAll(' ', '')
          .replaceAll('«', '<<')
          .replaceAll('‹', '<')
          //.replaceAll('K<', '<<')
          )
      .toList();

  // =========================
  // Récupération lignes MRZ
  // =========================

  String? line1;
  String? line2;

  for (int i = 0; i < cleaned.length; i++) {

    final l = cleaned[i];

    // ligne nom
    if (l.startsWith('P<')) {
      line1 = l;
    }

    // ligne data
    if (RegExp(r'^[A-Z0-9<]{20,}$').hasMatch(l)) {

      // parfois OCR coupe la ligne MRZ
      if (i + 1 < cleaned.length &&
          cleaned[i + 1].length < 20) {

        line2 = l + cleaned[i + 1];

      } else {

        line2 = l;
      }
    }
  }

  if (line1 == null || line2 == null) {
    return {};
  }

  // =========================
  // Correction OCR
  // =========================

  // line2 = line2
  //     .replaceAll('O', '0')
  //     .replaceAll('I', '1')
  //     .replaceAll('B', '8');

  debugPrint("MRZ1 = $line1");
  debugPrint("MRZ2 = $line2");

  // =========================
  // NOM / PRENOM
  // =========================

  final namesPart = line1.substring(5);

  final split = namesPart.split('<<');

  final surname = split.isNotEmpty
      ? split[0]
          .replaceAll('<', ' ')
          .trim()
      : '';

  final givenNames = split.length > 1
      ? split[1]
          .replaceAll('<', ' ')
          .trim()
      : '';

  // =========================
  // NUMERO PASSPORT
  // =========================

  final passportNumber =
      line2.substring(0, 9)
          .replaceAll('<', '');

  // =========================
  // NATIONALITE
  // =========================

  final nationality =
      line2.substring(10, 13);

  // =========================
  // DATE NAISSANCE
  // =========================

  final birthRaw =
      line2.substring(13, 19);

  // =========================
  // SEXE
  // =========================

  final sex =
      line2.substring(20, 21);

  // =========================
  // DATE EXPIRATION
  // =========================

  final expiryRaw =
      line2.substring(21, 27);

  return {

    "document_type": "PASSPORT",

    "numero": passportNumber,

    "nom": surname,

    "prenom": givenNames,

    "nationalite": nationality,

    "date_naissance":
        _convertMrzDate(birthRaw),

    "date_expiration":
        _convertMrzDate(expiryRaw),

    "sexe": sex,
  };
}

String _fixNumericMrzField(String value) {

  return value
      .replaceAll('O', '0')
      .replaceAll('Q', '0')
      .replaceAll('D', '0')

      .replaceAll('I', '1')
      .replaceAll('L', '1')

      .replaceAll('Z', '2')

      .replaceAll('S', '5')

      .replaceAll('B', '8');
}


  Future<void> sendToBackend(Map<String, String?> data) async {

    final deviceId = await DeviceService().getDeviceId();

    final url = Uri.parse("${AppConstants.baseUrl}/api/ocr");

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    // 🔥 JSON fields
    request.fields['deviceId'] = deviceId;
    request.fields['nom'] = data["nom"] ?? "";
    request.fields['prenom'] = data["prenom"] ?? "";
    request.fields['sexe'] = data["sexe"] ?? "";
    request.fields['dateNaissance'] = data["date_naissance"] ?? "";
    request.fields['dateExpiration'] = data["date_expiration"] ?? "";
    request.fields['numeroCin'] = data["numero"] ?? "";
    request.fields['adresseDomicile'] = data["adresse_domicile"] ?? "";

    // 🔥 image CIN
    if (selectedImage != null) {

      request.files.add(
        await http.MultipartFile.fromPath(
          'photoCin',
          selectedImage!.path,
        ),
      );
    }

    if (extractedFace != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'photoVisageCin',
        extractedFace!.path,
      ),
    );
  }

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: $responseBody");

    if (response.statusCode != 200 &&
        response.statusCode != 201) {

      throw Exception("Erreur upload OCR");
    }
  }
  }
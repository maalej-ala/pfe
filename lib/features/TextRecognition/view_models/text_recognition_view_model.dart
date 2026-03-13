import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/text_recognition_model.dart';

class TextRecognitionViewModel extends ChangeNotifier {

  /// MLKit
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Image Picker
  final ImagePicker _imagePicker = ImagePicker();

  /// STATE
  File? selectedImage;
  RecognizedText? result;
  bool isProcessing = false;

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

      await recognizeText();
    }
  }

  /// Take photo
  Future<void> takePhoto() async {

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      result = null;
      notifyListeners();
      await recognizeText();
    }
  }

  /// SERVICE : Text Recognition
  Future<void> recognizeText() async {

    if (selectedImage == null) return;
    isProcessing = true;
    notifyListeners();

    try {

      final inputImage = InputImage.fromFile(selectedImage!);

      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

 result = recognizedText;

    } catch (e) {
      debugPrint("Error recognizing text: $e");
    } finally {

    isProcessing = false;
    notifyListeners();
  }}

  /// Dispose
  void disposeRecognizer() {
    _textRecognizer.close();
  }
}
import 'package:flutter/material.dart';
import 'package:pfe_flutter/shared/widgets/document_scanner.dart';
import 'package:provider/provider.dart';
import '../view_models/text_recognition_view_model.dart';
import 'dart:io';                    // ← AJOUTE CETTE LIGNE
// === AJOUTÉS ===
import 'package:camera/camera.dart';
class TextRecognitionPage extends StatelessWidget {
  const TextRecognitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TextRecognitionViewModel(),
      child: const _TextRecognitionView(),
    );
  }
}

class _TextRecognitionView extends StatelessWidget {
  const _TextRecognitionView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TextRecognitionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Reconnaissance de texte")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// IMAGE
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: vm.selectedImage != null
                  ? Image.file(vm.selectedImage!, fit: BoxFit.cover)
                  : const Center(child: Text("Sélectionnez une image")),
            ),

            const SizedBox(height: 20),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: vm.pickImageFromGallery,
                    child: const Text("Galerie"),
                  ),
                ),
                const SizedBox(width: 10),

                /// ==================== BOUTON SCANNER (remplace l'ancien "Caméra") ====================
                Expanded(
  child: ElevatedButton(
    onPressed: () async {
      final vm = context.read<TextRecognitionViewModel>();

      try {
        final cameras = await availableCameras();
        final camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CardScannerPage(
              camera: camera,
              onPictureTaken: (File croppedImage) {
                // ← On passe directement au ViewModel
                vm.processScannedImage(croppedImage);
              },
            ),
          ),
        );
      } catch (e) {
        debugPrint("Erreur caméra: $e");
      }
    },
    child: const Text("Scanner Carte (Caméra)"),
  ),
),
              ],
            ),

            const SizedBox(height: 20),

            /// RESULT (inchangé)
            if (vm.isProcessing)
              const CircularProgressIndicator()
            else if (vm.result != null)
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TEXTE OCR
                      const Text(
            "Texte reconnu (lignes fusionnées) :",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 12),

         ...vm.extractedIdCardLines.map((line) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Text(
      line,
      style: const TextStyle(
        fontSize: 15,
        height: 1.4,
        letterSpacing: 0.3,
        fontFamily: 'monospace', // ← IMPORTANT : respect les espaces multiples
      ),
    ),
  ),
)),

                      const Divider(height: 30, color: Colors.black),

                      // EXTRACTION DES DONNÉES
                      Builder(
                        builder: (_) {
                          final extracted = vm.extractID(vm.extractedIdCardLines);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Numéro : ${extracted['numero'] ?? '-'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Nom : ${extracted['nom'] ?? '-'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Prénom : ${extracted['prenom'] ?? '-'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Date de naissance : ${extracted['date_naissance'] ?? '-'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Sexe : ${extracted['sexe'] ?? '-'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      /// VISAGE EXTRAIT (déjà présent dans ton code)
                      if (vm.extractedFace != null)
                        Column(
                          children: [
                            const Text("Visage extrait :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Image.file(vm.extractedFace!, height: 150),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
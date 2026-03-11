import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/text_recognition_view_model.dart';

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
      appBar: AppBar(
        title: const Text("Reconnaissance de texte"),
      ),

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
                  : const Center(
                      child: Text("Sélectionnez une image"),
                    ),
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

                Expanded(
                  child: ElevatedButton(
                    onPressed: vm.takePhoto,
                    child: const Text("Caméra"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// RESULT
            if (vm.isProcessing)
              const CircularProgressIndicator()
            else if (vm.result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(vm.result!.text),
                ),
              )
          ],
        ),
      ),
    );
  }
}
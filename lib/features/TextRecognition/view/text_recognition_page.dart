import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/identification/views/identification_page.dart';
import 'package:pfe_flutter/shared/widgets/document_scanner.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:provider/provider.dart';
import '../view_models/text_recognition_view_model.dart';
import 'dart:io';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                PageHeader(
                  currentStep: 0,
                  totalSteps: 8,
                  title: 'Reconnaissance de texte',
                  subtitle: 'Scannez votre carte d\'identité pour extraire les informations',
                  onBack: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Image Preview Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(text: 'Image de la carte d\'identité'),
                              const SizedBox(height: 16),
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: vm.selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          vm.selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.credit_card_outlined,
                                            size: 48,
                                            color: colorScheme.primary.withValues(alpha: 0.3),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Aucune image sélectionnée',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.primary.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.photo_library_outlined,
                                      label: 'Galerie',
                                      onPressed: vm.pickImageFromGallery,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.camera_alt_outlined,
                                      label: 'Scanner',
                                      onPressed: () => _openScanner(context, vm),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Processing Indicator
                        if (vm.isProcessing)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Traitement en cours...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),

                        // Results Card
                        if (vm.result != null && !vm.isProcessing) ...[
                          //Extracted Text Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel(text: 'Texte reconnu'),
                                const SizedBox(height: 16),
                                ...vm.extractedIdCardLines.map((line) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.primary.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Text(
                                      line,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),




                         // Extracted Data Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel(text: 'Informations extraites'),
                                const SizedBox(height: 16),
                                Builder(
                                  builder: (_) {
                                    final extracted = vm.extractID(vm.extractedIdCardLines);
                                  return Column(
  children: [
    _DataRow(
      label: 'Numéro CIN',
      value: extracted['numero'] ?? '-',
    ),

    _DataRow(
      label: 'Nom',
      value: extracted['nom'] ?? '-',
    ),

    _DataRow(
      label: 'Prénom',
      value: extracted['prenom'] ?? '-',
    ),

    _DataRow(
      label: 'Date de naissance',
      value: extracted['date_naissance'] ?? '-',
    ),

    _DataRow(
      label: 'Sexe',
      value: extracted['sexe'] ?? '-',
    ),

    _DataRow(
      label: 'Date d\'expiration',
      value: extracted['date_expiration'] ?? '-',
    ),

    _DataRow(
      label: 'Adresse domicile',
      value: extracted['adresse_domicile'] ?? '-',
    ),
  ],
);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),



                          // Extracted Face Card
                          
                          
                          // if (vm.extractedFace != null)
                          //   Container(
                          //     padding: const EdgeInsets.all(24),
                          //     decoration: BoxDecoration(
                          //       color: colorScheme.surface,
                          //       borderRadius: BorderRadius.circular(24),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: colorScheme.primary.withValues(alpha: 0.08),
                          //           blurRadius: 20,
                          //           offset: const Offset(0, 4),
                          //         ),
                          //       ],
                          //     ),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         _SectionLabel(text: 'Visage extrait'),
                          //         const SizedBox(height: 16),
                          //         Center(
                          //           child: Container(
                          //             decoration: BoxDecoration(
                          //               borderRadius: BorderRadius.circular(16),
                          //               boxShadow: [
                          //                 BoxShadow(
                          //                   color: colorScheme.primary.withValues(alpha: 0.1),
                          //                   blurRadius: 10,
                          //                   offset: const Offset(0, 2),
                          //                 ),
                          //               ],
                          //             ),
                          //             child: ClipRRect(
                          //               borderRadius: BorderRadius.circular(16),
                          //               child: Image.file(
                          //                 vm.extractedFace!,
                          //                 height: 150,
                          //                 width: 150,
                          //                 fit: BoxFit.cover,
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),

                          const SizedBox(height: 20),

                          // Complete Button
                          if (vm.selectedImage != null && vm.extractedFace != null)
                            PrimaryButton(
                              text: 'Continuer',
                              onPressed: () => _completeVerification(context, vm),
                            ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openScanner(BuildContext context, TextRecognitionViewModel vm) async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      if (!context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CardScannerPage(
            camera: camera,
            onPictureTaken: (File croppedImage) {
              vm.processScannedImage(croppedImage);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("Erreur caméra: $e");
    }
  }

  Future<void> _completeVerification(BuildContext context, TextRecognitionViewModel vm) async {
    final File? cinImage = vm.selectedImage;
    final File? faceImage = vm.extractedFace;

    if (cinImage == null || faceImage == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de terminer, certaines images sont manquantes.'),
        ),
      );
      return;
    }

    try {
      // Send OCR data to backend
      await vm.sendToBackend(vm.extractID(vm.extractedIdCardLines));

      if (!context.mounted) return;

      // Navigate to identification page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const IdentificationPage(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur serveur: $e'),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────
// INTERNAL WIDGETS
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                '$label:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
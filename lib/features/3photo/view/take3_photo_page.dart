// view/take3_photo_page.dart

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/3photo/view_model/face_capture_view_model.dart';
import 'package:pfe_flutter/shared/app_colors.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';

class Take3PhotoPage extends StatefulWidget {
  const Take3PhotoPage({super.key});

  @override
  State<Take3PhotoPage> createState() => _Take3PhotoPageState();
}

class _Take3PhotoPageState extends State<Take3PhotoPage>
    with SingleTickerProviderStateMixin {
  late final FaceCaptureViewModel _viewModel;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = FaceCaptureViewModel();
    _viewModel.addListener(_updateUI);
    _viewModel.initialize();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _viewModel.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Icône selon la direction ──────────────────────────────
  IconData _directionIcon(String direction) {
    if (direction.toLowerCase().contains('gauche')) return Icons.arrow_back_rounded;
    if (direction.toLowerCase().contains('droite')) return Icons.arrow_forward_rounded;
    return Icons.face_rounded;
  }

  Color _directionColor(String direction) {
    if (direction.toLowerCase().contains('gauche')) return const Color(0xFF1B6CA8);
    if (direction.toLowerCase().contains('droite')) return const Color(0xFF2E7D32);
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;
    final controller = _viewModel.controller;
    final directionColor = _directionColor(state.faceDirection);

    // Compte les photos prises
    final totalPhotos = [
      state.facePhotoPath,
      state.gauchePhotoPath,
      state.droitePhotoPath,
    ].where((p) => p != null).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                // ── En-tête ──────────────────────────────────────
                PageHeader(
                  currentStep: 6,
                  totalSteps: 8,
                  title: 'Vérification en direct',
                  subtitle: 'Prenez 3 photos pour confirmer votre identité',
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        // ── Indicateur de progression ─────────────
                        _ProgressSteps(total: 3, done: totalPhotos),
                        const SizedBox(height: 20),

                        // ── Instruction direction ─────────────────
                        _DirectionBanner(
                          direction: state.faceDirection,
                          icon: _directionIcon(state.faceDirection),
                          color: directionColor,
                        ),
                        const SizedBox(height: 16),

                        // ── Aperçu caméra ─────────────────────────
                        _CameraPreviewCard(
                          controller: controller,
                          pulseAnimation: _pulseAnimation,
                          directionColor: directionColor,
                        ),

                        const SizedBox(height: 20),

                        // ── Bouton capturer ───────────────────────
                        _CaptureButton(
                          onPressed: () async {
                            await _viewModel.capturePhotoForCurrentDirection();
                          },
                          label: 'Prendre la photo',
                          isPrimary: true,
                        ),

                        const SizedBox(height: 12),

                        // ── Bouton reprendre ──────────────────────
                        _CaptureButton(
                          onPressed: () async {
                            await _viewModel.capturePhotoForCurrentDirection();
                          },
                          label: 'Reprendre cette photo',
                          isPrimary: false,
                        ),

                        const SizedBox(height: 24),

                        // ── Photos capturées ──────────────────────
                        if (totalPhotos > 0) ...[
                          _SectionLabel(label: 'Photos capturées ($totalPhotos/3)'),
                          const SizedBox(height: 12),
                          _PhotosGrid(
                            facePhotoPath: state.facePhotoPath,
                            frontFaceExtracted: state.frontFaceExtracted,
                            gauchePhotoPath: state.gauchePhotoPath,
                            droitePhotoPath: state.droitePhotoPath,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ── Bouton terminer (quand tout est fait) ──
                        if (totalPhotos == 3) ...[
                          PrimaryButton(
                            text: 'Terminer la vérification',
                            onPressed: () => Navigator.pop(context),
                            enabled: true,
                          ),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 16),
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
}

// ═══════════════════════════════════════════════════════════════
//  WIDGETS PRIVÉS
// ═══════════════════════════════════════════════════════════════

// ── Progression 3 étapes ─────────────────────────────────────
class _ProgressSteps extends StatelessWidget {
  final int total;
  final int done;
  const _ProgressSteps({required this.total, required this.done});

  static const _labels = ['Face', 'Gauche', 'Droite'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(total, (i) {
          final isDone = i < done;
          final isCurrent = i == done;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.secondary
                              : isCurrent
                                  ? AppColors.primary
                                  : const Color(0xFFF0EDE6),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.white
                                        : const Color(0xFFAAAAAA),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDone
                              ? AppColors.secondary
                              : isCurrent
                                  ? AppColors.primary
                                  : const Color(0xFFAAAAAA),
                          fontWeight: isDone || isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < total - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i < done
                            ? AppColors.secondary
                            : const Color(0xFFE5E0D5),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Bandeau direction ────────────────────────────────────────
class _DirectionBanner extends StatelessWidget {
  final String direction;
  final IconData icon;
  final Color color;

  const _DirectionBanner({
    super.key,
    required this.direction,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          /// Icon Circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          /// Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Position actuelle',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  direction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aperçu caméra stylisé ────────────────────────────────────
class _CameraPreviewCard extends StatelessWidget {
  final CameraController? controller;
  final Animation<double> pulseAnimation;
  final Color directionColor;

  const _CameraPreviewCard({
    required this.controller,
    required this.pulseAnimation,
    required this.directionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: double.infinity,
          height: 340,
          child: controller != null && controller!.value.isInitialized
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Aperçu caméra — cover portrait sans déformation
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final previewSize = controller!.value.previewSize!;

                        // La caméra frontale Android retourne previewSize
                        // en mode "sensor" (paysage natif) même quand l'app
                        // est en portrait. On prend toujours la plus grande
                        // dimension comme hauteur et la plus petite comme largeur.
                        final sensorW = previewSize.width < previewSize.height
                            ? previewSize.width
                            : previewSize.height;
                        final sensorH = previewSize.width > previewSize.height
                            ? previewSize.width
                            : previewSize.height;

                        // Ratio portrait réel (ex: 9/16 ≈ 0.5625)
                        final portraitRatio = sensorW / sensorH;

                        final boxW = constraints.maxWidth;
                        final boxH = constraints.maxHeight;

                        double renderW, renderH;
                        if (boxW / boxH > portraitRatio) {
                          // Box trop large → on cale sur la largeur, on coupe en hauteur
                          renderW = boxW;
                          renderH = boxW / portraitRatio;
                        } else {
                          // Box trop haut → on cale sur la hauteur, on coupe en largeur
                          renderH = boxH;
                          renderW = boxH * portraitRatio;
                        }

                        return ClipRect(
                          child: OverflowBox(
                            maxWidth: renderW,
                            maxHeight: renderH,
                            child: SizedBox(
                              width: renderW,
                              height: renderH,
                              child: CameraPreview(controller!),
                            ),
                          ),
                        );
                      },
                    ),

                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.transparent,
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),

                    // Ellipse de guidage animée
                    Center(
                      child: AnimatedBuilder(
                        animation: pulseAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: pulseAnimation.value,
                          child: Container(
                            width: 180,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(110),
                              border: Border.all(
                                color: directionColor.withOpacity(0.85),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Coins décoratifs
                    ..._buildCorners(directionColor),

                    // Instruction bas
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Centrez votre visage dans l\'ellipse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: AppColors.primary,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.secondary,
                          strokeWidth: 2.5,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Initialisation de la caméra...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildCorners(Color color) {
    const size = 22.0;
    const thickness = 3.0;
    const margin = 18.0;

    Widget corner({
      required double? top,
      required double? bottom,
      required double? left,
      required double? right,
      required BorderRadius radius,
    }) =>
        Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border(
                top: top != null
                    ? BorderSide(color: color, width: thickness)
                    : BorderSide.none,
                bottom: bottom != null
                    ? BorderSide(color: color, width: thickness)
                    : BorderSide.none,
                left: left != null
                    ? BorderSide(color: color, width: thickness)
                    : BorderSide.none,
                right: right != null
                    ? BorderSide(color: color, width: thickness)
                    : BorderSide.none,
              ),
              borderRadius: radius,
            ),
          ),
        );

    return [
      corner(
          top: margin,
          bottom: null,
          left: margin,
          right: null,
          radius: const BorderRadius.only(
              topLeft: Radius.circular(6))),
      corner(
          top: margin,
          bottom: null,
          left: null,
          right: margin,
          radius: const BorderRadius.only(
              topRight: Radius.circular(6))),
      corner(
          top: null,
          bottom: margin,
          left: margin,
          right: null,
          radius: const BorderRadius.only(
              bottomLeft: Radius.circular(6))),
      corner(
          top: null,
          bottom: margin,
          left: null,
          right: margin,
          radius: const BorderRadius.only(
              bottomRight: Radius.circular(6))),
    ];
  }
}

// ── Bouton capturer / reprendre ──────────────────────────────
class _CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isPrimary;

  const _CaptureButton({
    required this.onPressed,
    required this.label,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.camera_alt_rounded, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: Color(0xFFDDD8CC), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Grille de photos capturées ───────────────────────────────
class _PhotosGrid extends StatelessWidget {
  final String? facePhotoPath;
  final File? frontFaceExtracted;
  final String? gauchePhotoPath;
  final String? droitePhotoPath;

  const _PhotosGrid({
    this.facePhotoPath,
    this.frontFaceExtracted,
    this.gauchePhotoPath,
    this.droitePhotoPath,
  });

  @override
  Widget build(BuildContext context) {
    final photos = <Map<String, dynamic>>[
      if (facePhotoPath != null)
        {'label': 'Face', 'path': facePhotoPath!, 'isFile': true},
      if (frontFaceExtracted != null)
        {'label': 'Visage extrait', 'file': frontFaceExtracted!, 'isFile': false},
      if (gauchePhotoPath != null)
        {'label': 'Gauche', 'path': gauchePhotoPath!, 'isFile': true},
      if (droitePhotoPath != null)
        {'label': 'Droite', 'path': droitePhotoPath!, 'isFile': true},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: photos.map((p) {
        final imageWidget = p['isFile'] as bool
            ? Image.file(File(p['path'] as String),
                width: 90, height: 90, fit: BoxFit.cover)
            : Image.file(p['file'] as File,
                width: 90, height: 90, fit: BoxFit.cover);

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageWidget,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              p['label'] as String,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],  
        );
      }).toList(),
    );
  }
}

// ── Label de section ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0A2342),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
}
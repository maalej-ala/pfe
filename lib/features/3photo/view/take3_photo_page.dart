// take3_photo_page.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/3photo/view_model/face_capture_view_model.dart';
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

  IconData _directionIcon(String direction) {
    if (direction.toLowerCase().contains('gauche')) return Icons.arrow_back_rounded;
    if (direction.toLowerCase().contains('droite')) return Icons.arrow_forward_rounded;
    return Icons.face_rounded;
  }

  Color _directionColor(String direction) {
    if (direction.toLowerCase().contains('gauche')) return const Color(0xFF1B6CA8);
    if (direction.toLowerCase().contains('droite')) return const Color(0xFF2E7D32);
    return Theme.of(context).colorScheme.secondary; // face → gold from theme
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;
    final controller = _viewModel.controller;
    final directionColor = _directionColor(state.faceDirection);

    final totalPhotos = [
      state.facePhotoPath,
      state.gauchePhotoPath,
      state.droitePhotoPath,
    ].where((p) => p != null).length;

    return Scaffold(
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
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
                        _ProgressSteps(total: 3, done: totalPhotos),
                        const SizedBox(height: 20),
                        _DirectionBanner(
                          direction: state.faceDirection,
                          icon: _directionIcon(state.faceDirection),
                          color: directionColor,
                        ),
                        const SizedBox(height: 16),
                        _CameraPreviewCard(
                          controller: controller,
                          pulseAnimation: _pulseAnimation,
                          directionColor: directionColor,
                        ),
                        const SizedBox(height: 20),
                        _CaptureButton(
                          onPressed: () async =>
                              _viewModel.capturePhotoForCurrentDirection(),
                          label: 'Prendre la photo',
                          isPrimary: true,
                        ),
                        const SizedBox(height: 12),
                        _CaptureButton(
                          onPressed: () async =>
                              _viewModel.capturePhotoForCurrentDirection(),
                          label: 'Reprendre cette photo',
                          isPrimary: false,
                        ),
                        const SizedBox(height: 24),
                        if (totalPhotos > 0) ...[
                          _SectionLabel(
                              label: 'Photos capturées ($totalPhotos/3)'),
                          const SizedBox(height: 12),
                          _PhotosGrid(
                            facePhotoPath: state.facePhotoPath,
                            frontFaceExtracted: state.frontFaceExtracted,
                            gauchePhotoPath: state.gauchePhotoPath,
                            droitePhotoPath: state.droitePhotoPath,
                          ),
                          const SizedBox(height: 24),
                        ],
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

// ── Progress steps ───────────────────────────────────────────
class _ProgressSteps extends StatelessWidget {
  final int total;
  final int done;
  const _ProgressSteps({required this.total, required this.done});

  static const _labels = ['Face', 'Gauche', 'Droite'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.06),
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
                              ? colorScheme.secondary
                              : isCurrent
                                  ? colorScheme.primary
                                  : const Color(0xFFF0EDE6),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color:
                                        colorScheme.primary.withOpacity(0.3),
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
                                  style: textTheme.labelSmall?.copyWith(
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
                        style: textTheme.labelSmall?.copyWith(
                          color: isDone
                              ? colorScheme.secondary
                              : isCurrent
                                  ? colorScheme.primary
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
                            ? colorScheme.secondary
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

// ── Direction banner ─────────────────────────────────────────
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
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
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

// ── Camera preview ───────────────────────────────────────────
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.18),
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
                    LayoutBuilder(builder: (context, constraints) {
                      final previewSize = controller!.value.previewSize!;
                      final sensorW = previewSize.width < previewSize.height
                          ? previewSize.width
                          : previewSize.height;
                      final sensorH = previewSize.width > previewSize.height
                          ? previewSize.width
                          : previewSize.height;
                      final portraitRatio = sensorW / sensorH;
                      final boxW = constraints.maxWidth;
                      final boxH = constraints.maxHeight;
                      double renderW, renderH;
                      if (boxW / boxH > portraitRatio) {
                        renderW = boxW;
                        renderH = boxW / portraitRatio;
                      } else {
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
                    }),
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
                    ..._buildCorners(directionColor),
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
                  color: colorScheme.primary,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: colorScheme.secondary,
                          strokeWidth: 2.5,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Initialisation de la caméra...',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
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
      double? top, double? bottom, double? left, double? right,
      required BorderRadius radius,
    }) =>
        Positioned(
          top: top, bottom: bottom, left: left, right: right,
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(
              border: Border(
                top: top != null ? BorderSide(color: color, width: thickness) : BorderSide.none,
                bottom: bottom != null ? BorderSide(color: color, width: thickness) : BorderSide.none,
                left: left != null ? BorderSide(color: color, width: thickness) : BorderSide.none,
                right: right != null ? BorderSide(color: color, width: thickness) : BorderSide.none,
              ),
              borderRadius: radius,
            ),
          ),
        );

    return [
      corner(top: margin, left: margin, radius: const BorderRadius.only(topLeft: Radius.circular(6))),
      corner(top: margin, right: margin, radius: const BorderRadius.only(topRight: Radius.circular(6))),
      corner(bottom: margin, left: margin, radius: const BorderRadius.only(bottomLeft: Radius.circular(6))),
      corner(bottom: margin, right: margin, radius: const BorderRadius.only(bottomRight: Radius.circular(6))),
    ];
  }
}

// ── Capture / retry button ───────────────────────────────────
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
      // Uses elevatedButtonTheme from AppTheme
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.camera_alt_rounded, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }

    // Uses outlinedButtonTheme from AppTheme
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text(label),
      ),
    );
  }
}

// ── Photos grid ──────────────────────────────────────────────
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
    final colorScheme = Theme.of(context).colorScheme;
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
                    color: colorScheme.secondary.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.1),
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
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF555555),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ── Section label ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: colorScheme.secondary,      // gold accent bar
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
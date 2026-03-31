// page_header.dart
import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const PageHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Back button + step badge ──────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // Subtle white-ish overlay regardless of theme
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: colorScheme.secondary.withOpacity(0.5)),
                ),
                child: Text(
                  'Étape $currentStep / $totalSteps',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Title + subtitle ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // titleLarge: white in light (on navy band),
              // uses theme color in dark (already light-colored)
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Progress bar ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.secondary),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}
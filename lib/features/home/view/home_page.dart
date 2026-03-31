// home_page.dart
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/identification/views/identification_page.dart';
import 'package:pfe_flutter/shared/app_colors.dart';
import 'package:pfe_flutter/shared/constantes.dart';
import '../view_models/home_view_model.dart';
import '../models/step_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = HomeViewModel();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // scaffoldBackgroundColor → AppColors.primary override for this page only
      backgroundColor: colorScheme.primary,
      body: Stack(
        children: [
          // Decorative circles — use theme colors
          Positioned(
            top: -80,
            right: -60,
            child: _circle(280, AppColors.darkBlue.withOpacity(0.6)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _circle(320, AppColors.darkBlue.withOpacity(0.4)),
          ),
          Positioned(
            top: 200,
            left: -40,
            child: _circle(160, colorScheme.secondary.withOpacity(0.15)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Logo row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppConstants.bankName,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Central illustration
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.secondary.withOpacity(0.3),
                            colorScheme.secondary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cardBackground,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.secondary.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.credit_card_rounded,
                            size: 60,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Title
                  Text(
                    "Votre banque,\npartout avec vous.",
                    style: textTheme.titleLarge?.copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    "Ouvrez votre compte bancaire en quelques minutes, 100% en ligne, sans vous déplacer.",
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Steps indicator
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vm.steps.length,
                      itemBuilder: (context, index) {
                        final step = vm.steps[index];
                        return Row(
                          children: [
                            StepDot(step: step),
                            if (index != vm.steps.length - 1)
                              const SizedBox(width: 40, child: StepLine()),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 44),

                  // CTA button — secondary (gold) background, primary text
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const IdentificationPage()),
                      ),
                      // Override theme: gold bg + navy text for this one button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ouvrir un compte',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Secondary link
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "J'ai déjà un compte →",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class StepDot extends StatelessWidget {
  final StepModel step;
  const StepDot({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: step.isActive ? colorScheme.secondary : AppColors.darkBlue,
            border: Border.all(
              color: colorScheme.secondary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              step.number,
              style: TextStyle(
                color: step.isActive
                    ? colorScheme.primary
                    : colorScheme.secondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          step.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.45),
              ),
        ),
      ],
    );
  }
}

class StepLine extends StatelessWidget {
  const StepLine({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 1,
        margin: const EdgeInsets.only(bottom: 16),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
      );
}
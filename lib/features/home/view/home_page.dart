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

    return Scaffold(
      backgroundColor: AppColors.primary,

      body: Stack(
        children: [

          /// decorative circles
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
            child: _circle(160, AppColors.secondary.withOpacity(0.15)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 24),

                  /// logo
                  Row(
                    children: [

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        AppConstants.bankName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  /// illustration centrale
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondary.withOpacity(0.3),
                            AppColors.secondary.withOpacity(0.05),
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
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.credit_card_rounded,
                            size: 60,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  /// titre
                 const Text( "Votre banque,\npartout avec vous.", 
                 style: TextStyle( 
                  color: Colors.white, 
                  fontSize: 34, 
                  fontWeight: FontWeight.bold, 
                  ), ), 
                  const SizedBox(height: 16), 
                  Text( "Ouvrez votre compte bancaire en quelques minutes, 100% en ligne, sans vous déplacer.", 
                  style: TextStyle( 
                    color: Colors.white.withOpacity(0.65), 
                    fontSize: 15, ), ),
                     const SizedBox(height: 40),

                  /// steps indicator
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
            const SizedBox(
              width: 40,
              child: StepLine(),
            ),
        ],
      );
    },
  ),
),
                  const SizedBox(height: 44),

                  /// bouton
                  SizedBox(
                    width: double.infinity,
                    height: 56,

                    child: ElevatedButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IdentificationPage(),
                          ),
                        );

                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.primary,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            'Ouvrir un compte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),

                          SizedBox(width: 10),

                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// secondary link
                  Center(
                    child: TextButton(
                      onPressed: () {},

                      child: Text(
                        "J'ai déjà un compte →",
                        style: TextStyle(
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

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class StepDot extends StatelessWidget {

  final StepModel step;

  const StepDot({super.key, required this.step});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Container(
          width: 28,
          height: 28,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: step.isActive
                ? AppColors.secondary
                : AppColors.darkBlue,

            border: Border.all(
              color: AppColors.secondary.withOpacity(0.4),
              width: 1.5,
            ),
          ),

          child: Center(
            child: Text(
              step.number,

              style: TextStyle(
                color: step.isActive
                    ? AppColors.primary
                    : AppColors.secondary,

                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          step.label,

          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class StepLine extends StatelessWidget {

  const StepLine({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 40, // largeur de la ligne
      height: 1,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.secondary.withOpacity(0.25),
    );
  }
}
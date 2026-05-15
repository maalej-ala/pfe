// verification_identite_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/choix_bancaire/views/choix_bancaire_page.dart';
import 'package:pfe_flutter/features/3photo/view/take3_photo_page.dart';
import 'package:pfe_flutter/features/TextRecognition/view/text_recognition_page.dart';
import 'package:pfe_flutter/features/verification_identite/models/verification_identite_model.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../view_models/verification_identite_view_model.dart';

class VerificationIdentitePage extends StatefulWidget {
  const VerificationIdentitePage({super.key});

  @override
  State<VerificationIdentitePage> createState() =>
      _VerificationIdentitePageState();
}

class _VerificationIdentitePageState extends State<VerificationIdentitePage> {
  late final VerificationIdentiteViewModel _viewModel;


  File? _photoVisageLive;

  @override
  void initState() {
    super.initState();
    _viewModel = VerificationIdentiteViewModel();
    _viewModel.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _viewModel.dispose();
    super.dispose();
  }




  Future<void> _ouvrirVerificationLive() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const Take3PhotoPage()),
    );
    if (result != null) {
      setState(() => _photoVisageLive = result);
      _viewModel.updateVerificationsPhotosCompleted(true);
    }
  }

  Future<void> _onSoumettre() async {
    final s = _viewModel.state;
    if (!s.isValid) {
      String msg = 'Veuillez compléter toutes les étapes.';
if (!s.verificationsPhotosCompleted)
        msg = 'Veuillez compléter la vérification vidéo.';
      else if (!s.confirmeSansAmericanite)
        msg = 'Veuillez confirmer la déclaration FATCA.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await _viewModel.submitVerification(
      photoVisageLive: _photoVisageLive,
    );

    if (!mounted) return;

    if (success) {
      // // ── Afficher le résultat OCR dans un bottom sheet ─────────────
      // final result = _viewModel.verificationResult;
      // if (result != null) {
      //   await showModalBottomSheet(
      //     context: context,
      //     isScrollControlled: true,
      //     backgroundColor: Colors.transparent,
      //     builder: (_) => _OcrResultBottomSheet(result: result),
      //   );
      // }

      // // ── Si identité vérifiée → continuer ─────────────────────────
      // if (!mounted) return;
      // if (result?.identiteVerifiee == true) {
        Navigator.push(
          context,
        MaterialPageRoute(builder: (_) => const ChoixBancairePage()),
        );
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ??
              'Erreur lors de l\'envoi. Vérifiez votre connexion.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;

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
                  title: "Vérification d'identité",
                  subtitle: 'Confirmez votre identité avec votre CIN',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            // Afficher le message d'erreur s'il y en a un
                            if (_viewModel.errorMessage != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _viewModel.errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      // ── 1. Informations CIN ───────────────────────
                      // _FormCard(
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const _SectionTitle(
                      //         icon: Icons.badge_outlined,
                      //         title: 'Informations CIN',
                      //       ),
                      //       const SizedBox(height: 16),
                      //       const _Label('Numéro de CIN'),
                      //       const SizedBox(height: 8),
                      //       _Input(
                      //         controller: _cinController,
                      //         hint: '8 chiffres',
                      //         icon: Icons.badge_outlined,
                      //         keyboardType: TextInputType.number,
                      //         inputFormatters: [
                      //           FilteringTextInputFormatter.digitsOnly,
                      //           LengthLimitingTextInputFormatter(8),
                      //         ],
                      //         onChanged: _viewModel.updateCin,
                      //       ),
                      //       const SizedBox(height: 16),
                      //       const _Label('Date d\'expiration CIN'),
                      //       const SizedBox(height: 8),
                      //       GestureDetector(
                      //         onTap: _selectDate,
                      //         child: AbsorbPointer(
                      //           child: _Input(
                      //             controller: _dateExpirationController,
                      //             hint: 'JJ/MM/AAAA',
                      //             icon: Icons.event_outlined,
                      //             suffixIcon: Icons.calendar_today_outlined,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                     // const SizedBox(height: 16),

                      // ── 2. Photos CIN ─────────────────────────────
                      // _FormCard(
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const _SectionTitle(
                      //         icon: Icons.photo_camera_outlined,
                      //         title: 'Photos de la CIN',
                      //       ),
                      //       const SizedBox(height: 16),
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: _StatusBox(
                      //               label: 'CIN Recto',
                      //               icon: Icons.flip_to_front_rounded,
                      //               isDone: state.hasCinRecto,
                      //               doneLabel: 'Scanné',
                      //               pendingLabel: 'Scanner',
                      //               onTap: _ouvrirScanCin,
                      //             ),
                      //           ),
                      //           const SizedBox(width: 12),
                      //           Expanded(
                      //             child: _StatusBox(
                      //               label: 'CIN Verso',
                      //               icon: Icons.flip_to_back_rounded,
                      //               isDone: state.hasCinVerso,
                      //               doneLabel: 'Confirmé',
                      //               pendingLabel: 'Confirmer',
                      //               onTap: () =>
                      //                   _viewModel.updateHasCinVerso(true),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      //const SizedBox(height: 16),

                      // ── 3. Vérification live ──────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.videocam_rounded,
                              title: 'Vérification en direct',
                            ),
                            const SizedBox(height: 16),
                            _LiveVerificationBox(
                              isDone: state.verificationsPhotosCompleted,
                              onTap: _ouvrirVerificationLive,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 4. Déclarations ───────────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.gavel_rounded,
                              title: 'Déclarations',
                            ),
                            const SizedBox(height: 16),
                            _DeclarationBox(
                              value: state.confirmeSansAmericanite,
                              onChanged:
                                  _viewModel.updateConfirmeSansAmericanite,
                              icon: Icons.gavel_rounded,
                              text:
                                  "Je confirme que je n'ai aucun indice d'américanité (non-soumis à FATCA)",
                              color: const Color(0xFF1B6CA8),
                            ),
                            const SizedBox(height: 12),
                            _DeclarationBox(
                              value: state.estClientAutreBanque,
                              onChanged: _viewModel.updateEstClientAutreBanque,
                              icon: Icons.account_balance_rounded,
                              text:
                                  "Je suis client(e) dans une autre banque",
                              color: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Bouton soumission ─────────────────────────
                      _viewModel.isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              text: 'Continuer',
                              onPressed: _onSoumettre,
                              enabled: state.isValid && !_viewModel.isLoading && !_viewModel.isSubmitting,
                            ),

                      const SizedBox(height: 32),
                    ],
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



// ════════════════════════════════════════════════════════════════════
// WIDGETS DE LA PAGE PRINCIPALE (inchangés)
// ════════════════════════════════════════════════════════════════════

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}




class _LiveVerificationBox extends StatelessWidget {
  final bool isDone;
  final VoidCallback onTap;
  const _LiveVerificationBox({required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final doneColor = colorScheme.secondary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDone
            ? doneColor.withOpacity(0.07)
            : colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? doneColor.withOpacity(0.5)
              : colorScheme.primary.withOpacity(0.15),
          width: isDone ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isDone
                ? Container(
                    key: const ValueKey('done'),
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: doneColor, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: doneColor.withOpacity(0.3), blurRadius: 12)],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 28),
                  )
                : Container(
                    key: const ValueKey('idle'),
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: colorScheme.primary.withOpacity(0.25),
                          blurRadius: 12)],
                    ),
                    child: Icon(Icons.videocam_rounded,
                        color: colorScheme.secondary, size: 28),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            isDone ? 'Vérification complétée !' : 'Vidéo de vérification en direct',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDone ? doneColor : null,
                  fontWeight: isDone ? FontWeight.bold : null,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            isDone
                ? 'Vos 3 photos ont été capturées avec succès'
                : 'Nous allons vous demander de prendre 3 photos face caméra',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDone
                      ? doneColor.withOpacity(0.8)
                      : colorScheme.primary,
                ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(
                  isDone ? Icons.refresh_rounded : Icons.camera_alt_outlined,
                  size: 18),
              label: Text(isDone ? 'Recommencer' : 'Lancer la vérification'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isDone ? doneColor : colorScheme.primary,
                    width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeclarationBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final IconData icon;
  final String text;
  final Color color;

  const _DeclarationBox({
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value
              ? color.withOpacity(0.06)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? color.withOpacity(0.4) : const Color(0xFFDDD8CC),
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF333333),
                        fontWeight:
                            value ? FontWeight.w600 : FontWeight.normal,
                      )),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );
}
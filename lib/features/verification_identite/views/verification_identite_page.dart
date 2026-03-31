// verification_identite_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/motDePasse/view/mot_de_passe_page.dart';
import 'package:pfe_flutter/features/3photo/view/take3_photo_page.dart';
import 'package:pfe_flutter/features/TextRecognition/view/text_recognition_page.dart';
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

class _VerificationIdentitePageState
    extends State<VerificationIdentitePage> {
  late final VerificationIdentiteViewModel _viewModel;
  final _cinController = TextEditingController();
  final _dateDelivranceController = TextEditingController();

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
    _cinController.dispose();
    _dateDelivranceController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: colorScheme.secondary,
            surface: colorScheme.primary,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _dateDelivranceController.text = formatted;
      _viewModel.updateDateDelivrance(formatted);
    }
  }

  void _onSoumettre() {
    if (!_viewModel.state.isValid) {
      String msg =
          'Veuillez compléter toutes les étapes de vérification.';
      final s = _viewModel.state;
      if (s.cin.length != 8)
        msg = 'Le numéro CIN doit contenir 8 chiffres.';
      else if (s.dateDelivrance.isEmpty)
        msg = 'Veuillez saisir la date de délivrance.';
      else if (!s.hasCinRecto || !s.hasCinVerso)
        msg = 'Veuillez télécharger les deux faces de votre CIN.';
      else if (!s.verificationsPhotosCompleted)
        msg = 'Veuillez compléter la vérification vidéo.';
      else if (!s.confirmeSansAmericanite)
        msg = 'Veuillez confirmer la déclaration FATCA.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg), backgroundColor: Colors.redAccent),
      );
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const MotDePassePage()));
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;
    final colorScheme = Theme.of(context).colorScheme;

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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // ── CIN Info ──────────────────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.badge_outlined,
                              title: 'Informations CIN',
                            ),
                            const SizedBox(height: 16),
                            const _Label('Numéro de CIN'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _cinController,
                              hint: '8 chiffres',
                              icon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              onChanged: _viewModel.updateCin,
                            ),
                            const SizedBox(height: 16),
                            const _Label('Date de délivrance CIN'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectDate,
                              child: AbsorbPointer(
                                child: _Input(
                                  controller: _dateDelivranceController,
                                  hint: 'JJ/MM/AAAA',
                                  icon: Icons.event_outlined,
                                  suffixIcon:
                                      Icons.calendar_today_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Photos CIN ────────────────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.photo_camera_outlined,
                              title: 'Photos de la CIN',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _PhotoUploadBox(
                                    label: 'CIN Recto',
                                    icon: Icons.flip_to_front_rounded,
                                    hasImage: state.hasCinRecto,
                                    onTap: () async {
                                      final result =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TextRecognitionPage(),
                                        ),
                                      );
                                      if (result != null &&
                                          result is String &&
                                          result.isNotEmpty) {
                                        _cinController.text = result;
                                        _viewModel.updateCin(result);
                                        _viewModel
                                            .updateHasCinRecto(true);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PhotoUploadBox(
                                    label: 'CIN Verso',
                                    icon: Icons.flip_to_back_rounded,
                                    hasImage: state.hasCinVerso,
                                    onTap: () => _viewModel
                                        .updateHasCinVerso(true),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Live verification ─────────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.videocam_rounded,
                              title: 'Vérification en direct',
                            ),
                            const SizedBox(height: 16),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: state.verificationsPhotosCompleted
                                    ? colorScheme.secondary
                                        .withOpacity(0.07)
                                    : colorScheme.primary
                                        .withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: state
                                          .verificationsPhotosCompleted
                                      ? colorScheme.secondary
                                          .withOpacity(0.4)
                                      : colorScheme.primary
                                          .withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: state
                                              .verificationsPhotosCompleted
                                          ? colorScheme.secondary
                                          : colorScheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withOpacity(0.25),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      state.verificationsPhotosCompleted
                                          ? Icons.check_rounded
                                          : Icons.videocam_rounded,
                                      color: state
                                              .verificationsPhotosCompleted
                                          ? Colors.white
                                          : colorScheme.secondary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.verificationsPhotosCompleted
                                        ? 'Vérification complétée !'
                                        : 'Vidéo de vérification en direct',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Nous allons vous demander de prendre 3 photos face caméra pour confirmer votre identité',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (!state
                                      .verificationsPhotosCompleted)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const Take3PhotoPage(),
                                            ),
                                          );
                                          _viewModel
                                              .updateVerificationsPhotosCompleted(
                                                  true);
                                        },
                                        icon: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 18),
                                        label: const Text(
                                            'Lancer la vérification'),
                                        // Tighten border to primary navy
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: colorScheme.primary,
                                              width: 1.5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12)),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Declarations ──────────────────────────────
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
                              onChanged: _viewModel
                                  .updateConfirmeSansAmericanite,
                              icon: Icons.gavel_rounded,
                              text:
                                  "Je confirme que je n'ai aucun indice d'américanité (non-soumis à FATCA)",
                              color: const Color(0xFF1B6CA8),
                            ),
                            const SizedBox(height: 12),
                            _DeclarationBox(
                              value: state.estClientAutreBanque,
                              onChanged:
                                  _viewModel.updateEstClientAutreBanque,
                              icon: Icons.account_balance_rounded,
                              text:
                                  "Je suis client(e) dans une autre banque",
                              color: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      PrimaryButton(
                        text: 'Continuer',
                        onPressed: _onSoumettre,
                        enabled: state.isValid,
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

// ── Shared card ──────────────────────────────────────────────
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

// ── Section title with icon badge ────────────────────────────
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

// ── Field label ──────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelMedium);
}

// ── Text input ───────────────────────────────────────────────
class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _Input({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    final iconSize = Theme.of(context).iconTheme.size;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: iconSize, color: iconColor),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 17, color: iconColor)
            : null,
      ),
    );
  }
}

// ── Photo upload box ─────────────────────────────────────────
class _PhotoUploadBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool hasImage;
  final VoidCallback onTap;

  const _PhotoUploadBox({
    required this.label,
    required this.icon,
    required this.hasImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).iconTheme.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: hasImage
              ? colorScheme.primary.withOpacity(0.05)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasImage
                ? colorScheme.secondary
                : const Color(0xFFDDD8CC),
            width: hasImage ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasImage ? Icons.check_circle_outline : icon,
              color: hasImage ? colorScheme.secondary : iconColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: hasImage
                        ? colorScheme.primary
                        : const Color(0xFF888888),
                    fontWeight: hasImage
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
            if (!hasImage)
              Text(
                'Appuyer pour télécharger',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Declaration checkbox box ─────────────────────────────────
// Note: uses a custom per-item color (blue/green), NOT the global
// checkboxTheme, because each declaration has its own accent color.
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
            color:
                value ? color.withOpacity(0.4) : const Color(0xFFDDD8CC),
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF333333),
                      fontWeight:
                          value ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            // Per-item color checkbox — intentionally overrides theme
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: BorderSide(
                  color: color.withOpacity(0.5), width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );
}
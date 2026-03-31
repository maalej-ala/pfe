// mot_de_passe_page.dart
import 'package:flutter/material.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../models/mot_de_passe_state.dart';
import '../view_models/mot_de_passe_view_model.dart';

class MotDePassePage extends StatefulWidget {
  const MotDePassePage({super.key});

  @override
  State<MotDePassePage> createState() => _MotDePassePageState();
}

class _MotDePassePageState extends State<MotDePassePage> {
  late final MotDePasseViewModel _viewModel;
  final _mdpController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = MotDePasseViewModel();
    _viewModel.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _mdpController.dispose();
    _confirmController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onSoumettre() async {
    final success = await _viewModel.soumettre();
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, _viewModel.state.motDePasse);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de continuer.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;

    return Scaffold(
      // scaffoldBackgroundColor from AppTheme
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                PageHeader(
                  currentStep: 7,
                  totalSteps: 8,
                  title: 'Mot de passe',
                  subtitle: 'Créez un mot de passe sécurisé pour votre compte',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // ── Password creation card ──────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.lock_outline_rounded,
                              title: 'Créer votre mot de passe',
                            ),
                            const SizedBox(height: 20),

                            const _Label('Mot de passe'),
                            const SizedBox(height: 8),
                            _PasswordInput(
                              controller: _mdpController,
                              hint: 'Minimum 8 caractères',
                              isVisible: state.motDePasseVisible,
                              onChanged: _viewModel.updateMotDePasse,
                              onToggleVisibility:
                                  _viewModel.toggleMotDePasseVisible,
                            ),
                            const SizedBox(height: 12),

                            if (state.motDePasse.isNotEmpty)
                              _StrengthBar(strength: state.strength),

                            const SizedBox(height: 20),

                            const _Label('Confirmer le mot de passe'),
                            const SizedBox(height: 8),
                            _PasswordInput(
                              controller: _confirmController,
                              hint: 'Répétez votre mot de passe',
                              isVisible: state.confirmationVisible,
                              onChanged: _viewModel.updateConfirmation,
                              onToggleVisibility:
                                  _viewModel.toggleConfirmationVisible,
                              hasError: state.isConfirmationError,
                              isSuccess: state.isConfirmationMatch,
                            ),

                            if (state.isConfirmationError) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 14, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Les mots de passe ne correspondent pas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.redAccent,
                                          height: 1,
                                        ),
                                  ),
                                ],
                              ),
                            ],

                            if (state.isConfirmationMatch) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 14, color: Colors.green.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Les mots de passe correspondent',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.green.shade600,
                                          height: 1,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Criteria card ───────────────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.checklist_rounded,
                              title: 'Critères de sécurité',
                            ),
                            const SizedBox(height: 16),
                            _Criterion(
                                label: 'Au moins 8 caractères',
                                met: state.hasMinLength),
                            _Criterion(
                                label: 'Une lettre majuscule (A–Z)',
                                met: state.hasUppercase),
                            _Criterion(
                                label: 'Une lettre minuscule (a–z)',
                                met: state.hasLowercase),
                            _Criterion(
                                label: 'Un chiffre (0–9)',
                                met: state.hasDigit),
                            _Criterion(
                                label: r'Un caractère spécial (!@#$...)',
                                met: state.hasSpecial),
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

// ── Password field ───────────────────────────────────────────
class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isVisible;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;
  final bool hasError;
  final bool isSuccess;

  const _PasswordInput({
    required this.controller,
    required this.hint,
    required this.isVisible,
    required this.onChanged,
    required this.onToggleVisibility,
    this.hasError = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;

    // Semantic border color: error → red, success → green, default → theme
    Color borderColor = const Color(0xFFE5E0D5);
    if (hasError) borderColor = Colors.redAccent;
    if (isSuccess) borderColor = Colors.green;

    Color? fillColor = const Color(0xFFF9F8F5);
    if (hasError) fillColor = Colors.red.withOpacity(0.03);
    if (isSuccess) fillColor = Colors.green.withOpacity(0.03);

    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            Icon(Icons.lock_outline, size: 19, color: iconColor),
        suffixIcon: GestureDetector(
          onTap: onToggleVisibility,
          child: Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 19,
            color: iconColor,
          ),
        ),
        // Override theme fill/borders only for error/success states
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError
                ? Colors.redAccent
                : isSuccess
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Strength bar ─────────────────────────────────────────────
class _StrengthBar extends StatelessWidget {
  final PasswordStrength strength;
  const _StrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final (label, color, segments) = switch (strength) {
      PasswordStrength.weak => ('Faible', Colors.redAccent, 1),
      PasswordStrength.medium => ('Moyen', Colors.orange, 2),
      PasswordStrength.strong => ('Fort', Colors.green, 3),
      _ => ('', Colors.grey, 0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                height: 5,
                decoration: BoxDecoration(
                  color: i < segments ? color : const Color(0xFFE5E0D5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              strength == PasswordStrength.strong ||
                      strength == PasswordStrength.medium
                  ? Icons.shield_outlined
                  : Icons.warning_amber_outlined,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              'Mot de passe $label',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Single criterion row ─────────────────────────────────────
class _Criterion extends StatelessWidget {
  final String label;
  final bool met;
  const _Criterion({required this.label, required this.met});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: met
                    ? Colors.green.withOpacity(0.12)
                    : const Color(0xFFF0EEE9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: met ? Colors.green : const Color(0xFFDDD8CC),
                  width: 1.5,
                ),
              ),
              child: Icon(
                met ? Icons.check : Icons.remove,
                size: 13,
                color: met ? Colors.green : const Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: met
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFF888888),
                    fontWeight:
                        met ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      );
}
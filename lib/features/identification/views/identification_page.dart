// identification_page.dart
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pfe_flutter/features/adresse/views/address_page.dart';
import 'package:pfe_flutter/features/identification/view_model/identification_view_model.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({super.key});

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  late final IdentificationViewModel _viewModel;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = IdentificationViewModel();
    _viewModel.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _nomController.dispose();
    _prenomController.dispose();
    _telController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colorScheme.secondary,
              surface: colorScheme.primary,
              onSurface: Colors.white,
            ),
//             textButtonTheme: TextButtonThemeData(
//   style: TextButton.styleFrom(
//     textStyle: const TextStyle(
//       fontSize: 24,               // taille du texte
//       fontWeight: FontWeight.bold, // texte en gras
//     ),
//     padding: const EdgeInsets.symmetric(
//       horizontal: 24,
//       vertical: 12,
//     ), // padding du bouton
//   ),
// ),
        ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _dateController.text = formatted;
      _viewModel.updateDateNaissance(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Uses scaffoldBackgroundColor from AppTheme automatically
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                PageHeader(
                  currentStep: 1,
                  totalSteps: 8,
                  title: 'Identification',
                  subtitle: 'Veuillez renseigner vos informations personnelles',
                  onBack: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(text: 'Civilité'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _CiviliteChip(
                                label: 'M.',
                                selected: state.civilite == 'M.',
                                onTap: () => _viewModel.updateCivilite('M.'),
                              ),
                              const SizedBox(width: 12),
                              _CiviliteChip(
                                label: 'Mme',
                                selected: state.civilite == 'Mme',
                                onTap: () => _viewModel.updateCivilite('Mme'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          _SectionLabel(text: 'Nom'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _nomController,
                            hint: 'Votre nom de famille',
                            icon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.name,
                            onChanged: _viewModel.updateNom,
                          ),

                          const SizedBox(height: 20),

                          _SectionLabel(text: 'Prénom'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _prenomController,
                            hint: 'Votre prénom',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.name,
                            onChanged: _viewModel.updatePrenom,
                          ),

                          const SizedBox(height: 20),

                          _SectionLabel(text: 'Numéro de téléphone'),
                          const SizedBox(height: 8),

IntlPhoneField(
  controller: _telController,
  initialCountryCode: 'TN',
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    hintText: 'Votre numéro de téléphone',
    prefixIcon: const Icon(Icons.phone_outlined),
    // Utiliser la même couleur et le même style que les autres champs
    filled: true,
    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
    contentPadding: Theme.of(context).inputDecorationTheme.contentPadding,
    border: Theme.of(context).inputDecorationTheme.border,
    enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
    focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
  ),
  onChanged: (phone) {
    _viewModel.updatePhone(
      phone.completeNumber,
      phone.countryCode,
      phone.number,
    );
  },
),

                          _SectionLabel(text: 'Adresse e-mail'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _emailController,
                            hint: 'exemple@email.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: _viewModel.updateEmail,
                          ),

                          const SizedBox(height: 20),

                          _SectionLabel(text: 'Date de naissance'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: _InputField(
                                controller: _dateController,
                                hint: 'JJ/MM/AAAA',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.datetime,
                                suffixIcon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Mentions légales
                          _LegalCheckbox(
                            accepted: state.accepteMentions,
                            onChanged: _viewModel.updateAccepteMentions,
                          ),

                          const SizedBox(height: 32),

                          PrimaryButton(
                            text: 'Continuer',
                            enabled: state.accepteMentions,
                            onPressed: state.accepteMentions
    ? () async {
        try {
         // await _viewModel.submitIdentification(); // ✅ ENVOI BACKEND

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdressePage(),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      }
    : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
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
    // Uses labelMedium from AppTheme
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    final iconSize = Theme.of(context).iconTheme.size;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      // Uses bodyMedium from AppTheme
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        // Uses inputDecorationTheme automatically; only widget-specific
        // overrides go here (the icons, which vary per field)
        prefixIcon: Icon(icon, size: iconSize, color: iconColor),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 18, color: iconColor)
            : null,
      ),
    );
  }
}

class _CiviliteChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CiviliteChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          // selected → primary (navy), unselected → theme background
          color: selected ? colorScheme.primary : const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : const Color(0xFFDDD8CC),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            // selected → white, unselected → subtle grey
            color: selected ? colorScheme.onPrimary : const Color(0xFF666666),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Extracted widget so build() stays clean
class _LegalCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;

  const _LegalCheckbox({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bodySmall = Theme.of(context).textTheme.bodySmall!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Uses scaffold background color for the inner box
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accepted
              ? colorScheme.secondary.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: accepted,
              // Styling comes entirely from checkboxTheme in AppTheme
              onChanged: (val) => onChanged(val ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                // Base style from bodySmall
                style: bodySmall,
                children: [
                  const TextSpan(text: "J'accepte les "),
                  TextSpan(
                    text: 'mentions légales relatives à la protection des données personnelles',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      fontSize: bodySmall.fontSize,
                      height: bodySmall.height,
                    ),
                  ),
                  const TextSpan(text: ' conformément au RGPD.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
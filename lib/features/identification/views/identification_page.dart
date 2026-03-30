import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/adresse/views/address_page.dart';
import 'package:pfe_flutter/features/identification/view_model/identification_view_model.dart';
import 'package:pfe_flutter/shared/app_colors.dart';
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18 )),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.secondary,
              surface: AppColors.primary,
              onSurface: Colors.white,
            ),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Stack(
        children: [
          // Bande haute navy
          HeaderBand(),

          SafeArea(
            child: Column(
              children: [
                // AppBar personnalisée
PageHeader(
        currentStep: 1,
        totalSteps: 8,
        title: 'Identification',
        subtitle: 'Veuillez renseigner vos informations personnelles',
        onBack: () => Navigator.pop(context),
      ),

                const SizedBox(height: 20),

                // Formulaire
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
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
                          _InputField(
                            controller: _telController,
                            hint: '+216 XX XX XX XX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            onChanged: _viewModel.updateTel,
                          ),

                          const SizedBox(height: 20),

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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3EE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: state.accepteMentions
                                    ? AppColors.secondary.withOpacity(0.5)
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
                                    value: state.accepteMentions,
                                    onChanged: (val) =>
                                        _viewModel.updateAccepteMentions(val ?? false),
                                    activeColor: AppColors.secondary,
                                    checkColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFBBB49A),
                                      width: 1.5,
                                    ),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        color: Color(0xFF555555),
                                        fontSize: 12.5,
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(text: 'J\'accepte les '),
                                        TextSpan(
                                          text:
                                              'mentions légales relatives à la protection des données personnelles',
                                          style: TextStyle(
                                            color: Color(0xFFC9A84C),
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        TextSpan(text: ' conformément au RGPD.'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Bouton Continuer
PrimaryButton(
  text: 'Continuer',
  enabled: state.accepteMentions,
  onPressed: state.accepteMentions
      ? () async {
          try {
            // await _viewModel.submitIdentification(); // ✅ utiliser le bon nom
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdressePage()),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e')),
            );
          }
        }
      : null, // Si pas accepté, bouton désactivé
)
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

// ====================== WIDGETS INTERNES (inchangés sauf _InputField) ======================

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0A2342),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final ValueChanged<String>? onChanged;   // ← AJOUTÉ pour le ViewModel

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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,                    // ← Connexion au ViewModel
      style: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF0A2342),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, size: 19, color: const Color(0xFF8899AA)),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 18, color: const Color(0xFF8899AA))
            : null,
        filled: true,
        fillColor: const Color(0xFFF9F8F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E0D5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E0D5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A2342) : const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0A2342) : const Color(0xFFDDD8CC),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF666666),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
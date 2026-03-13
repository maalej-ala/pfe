import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/adresse/view_models/address_view_model.dart';
import 'package:pfe_flutter/features/situation_personnelle/views/situation_personnelle_page.dart';
import 'package:pfe_flutter/shared/app_colors.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';

class AdressePage extends StatefulWidget {
  const AdressePage({super.key});

  @override
  State<AdressePage> createState() => _AdressePageState();
}

class _AdressePageState extends State<AdressePage> {
  late final AdresseViewModel _viewModel;

  final _adresseController = TextEditingController();
  final _codePostalController = TextEditingController();

 

  @override
  void initState() {
    super.initState();
    _viewModel = AdresseViewModel();
    _viewModel.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _adresseController.dispose();
    _codePostalController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onContinuer() {
    final state = _viewModel.state;
    if (!state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // Navigation vers la page suivante avec les données
    Navigator.push(context, MaterialPageRoute(builder: (_) => SituationPersonnellePage()));
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Stack(
        children: [
          // Header background
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                PageHeader(currentStep: 2, totalSteps: 8, title: 'Adresse', subtitle: 'Renseignez votre adresse de résidence'),
                const SizedBox(height: 24),

                // Form
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Adresse
                            _Label('Adresse complète'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _adresseController,
                              hint: 'N° rue, rue, immeuble...',
                              icon: Icons.home_outlined,
                              onChanged: _viewModel.updateAdresse,
                            ),
                            const SizedBox(height: 20),

                            // Pays
                            _Label('Pays'),
                            const SizedBox(height: 8),
                            _DropdownField(
                              value: state.pays,
                              items: _viewModel.pays,
                              hint: 'Sélectionner le pays',
                              icon: Icons.flag_outlined,
                              onChanged: _viewModel.updatePays,
                            ),
                            const SizedBox(height: 20),

                            // Gouvernorat
                            _Label('Gouvernorat'),
                            const SizedBox(height: 8),
                            _DropdownField(
                              value: state.gouvernorat,
                              items: _viewModel.gouvernorats,
                              hint: 'Sélectionner le gouvernorat',
                              icon: Icons.map_outlined,
                              onChanged: _viewModel.updateGouvernorat,
                            ),
                            const SizedBox(height: 20),

                            // Code postal
                            _Label('Code postal'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _codePostalController,
                              hint: 'Ex: 1001',
                              icon: Icons.local_post_office_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: _viewModel.updateCodePostal,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Bouton Continuer
                      PrimaryButton(text:'Continuer', onPressed: _onContinuer, enabled: state.isValid),
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

// ====================== WIDGETS PRIVÉS ======================





class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0A2342),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _Input({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF0A2342),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5),
          prefixIcon: Icon(icon, size: 19, color: const Color(0xFF8899AA)),
          filled: true,
          fillColor: const Color(0xFFF9F8F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E0D5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E0D5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
          ),
        ),
      );
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F8F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E0D5)),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 19, color: const Color(0xFF8899AA)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          ),
          hint: Text(hint, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5)),
          style: const TextStyle(
            color: Color(0xFF0A2342),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8899AA)),
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
      );
}
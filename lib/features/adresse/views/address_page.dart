// address_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/adresse/view_models/address_view_model.dart';
import 'package:pfe_flutter/features/situation_personnelle/views/situation_personnelle_page.dart';
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
    if (!_viewModel.state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => SituationPersonnellePage()));
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
                  currentStep: 2,
                  totalSteps: 8,
                  title: 'Adresse',
                  subtitle: 'Renseignez votre adresse de résidence',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Adresse complète'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _adresseController,
                              hint: 'N° rue, rue, immeuble...',
                              icon: Icons.home_outlined,
                              onChanged: _viewModel.updateAdresse,
                            ),
                            const SizedBox(height: 20),
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
                            _Label('Code postal'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _codePostalController,
                              hint: 'Ex: 1001',
                              icon: Icons.local_post_office_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: _viewModel.updateCodePostal,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: 'Continuer',
                        onPressed: _onContinuer,
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

// ── Shared card shell ────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,           // white from theme
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

// ── Section label ────────────────────────────────────────────
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
        // All border/fill comes from inputDecorationTheme
      ),
    );
  }
}

// ── Dropdown ─────────────────────────────────────────────────
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E0D5)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 19, color: iconColor),
          border: InputBorder.none,
          // Override theme padding slightly for dropdown alignment
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        ),
        hint: Text(hint, style: theme.inputDecorationTheme.hintStyle),
        style: theme.textTheme.bodyMedium,
        dropdownColor: theme.colorScheme.surface,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: iconColor),
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }
}
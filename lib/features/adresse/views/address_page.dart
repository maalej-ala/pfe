import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/adresse/view_models/address_view_model.dart';
import 'package:pfe_flutter/features/situation_personnelle/views/situation_personnelle_page.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';

class AdressePage extends StatefulWidget {
  final String? initialCountryIso;

const AdressePage({super.key, this.initialCountryIso});

  @override
  State<AdressePage> createState() => _AdressePageState();
}

class _AdressePageState extends State<AdressePage> {
  late final AdresseViewModel _viewModel;
  final _adresseController    = TextEditingController();
  final _codePostalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = AdresseViewModel();
if (widget.initialCountryIso != null) {
    _viewModel.setCountryFromIso(widget.initialCountryIso!);
  }

  _viewModel.addListener(_updateUI);  }

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

Future<void> _onContinuer() async {
    if (!_viewModel.state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
      //  await _viewModel.submitAdresse(); // ✅ envoi backend

    Navigator.push(
        context, MaterialPageRoute(builder: (_) => SituationPersonnellePage( 
          currency: _viewModel.state.currency, // ✅ passe la currency
)));
  }

  @override
  Widget build(BuildContext context) {
    final state      = _viewModel.state;
    final countries  = _viewModel.allCountries;
    final states     = _viewModel.statesOfCountry;
    final isLoading  = countries.isEmpty;

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
                  child: isLoading
                      // ── Loading state while package data is parsed ──
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _FormCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Adresse ──────────────────────────
                                  _Label('Adresse complète'),
                                  const SizedBox(height: 8),
                                  _Input(
                                    controller: _adresseController,
                                    hint: 'N° rue, rue, immeuble...',
                                    icon: Icons.home_outlined,
                                    onChanged: _viewModel.updateAdresse,
                                  ),
                                  const SizedBox(height: 20),

                                  // ── Pays ─────────────────────────────
                                  _Label('Pays'),
                                  const SizedBox(height: 8),
                                  _CountryDropdown(
                                    countries: countries,
                                    selectedIso: state.paysIso,
                                    onChanged: _viewModel.updatePays,
                                  ),
                                  const SizedBox(height: 20),

                                  // ── État / Gouvernorat ────────────────
                                  _Label('Gouvernorat / État'),
                                  const SizedBox(height: 8),
                                  _StateDropdown(
                                    states: states,
                                    selectedName: state.gouvernorat,
                                    onChanged: _viewModel.updateGouvernorat,
                                  ),
                                  const SizedBox(height: 20),

                                  // ── Code postal ───────────────────────
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

// ═══════════════════════════════════════════════════════════════
//  PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════

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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelMedium);
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
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    final iconSize  = Theme.of(context).iconTheme.size;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

// ── Country dropdown with flag emoji ─────────────────────────
class _CountryDropdown extends StatelessWidget {
  final List<csc.Country> countries;
  final String? selectedIso;
  final ValueChanged<csc.Country> onChanged;

  const _CountryDropdown({
    required this.countries,
    required this.selectedIso,
    required this.onChanged,
  });

  /// ISO code → flag emoji  (e.g. "TN" → 🇹🇳)
  String _flag(String iso) {
    return iso.toUpperCase().split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) + 0x1F1A5);
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final iconColor = theme.iconTheme.color;

    // Find the currently selected Country object
    final selected = countries.isEmpty
        ? null
        : countries.firstWhere(
            (c) => c.isoCode == selectedIso,
            orElse: () => countries.first,
          );

    return Container(
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF243447)
              : const Color(0xFFE5E0D5),
        ),
      ),
      child: DropdownButtonFormField<csc.Country>(
        value: selected,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.flag_outlined, size: 19, color: iconColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        ),
        hint: Text('Sélectionner le pays',
            style: theme.inputDecorationTheme.hintStyle),
        style: theme.textTheme.bodyMedium,
        dropdownColor: theme.colorScheme.surface,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: iconColor),
        onChanged: (c) {
          if (c != null) onChanged(c);
        },
        selectedItemBuilder: (context) => countries
            .map((c) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_flag(c.isoCode)}  ${c.name}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ))
            .toList(),
        items: countries
            .map((c) => DropdownMenuItem<csc.Country>(
                  value: c,
                  child: Text(
                    '${_flag(c.isoCode)}  ${c.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── State / Gouvernorat dropdown ──────────────────────────────
class _StateDropdown extends StatelessWidget {
  final List<csc.State> states;
  final String? selectedName;
  final ValueChanged<String?> onChanged;

  const _StateDropdown({
    required this.states,
    required this.selectedName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final iconColor  = theme.iconTheme.color;

    if (states.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF243447)
                : const Color(0xFFE5E0D5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.map_outlined, size: 19, color: iconColor),
            const SizedBox(width: 12),
            Text(
              'Aucun gouvernorat disponible',
              style: theme.inputDecorationTheme.hintStyle,
            ),
          ],
        ),
      );
    }

    // Validate selected against current list
    final validSelected = states.any((s) => s.name == selectedName)
        ? selectedName
        : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF243447)
              : const Color(0xFFE5E0D5),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: validSelected,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.map_outlined, size: 19, color: iconColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        ),
        hint: Text('Sélectionner le gouvernorat',
            style: theme.inputDecorationTheme.hintStyle),
        style: theme.textTheme.bodyMedium,
        dropdownColor: theme.colorScheme.surface,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: iconColor),
        onChanged: onChanged,
        items: states
            .map((s) => DropdownMenuItem<String>(
                  value: s.name,
                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
      ),
    );
  }
}
// choix_bancaire_page.dart
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/verification_identite/views/verification_identite_page.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../view_models/choix_bancaire_view_model.dart';

class ChoixBancairePage extends StatefulWidget {
  const ChoixBancairePage({super.key});

  @override
  State<ChoixBancairePage> createState() => _ChoixBancairePageState();
}

class _ChoixBancairePageState extends State<ChoixBancairePage> {
  late final ChoixBancaireViewModel _viewModel;

  final List<String> _agences = [
    'Tunis Centre-Ville', 'Tunis Lafayette', 'Ariana', 'Ben Arous',
    'Sousse Centre', 'Sfax', 'Monastir', 'Nabeul', 'Bizerte',
  ];

  final List<Map<String, dynamic>> _typesCarte = [
    {'nom': 'Carte Classique', 'desc': 'Gratuite – Retrait & paiement local', 'icon': Icons.credit_card},
    {'nom': 'Carte Gold', 'desc': 'Paiement international & avantages', 'icon': Icons.star_rounded},
    {'nom': 'Carte Platinum', 'desc': 'Premium – Plafonds élevés & services VIP', 'icon': Icons.diamond_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ChoixBancaireViewModel();
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

  void _onContinuer() {
    if (!_viewModel.state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une agence et un type de carte.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const VerificationIdentitePage()));
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
                  currentStep: 5,
                  totalSteps: 8,
                  title: 'Choix bancaire',
                  subtitle: 'Choisissez votre agence et type de carte',
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
                            const _Label('Choisir une agence'),
                            const SizedBox(height: 8),
                            _DropdownField(
                              value: state.agence,
                              items: _agences,
                              hint: 'Agence la plus proche',
                              icon: Icons.location_city_outlined,
                              onChanged: _viewModel.updateAgence,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label('Type de carte bancaire'),
                            const SizedBox(height: 16),
                            ..._typesCarte.map((carte) => _CarteOption(
                                  nom: carte['nom'],
                                  desc: carte['desc'],
                                  icon: carte['icon'],
                                  selected: state.typeCarte == carte['nom'],
                                  onTap: () =>
                                      _viewModel.updateTypeCarte(carte['nom']),
                                )),
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

// ── Section label ────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelMedium);
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

// ── Carte option ─────────────────────────────────────────────
class _CarteOption extends StatelessWidget {
  final String nom;
  final String desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CarteOption({
    required this.nom,
    required this.desc,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : const Color(0xFFF9F8F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colorScheme.secondary : const Color(0xFFE5E0D5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.secondary.withOpacity(0.2)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? colorScheme.secondary : colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    desc,
                    style: textTheme.labelSmall?.copyWith(
                      color: selected
                          ? Colors.white60
                          : const Color(0xFF888888),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: colorScheme.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}
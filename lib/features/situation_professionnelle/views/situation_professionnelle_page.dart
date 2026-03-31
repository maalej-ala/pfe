// situation_professionnelle_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/choix_bancaire/views/choix_bancaire_page.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../view_models/situation_professionnelle_view_model.dart';

class SituationProfessionnellePage extends StatefulWidget {
  const SituationProfessionnellePage({super.key});

  @override
  State<SituationProfessionnellePage> createState() =>
      _SituationProfessionnellePageState();
}

class _SituationProfessionnellePageState
    extends State<SituationProfessionnellePage> {
  late final SituationProfessionnelleViewModel _viewModel;
  final _revenuController = TextEditingController();

  final List<String> _categoriesSocioPro = [
    'Salarié du secteur privé',
    'Fonctionnaire / Salarié du secteur public',
    'Profession libérale',
    'Commerçant / Artisan',
    "Chef d'entreprise",
    'Retraité(e)',
    'Étudiant(e)',
    'Sans emploi',
  ];

  final List<String> _naturesActivite = [
    'Activité principale',
    'Activité secondaire',
    'Retraite',
    'Rente',
  ];

  final List<String> _secteursActivite = [
    'Agriculture', 'Industrie', 'Commerce', 'Services', 'Administration',
    'Santé', 'Éducation', 'Tourisme', 'Finance / Banque', 'Immobilier',
    'Transport / Logistique', 'Technologies / IT', 'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = SituationProfessionnelleViewModel();
    _viewModel.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _revenuController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onContinuer() {
    if (!_viewModel.state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez remplir tous les champs obligatoires.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ChoixBancairePage()));
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
                  currentStep: 4,
                  totalSteps: 8,
                  title: 'Situation professionnelle',
                  subtitle: "CSP, revenus & secteur d'activité",
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
                            const _Label(
                                'Catégorie socio-professionnelle'),
                            const SizedBox(height: 8),
                            _DropdownField(
                              value: state.categorieSocioPro,
                              items: _categoriesSocioPro,
                              hint: 'Sélectionner votre catégorie',
                              icon: Icons.work_outline_rounded,
                              onChanged:
                                  _viewModel.updateCategorieSocioPro,
                              isExpanded: true,
                            ),
                            const SizedBox(height: 20),

                            const _Label('Revenu net mensuel (TND)'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _revenuController,
                              hint: 'Ex: 2500',
                              icon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: _viewModel.updateRevenu,
                            ),
                            const SizedBox(height: 20),

                            const _Label("Nature de l'activité"),
                            const SizedBox(height: 8),
                            _DropdownField(
                              value: state.natureActivite,
                              items: _naturesActivite,
                              hint: 'Sélectionner la nature',
                              icon: Icons.category_outlined,
                              onChanged: _viewModel.updateNatureActivite,
                            ),
                            const SizedBox(height: 20),

                            const _Label("Secteur d'activité"),
                            const SizedBox(height: 8),
                            _DropdownField(
                              value: state.secteurActivite,
                              items: _secteursActivite,
                              hint: 'Sélectionner le secteur',
                              icon: Icons.business_outlined,
                              onChanged:
                                  _viewModel.updateSecteurActivite,
                              isExpanded: true,
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
  final bool isExpanded;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.isExpanded = false,
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
        isExpanded: isExpanded,
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
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ))
            .toList(),
      ),
    );
  }
}
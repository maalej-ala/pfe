import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/situation_professionnelle/views/situation_professionnelle_page.dart';
import 'package:pfe_flutter/shared/app_colors.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../view_models/situation_personnelle_view_model.dart';

class SituationPersonnellePage extends StatefulWidget {
  const SituationPersonnellePage({super.key});

  @override
  State<SituationPersonnellePage> createState() => _SituationPersonnellePageState();
}

class _SituationPersonnellePageState extends State<SituationPersonnellePage> {
  late final SituationPersonnelleViewModel _viewModel;

  final List<String> _nationalites = [
    'Tunisienne', 'Française', 'Algérienne', 'Marocaine', 'Libyenne', 'Autre',
  ];

  final List<String> _statutsCivils = [
    'Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf / Veuve',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = SituationPersonnelleViewModel();
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
          content: Text('Veuillez remplir tous les champs obligatoires.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SituationProfessionnellePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                // shared widget header
                PageHeader(currentStep: 3, totalSteps: 8, title: 'Situation personnelle', subtitle: 'Nationalité, statut civil et situation familiale', onBack: () => Navigator.pop(context)),
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
                            // Nationalité
                            const _Label('Nationalité'),
                            const SizedBox(height: 8),
                            _DropdownField(
                              value: state.nationalite,
                              items: _nationalites,
                              hint: 'Sélectionner la nationalité',
                              icon: Icons.public_outlined,
                              onChanged: _viewModel.updateNationalite,
                            ),
                            const SizedBox(height: 24),

                            // Statut civil
                            const _Label('Statut civil'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _statutsCivils
                                  .map((s) => _SelectChip(
                                        label: s,
                                        selected: state.statutCivil == s,
                                        onTap: () => _viewModel.updateStatutCivil(s),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 24),

                            // Nombre d'enfants
                            const _Label("Nombre d'enfants"),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _CounterButton(
                                  icon: Icons.remove,
                                  onTap: () => _viewModel.updateNbEnfants(
                                    (state.nbEnfants - 1).clamp(0, 20),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  '${state.nbEnfants}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A2342),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                _CounterButton(
                                  icon: Icons.add,
                                  onTap: () => _viewModel.updateNbEnfants(state.nbEnfants + 1),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  state.nbEnfants <= 1 ? 'enfant' : 'enfants',
                                  style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                     PrimaryButton(text:  'Continuer', onPressed: _onContinuer, enabled: state.isValid),
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
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        ),
      );
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0A2342) : const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFF0A2342) : const Color(0xFFDDD8CC),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF555555),
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF0A2342),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}
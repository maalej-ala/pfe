// situation_personnelle_page.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/situation_professionnelle/views/situation_professionnelle_page.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../view_models/situation_personnelle_view_model.dart';

class SituationPersonnellePage extends StatefulWidget {
    final String currency; // ✅ AJOUT
  const SituationPersonnellePage({
    super.key,
    this.currency = 'USD', // défaut
  });
  @override
  State<SituationPersonnellePage> createState() =>
      _SituationPersonnellePageState();
}

class _SituationPersonnellePageState
    extends State<SituationPersonnellePage> {
  late final SituationPersonnelleViewModel _viewModel;

  final List<String> _nationalites =[
  'Afghane','Albanaise','Algérienne','Allemande','Américaine','Andorrane',
  'Angolaise','Antiguaise','Argentine','Arménienne','Australienne','Autrichienne','Azerbaïdjanaise',
  'Bahamienne','Bahreïnienne','Bangladaise','Barbadienne','Biélorusse','Belge','Bélizienne','Béninoise','Bhoutanaise',
  'Birmane','Bolivienne','Bosnienne','Botswanaise','Brésilienne','Brunéienne','Bulgare','Burkinabée','Burundaise',
  'Cambodgienne','Camerounaise','Canadienne','Cap-Verdienne','Centrafricaine','Chilienne','Chinoise','Chypriote','Colombienne',
  'Comorienne','Congolaise (Congo)','Congolaise (RDC)','Costaricaine','Croate','Cubaine',
  'Danoise','Djiboutienne','Dominicaine','Dominiquaise',
  'Égyptienne','Émiratie','Équatorienne','Érythréenne','Espagnole','Estonienne','Éthiopienne',
  'Fidjienne','Finlandaise','Française',
  'Gabonaise','Gambienne','Géorgienne','Ghanéenne','Grecque','Grenadienne','Guatémaltèque','Guinéenne','Guyanienne',
  'Haïtienne','Hondurienne','Hongroise',
  'Indienne','Indonésienne','Irakienne','Iranienne','Irlandaise','Islandaise','Israélienne','Italienne',
  'Jamaïcaine','Japonaise','Jordanienne',
  'Kazakhe','Kényane','Kirghize','Kiribatienne','Koweïtienne','Kosovare',
  'Laotienne','Lesothane','Lettone','Libanaise','Libérienne','Libyenne','Liechtensteinoise','Lituanienne','Luxembourgeoise',
  'Macédonienne','Malgache','Malaisienne','Malawienne','Maldivienne','Malienne','Maltaise','Marocaine','Marshallaise','Mauritanienne','Mauricienne','Mexicaine','Micronésienne','Moldave','Monégasque','Mongole','Monténégrine','Mozambicaine',
  'Namibienne','Nauruane','Népalaise','Nicaraguayenne','Nigériane','Nigérienne','Nord-Coréenne','Norvégienne','Néo-Zélandaise',
  'Omanaise','Ougandaise','Ouzbèke',
  'Pakistanaise','Palaosienne','Palestinienne','Panaméenne','Papouasienne','Paraguayenne','Péruvienne','Philippine','Polonaise','Portugaise',
  'Qatarienne',
  'Roumaine','Rwandaise','Russe',
  'Saint-Kittsienne','Saint-Lucienne','Saint-Marinaise','Saint-Vincentaise','Salvadorienne','Samoane','Santoméenne','Saoudienne',
  'Sénégalaise','Serbe','Seychelloise','Sierra-Léonaise','Singapourienne','Slovaque','Slovène','Somalienne','Soudanaise',
  'Sri-Lankaise','Sud-Africaine','Sud-Coréenne','Sud-Soudanaise','Suédoise','Suisse','Surinamaise','Syrienne',
  'Tadjike','Taïwanaise','Tanzanienne','Tchadienne','Tchèque','Thaïlandaise','Timoraise','Togolaise','Tongienne','Trinidadienne','Tunisienne','Turkmène','Turque','Tuvaluane',
  'Ukrainienne','Uruguayenne',
  'Vanuataise','Vaticane','Vénézuélienne','Vietnamienne',
  'Yéménite',
  'Zambienne','Zimbabwéenne'
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

  Future<void> _onContinuer() async {
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
       // await _viewModel.submitSituationPersonnelle(); // ✅ envoi backend

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SituationProfessionnellePage(
            currency: widget.currency,
          )),
    );
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
                  currentStep: 3,
                  totalSteps: 8,
                  title: 'Situation personnelle',
                  subtitle:
                      'Nationalité, statut civil et situation familiale',
                  onBack: () => Navigator.pop(context),
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
                            const _Label('Nationalité'),
                            const SizedBox(height: 8),
                            _NationaliteDropdown(
                              nationalites: _nationalites,
                              selected: state.nationalite,
                              onChanged: _viewModel.updateNationalite,
                            ),
                            const SizedBox(height: 24),

                            const _Label('Statut civil'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _statutsCivils
                                  .map((s) => _SelectChip(
                                        label: s,
                                        selected: state.statutCivil == s,
                                        onTap: () =>
                                            _viewModel.updateStatutCivil(s),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 24),

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
                                // labelLarge for the big counter digit
                                Text(
                                  '${state.nbEnfants}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge,
                                ),
                                const SizedBox(width: 20),
                                _CounterButton(
                                  icon: Icons.add,
                                  onTap: () => _viewModel.updateNbEnfants(
                                      state.nbEnfants + 1),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  state.nbEnfants <= 1
                                      ? 'enfant'
                                      : 'enfants',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF888888),
                                        fontSize: 14,
                                      ),
                                ),
                              ],
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

// ── Dropdown ─────────────────────────────────────────────────
class _NationaliteDropdown extends StatelessWidget {
  final List<String> nationalites;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _NationaliteDropdown({
    required this.nationalites,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final iconColor = theme.iconTheme.color;

    return DropdownSearch<String>(
      selectedItem: selected,

      items: (filter, _) => nationalites
          .where((n) => n.toLowerCase().contains(filter.toLowerCase()))
          .toList(),

      compareFn: (a, b) => a == b,

      // ✅ utilise le theme global
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: 'Sélectionner la nationalité',
          prefixIcon: Icon(Icons.public_outlined, size: 19, color: iconColor),

          // 🔥 IMPORTANT : utiliser le theme
          filled: inputTheme.filled,
          fillColor: inputTheme.fillColor,
          contentPadding: inputTheme.contentPadding,
          hintStyle: inputTheme.hintStyle,
          border: inputTheme.border,
          enabledBorder: inputTheme.enabledBorder,
          focusedBorder: inputTheme.focusedBorder,
        ),
      ),

      popupProps: PopupProps.menu(
        showSearchBox: true,

        // ✅ champ de recherche avec theme
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Rechercher une nationalité...',
            prefixIcon: Icon(Icons.search, size: 19, color: iconColor),

            filled: inputTheme.filled,
            fillColor: inputTheme.fillColor,
            hintStyle: inputTheme.hintStyle,
            border: inputTheme.border,
            enabledBorder: inputTheme.enabledBorder,
            focusedBorder: inputTheme.focusedBorder,
            contentPadding: inputTheme.contentPadding,
          ),
        ),

        menuProps: MenuProps(
          borderRadius: BorderRadius.circular(14),
          elevation: 4,
        ),

        constraints: const BoxConstraints(maxHeight: 300),

        containerBuilder: (ctx, child) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: theme.colorScheme.surface, // ✅ important pour dark mode
            child: child,
          ),
        ),
      ),

      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem ?? '',
          style: theme.textTheme.bodyMedium,
        );
      },

      itemAsString: (item) => item,

      onChanged: onChanged,
    );
  }
}
// ── Select chip (statut civil) ────────────────────────────────
class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : const Color(0xFFDDD8CC),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : const Color(0xFF555555),
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

// ── +/- counter button ────────────────────────────────────────
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.onPrimary, size: 18),
      ),
    );
  }
}
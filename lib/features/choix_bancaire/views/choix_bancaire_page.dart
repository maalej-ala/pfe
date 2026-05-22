// choix_bancaire_page.dart
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/motDePasse/view/mot_de_passe_page.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../view_models/choix_bancaire_view_model.dart';

// ════════════════════════════════════════════════════════════════
//  DONNÉES — Packs par type de compte
// ════════════════════════════════════════════════════════════════

const _packsCourant = [
  {
    'nom': 'PACK ALTITUDE CLASSIQUE',
    'desc': "L'offre Altitude Classique vous accompagne dans votre expérience bancaire quotidienne.",
    'tarif': '10  TND / mois',
    'icon': Icons.credit_card_rounded,
    'avantages': [
      'Dépôt initial',
      'Dépôt / Retrait via Mobile Money',
      'Carte visa prépayée',
      'Online Banking',
    ],
  },
  {
    'nom': 'PACK ALTITUDE PRIVILEGE',
    'desc': "L'offre Altitude Privilège vous offre des avantages exclusifs pour votre compte courant.",
    'tarif': '15  TND / mois',
    'icon': Icons.star_rounded,
    'avantages': [
      'Dépôt initial',
      'Dépôt / Retrait via Mobile Money',
      'Carte visa prépayée',
      'Online Banking',
      'Services GIMAC',
    ],
  },
  {
    'nom': 'PACK ACTIVA',
    'desc': "L'offre Activa est idéale pour une gestion simple et efficace de votre compte courant.",
    'tarif': '5  TND / mois',
    'icon': Icons.flash_on_rounded,
    'avantages': [
      'Dépôt initial',
      'Dépôt / Retrait via Mobile Money',
      'Carte visa prépayée',
      'Online Banking',
    ],
  },
];

const _packsEpargne = [
  {
    'nom': 'ÉPARGNE ESSENTIELLE',
    'desc': "Constituez votre épargne à votre rythme avec un taux attractif et sans frais de gestion.",
    'tarif': 'Taux : 3,5 % / an',
    'icon': Icons.savings_rounded,
    'avantages': [
      'Ouverture dès 10  TND',
      'Versements libres',
      'Retrait à tout moment',
      'Relevé mensuel en ligne',
    ],
  },
  {
    'nom': 'ÉPARGNE CROISSANCE',
    'desc': "Maximisez vos rendements avec un taux bonifié et des versements programmés automatiques.",
    'tarif': 'Taux : 5,25 % / an',
    'icon': Icons.trending_up_rounded,
    'avantages': [
      'Ouverture dès 50  TND',
      'Versements programmés',
      'Taux bonifié garanti 12 mois',
      'Relevé mensuel en ligne',
      'Conseiller dédié',
    ],
  },
  {
    'nom': 'ÉPARGNE JEUNE',
    'desc': "Une épargne pensée pour les moins de 25 ans, sans frais et avec des avantages exclusifs.",
    'tarif': 'Taux : 4,0 % / an',
    'icon': Icons.school_rounded,
    'avantages': [
      'Réservé aux moins de 25 ans',
      'Ouverture dès 5  TND',
      'Aucun frais de gestion',
      'Carte prépayée offerte',
      'Online Banking',
    ],
  },
];

const _packsDeux = [
  {
    'nom': 'PACK DUO ESSENTIEL',
    'desc': "Combinez un compte courant et un compte épargne dans une offre tout-en-un accessible.",
    'tarif': '12  TND / mois',
    'icon': Icons.account_balance_wallet_rounded,
    'avantages': [
      'Compte courant + Compte épargne',
      'Carte visa prépayée',
      'Dépôt / Retrait via Mobile Money',
      'Online Banking',
      'Taux épargne : 3,0 % / an',
    ],
  },
  {
    'nom': 'PACK DUO PRIVILEGE',
    'desc': "L'excellence bancaire au quotidien : deux comptes, un seul pack, des avantages premium.",
    'tarif': '20  TND / mois',
    'icon': Icons.diamond_rounded,
    'avantages': [
      'Compte courant + Compte épargne',
      'Carte visa Gold internationale',
      'Dépôt / Retrait via Mobile Money',
      'Online Banking',
      'Taux épargne : 5,0 % / an',
      'Services GIMAC',
      'Conseiller dédié',
    ],
  },
  {
    'nom': 'PACK DUO ACTIVA',
    'desc': "La formule duo la plus accessible pour démarrer votre double projet bancaire.",
    'tarif': '8  TND / mois',
    'icon': Icons.swap_horiz_rounded,
    'avantages': [
      'Compte courant + Compte épargne',
      'Carte visa prépayée',
      'Mobile Money',
      'Online Banking',
      'Taux épargne : 2,5 % / an',
    ],
  },
];

// ════════════════════════════════════════════════════════════════
//  PAGE
// ════════════════════════════════════════════════════════════════

class ChoixBancairePage extends StatefulWidget {
  const ChoixBancairePage({super.key});

  @override
  State<ChoixBancairePage> createState() => _ChoixBancairePageState();
}

class _ChoixBancairePageState extends State<ChoixBancairePage> {
  late final ChoixBancaireViewModel _viewModel;

  /// 'courant' | 'epargne' | 'deux'
  String? _typeCompte;

  final List<String> _agences = [
    'Tunis Centre-Ville', 'Tunis Lafayette', 'Ariana', 'Ben Arous',
    'Sousse Centre', 'Sfax', 'Monastir', 'Nabeul', 'Bizerte',
  ];

  static const _typesCompte = [
    {
      'key': 'courant',
      'label': 'Compte Courant',
      'desc': 'Gestion quotidienne, paiements & retraits',
      'icon': Icons.account_balance_rounded,
    },
    {
      'key': 'epargne',
      'label': 'Compte Épargne',
      'desc': 'Faites fructifier votre argent',
      'icon': Icons.savings_rounded,
    },
    {
      'key': 'deux',
      'label': 'Les Deux',
      'desc': 'Courant + Épargne en une seule offre',
      'icon': Icons.account_balance_wallet_rounded,
    },
  ];

  List<Map<String, dynamic>> get _packsActifs {
    switch (_typeCompte) {
      case 'courant': return List<Map<String, dynamic>>.from(_packsCourant);
      case 'epargne': return List<Map<String, dynamic>>.from(_packsEpargne);
      case 'deux':    return List<Map<String, dynamic>>.from(_packsDeux);
      default:        return [];
    }
  }

  String get _packSectionTitle {
    switch (_typeCompte) {
      case 'courant': return 'Choisir un pack courant';
      case 'epargne': return 'Choisir un pack épargne';
      case 'deux':    return 'Choisir un pack duo';
      default:        return 'Choisir un pack';
    }
  }

  @override
  void initState() {
    super.initState();
    _viewModel = ChoixBancaireViewModel();
    _viewModel.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

void _selectTypeCompte(String key) {
  setState(() {
    _typeCompte = key;

    _viewModel.updateTypeCompte(key);

    // reset pack
    _viewModel.updateTypeCarte(null);
  });
}

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _viewModel.dispose();
    super.dispose();
  }

 Future<void> _onContinuer() async {

  if (_typeCompte == null) {

    _showSnack(
      'Veuillez choisir un type de compte.',
    );

    return;
  }

  if (!_viewModel.state.isValid) {

    _showSnack(
      'Veuillez sélectionner une agence et un pack.',
    );

    return;
  }

  final success =
      await _viewModel.saveChoixBancaire();

  if (!mounted) return;

  if (success) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MotDePassePage(),
      ),
    );

  } else {

    _showSnack(

      _viewModel.state.error ??

      'Erreur inconnue',
    );
  }
}

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
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
                  currentStep: 5,
                  totalSteps: 8,
                  title: 'Choix bancaire',
                  subtitle: 'Compte, agence et pack',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [

                      
                      // ── 2. Agence ─────────────────────────────────
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
// ── 1. Type de compte ─────────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label('Type de compte'),
                            const SizedBox(height: 14),
                            ..._typesCompte.map((tc) => _CompteTypeOption(
                                  label: tc['label'] as String,
                                  desc: tc['desc'] as String,
                                  icon: tc['icon'] as IconData,
                                  selected: _typeCompte == tc['key'],
                                  onTap: () =>
                                      _selectTypeCompte(tc['key'] as String),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 3. Packs dynamiques ───────────────────────
                      if (_typeCompte != null)
                        _FormCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label(_packSectionTitle),
                              const SizedBox(height: 16),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  key: ValueKey(_typeCompte),
                                  children: _packsActifs
                                      .map((carte) => _PackOption(
                                            nom: carte['nom'] as String,
                                            desc: carte['desc'] as String,
                                            tarif: carte['tarif'] as String,
                                            icon: carte['icon'] as IconData,
                                            avantages: List<String>.from(
                                                carte['avantages'] as List),
                                            selected:
                                                state.typeCarte == carte['nom'],
                                            onTap: () =>
                                                _viewModel.updateTypeCarte(
                                                    carte['nom'] as String),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _EmptyPackHint(),

                      const SizedBox(height: 28),

                     PrimaryButton(
  text: state.isLoading
      ? 'Chargement...'
      : 'Continuer',
  onPressed: state.isLoading
      ? null
      : _onContinuer,
  enabled: _typeCompte != null &&
      state.isValid &&
      !state.isLoading,
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

// ════════════════════════════════════════════════════════════════
//  WIDGET — Option type de compte (radio stylisé)
// ════════════════════════════════════════════════════════════════

class _CompteTypeOption extends StatelessWidget {
  final String label;
  final String desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CompteTypeOption({
    required this.label,
    required this.desc,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor
        ?? const Color(0xFFF9F8F5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colorScheme.secondary : const Color(0xFFE5E0D5),
            width: selected ? 1.8 : 1.0,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: colorScheme.primary.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.secondary.withOpacity(0.18)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20,
                  color: selected ? colorScheme.secondary : colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.5,
                        color: selected
                            ? Colors.white60
                            : const Color(0xFF888888),
                      )),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey('on'),
                      color: colorScheme.secondary, size: 22)
                  : Icon(Icons.radio_button_unchecked_rounded,
                      key: const ValueKey('off'),
                      color: const Color(0xFFCCCCCC), size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  WIDGET — Placeholder avant le choix du type de compte
// ════════════════════════════════════════════════════════════════

class _EmptyPackHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: colorScheme.primary.withOpacity(0.4), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sélectionnez un type de compte ci-dessus pour voir les packs disponibles.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary.withOpacity(0.55),
                    fontSize: 12.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  WIDGETS PARTAGÉS
// ════════════════════════════════════════════════════════════════

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
        color: theme.inputDecorationTheme.fillColor,
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

class _PackOption extends StatelessWidget {
  final String nom;
  final String desc;
  final String tarif;
  final IconData icon;
  final List<String> avantages;
  final bool selected;
  final VoidCallback onTap;

  const _PackOption({
    required this.nom,
    required this.desc,
    required this.tarif,
    required this.icon,
    required this.avantages,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Color activeBg = colorScheme.primary;
    final Color activeAccent = colorScheme.secondary;
    final Color inactiveBg = Theme.of(context).inputDecorationTheme.fillColor
        ?? const Color(0xFFF9F8F5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? activeAccent : const Color(0xFFE5E0D5),
            width: selected ? 1.8 : 1.0,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: activeBg.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4))]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête ───────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: selected
                          ? activeAccent.withOpacity(0.18)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20,
                        color: selected ? activeAccent : colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(nom,
                        style: textTheme.labelMedium?.copyWith(
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 0.3,
                        )),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded,
                        color: activeAccent, size: 22),
                ],
              ),

              const SizedBox(height: 10),

              // ── Description ───────────────────────────────
              Text(desc,
                  style: textTheme.bodySmall?.copyWith(
                    color: selected ? Colors.white70 : const Color(0xFF666666),
                    fontSize: 12,
                  )),

              const SizedBox(height: 10),

              // ── Avantages ─────────────────────────────────
              ...avantages.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_rounded,
                            size: 14,
                            color: selected
                                ? activeAccent
                                : colorScheme.primary.withOpacity(0.6)),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(a,
                              style: textTheme.bodySmall?.copyWith(
                                color: selected
                                    ? Colors.white.withOpacity(0.85)
                                    : const Color(0xFF555555),
                                fontSize: 12,
                                height: 1.4,
                              )),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 10),

              // ── Tarif / Taux ──────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? activeAccent.withOpacity(0.18)
                      : colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payments_outlined,
                        size: 14,
                        color: selected ? activeAccent : colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(tarif,
                        style: textTheme.labelSmall?.copyWith(
                          color: selected ? activeAccent : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
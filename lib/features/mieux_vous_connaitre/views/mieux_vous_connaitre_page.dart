import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/mieux_vous_connaitre/models/mieux_vous_connaitre_state.dart';
import 'package:pfe_flutter/shared/app_colors.dart';


import 'package:pfe_flutter/features/3photo/view/take3_photo_page.dart';
import 'package:pfe_flutter/features/TextRecognition/view/text_recognition_page.dart';

import '../view_models/mieux_vous_connaitre_view_model.dart';

class MieuxVousConnaitrePage extends StatefulWidget {
  const MieuxVousConnaitrePage({super.key});

  @override
  State<MieuxVousConnaitrePage> createState() => _MieuxVousConnaitrePageState();
}

class _MieuxVousConnaitrePageState extends State<MieuxVousConnaitrePage> {
  late final MieuxVousConnaitreViewModel _viewModel;

  // Contrôleurs
  final _adresseController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _revenuController = TextEditingController();
  final _cinController = TextEditingController();
  final _dateDelivranceController = TextEditingController();

  // Listes statiques
  final List<String> _gouvernorats = [
    'Ariana', 'Béja', 'Ben Arous', 'Bizerte', 'Gabès', 'Gafsa',
    'Jendouba', 'Kairouan', 'Kasserine', 'Kébili', 'Kef', 'Mahdia',
    'Manouba', 'Médenine', 'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid',
    'Siliana', 'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan',
  ];

  final List<String> _nationalites = ['Tunisienne', 'Française', 'Algérienne', 'Marocaine', 'Libyenne', 'Autre'];
  final List<String> _statutsCivils = ['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf / Veuve'];
  final List<String> _categoriesSocioPro = [
    'Salarié du secteur privé', 'Fonctionnaire / Salarié du secteur public',
    'Profession libérale', 'Commerçant / Artisan', 'Chef d\'entreprise',
    'Retraité(e)', 'Étudiant(e)', 'Sans emploi',
  ];
  final List<String> _naturesActivite = ['Activité principale', 'Activité secondaire', 'Retraite', 'Rente'];
  final List<String> _secteursActivite = [
    'Agriculture', 'Industrie', 'Commerce', 'Services', 'Administration',
    'Santé', 'Éducation', 'Tourisme', 'Finance / Banque', 'Immobilier',
    'Transport / Logistique', 'Technologies / IT', 'Autre',
  ];
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
    _viewModel = MieuxVousConnaitreViewModel();
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
    _revenuController.dispose();
    _cinController.dispose();
    _dateDelivranceController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.secondary,
            surface: AppColors.primary,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      ctrl.text = formatted;
      _viewModel.updateDateDelivrance(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Stack(
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _NavButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
                      const Spacer(),
                      _StepBadge(current: 2, total: 4),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mieux vous connaître', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.4)),
                      SizedBox(height: 4),
                      Text('Complétez les 5 sections pour finaliser votre dossier', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.50,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _AccordionSection(
                        index: 0,
                        expanded: state.expandedSection == 0,
                        icon: Icons.location_on_outlined,
                        title: 'Adresse',
                        subtitle: 'Pays, gouvernorat & code postal',
                        onTap: () => _viewModel.updateExpandedSection(state.expandedSection == 0 ? -1 : 0),
                        child: _buildAdresseSection(state),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 1,
                        expanded: state.expandedSection == 1,
                        icon: Icons.person_outline_rounded,
                        title: 'Informations personnelles',
                        subtitle: 'Nationalité, statut civil, enfants',
                        onTap: () => _viewModel.updateExpandedSection(state.expandedSection == 1 ? -1 : 1),
                        child: _buildInfoPersonnellesSection(state),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 2,
                        expanded: state.expandedSection == 2,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Informations financières',
                        subtitle: 'CSP, revenus & secteur d\'activité',
                        onTap: () => _viewModel.updateExpandedSection(state.expandedSection == 2 ? -1 : 2),
                        child: _buildInfoFinancieresSection(state),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 3,
                        expanded: state.expandedSection == 3,
                        icon: Icons.account_balance_outlined,
                        title: 'Agence & Carte',
                        subtitle: 'Choisissez votre agence et type de carte',
                        onTap: () => _viewModel.updateExpandedSection(state.expandedSection == 3 ? -1 : 3),
                        child: _buildAgenceCarteSection(state),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 4,
                        expanded: state.expandedSection == 4,
                        icon: Icons.badge_outlined,
                        title: 'Mes documents',
                        subtitle: 'CIN, photos & déclarations',
                        onTap: () => _viewModel.updateExpandedSection(state.expandedSection == 4 ? -1 : 4),
                        child: _buildDocumentsSection(state),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continuer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.secondary),
                            ],
                          ),
                        ),
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

  // ==================== SECTIONS ADAPTÉES ====================

  Widget _buildAdresseSection(MieuxVousConnaitreState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Adresse complète'),
        const SizedBox(height: 8),
        _Input(controller: _adresseController, hint: 'N° rue, rue, immeuble...', icon: Icons.home_outlined, onChanged: _viewModel.updateAdresse),
        const SizedBox(height: 16),
        _Label('Pays'),
        const SizedBox(height: 8),
        _DropdownField(value: state.pays, items: const ['Tunisie', 'France', 'Algérie', 'Maroc', 'Autre'], hint: 'Sélectionner le pays', icon: Icons.flag_outlined, onChanged: _viewModel.updatePays),
        const SizedBox(height: 16),
        _Label('Gouvernorat'),
        const SizedBox(height: 8),
        _DropdownField(value: state.gouvernorat, items: _gouvernorats, hint: 'Sélectionner le gouvernorat', icon: Icons.map_outlined, onChanged: _viewModel.updateGouvernorat),
        const SizedBox(height: 16),
        _Label('Code postal'),
        const SizedBox(height: 8),
        _Input(controller: _codePostalController, hint: 'Ex: 1001', icon: Icons.local_post_office_outlined, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], onChanged: _viewModel.updateCodePostal),
      ],
    );
  }

  Widget _buildInfoPersonnellesSection(MieuxVousConnaitreState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Nationalité'),
        const SizedBox(height: 8),
        _DropdownField(value: state.nationalite, items: _nationalites, hint: 'Sélectionner la nationalité', icon: Icons.public_outlined, onChanged: _viewModel.updateNationalite),
        const SizedBox(height: 16),
        _Label('Statut civil'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _statutsCivils.map((s) => _SelectChip(label: s, selected: state.statutCivil == s, onTap: () => _viewModel.updateStatutCivil(s))).toList(),
        ),
        const SizedBox(height: 16),
        _Label('Nombre d\'enfants'),
        const SizedBox(height: 10),
        Row(
          children: [
            _CounterButton(icon: Icons.remove, onTap: () => _viewModel.updateNbEnfants((state.nbEnfants - 1).clamp(0, 20))),
            const SizedBox(width: 20),
            Text('${state.nbEnfants}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
            const SizedBox(width: 20),
            _CounterButton(icon: Icons.add, onTap: () => _viewModel.updateNbEnfants(state.nbEnfants + 1)),
            const SizedBox(width: 12),
            Text(state.nbEnfants <= 1 ? 'enfant' : 'enfants', style: const TextStyle(color: Color(0xFF888888), fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoFinancieresSection(MieuxVousConnaitreState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Catégorie socio-professionnelle'),
        const SizedBox(height: 8),
        _DropdownField(value: state.categorieSocioPro, items: _categoriesSocioPro, hint: 'Sélectionner votre catégorie', icon: Icons.work_outline_rounded, onChanged: _viewModel.updateCategorieSocioPro),
        const SizedBox(height: 16),
        _Label('Revenu net mensuel (TND)'),
        const SizedBox(height: 8),
        _Input(controller: _revenuController, hint: 'Ex: 2500', icon: Icons.payments_outlined, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], onChanged: _viewModel.updateRevenu),
        const SizedBox(height: 16),
        _Label('Nature de l\'activité'),
        const SizedBox(height: 8),
        _DropdownField(value: state.natureActivite, items: _naturesActivite, hint: 'Sélectionner la nature', icon: Icons.category_outlined, onChanged: _viewModel.updateNatureActivite),
        const SizedBox(height: 16),
        _Label('Secteur d\'activité'),
        const SizedBox(height: 8),
        _DropdownField(value: state.secteurActivite, items: _secteursActivite, hint: 'Sélectionner le secteur', icon: Icons.business_outlined, onChanged: _viewModel.updateSecteurActivite),
      ],
    );
  }

  Widget _buildAgenceCarteSection(MieuxVousConnaitreState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Choisir une agence'),
        const SizedBox(height: 8),
        _DropdownField(value: state.agence, items: _agences, hint: 'Agence la plus proche', icon: Icons.location_city_outlined, onChanged: _viewModel.updateAgence),
        const SizedBox(height: 20),
        _Label('Type de carte bancaire'),
        const SizedBox(height: 12),
        ..._typesCarte.map((carte) => _CarteOption(
              nom: carte['nom'],
              desc: carte['desc'],
              icon: carte['icon'],
              selected: state.typeCarte == carte['nom'],
              onTap: () => _viewModel.updateTypeCarte(carte['nom']),
            )),
      ],
    );
  }

  Widget _buildDocumentsSection(MieuxVousConnaitreState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Numéro de CIN'),
        const SizedBox(height: 8),
        _Input(controller: _cinController, hint: '8 chiffres', icon: Icons.badge_outlined, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)], onChanged: _viewModel.updateCin),
        const SizedBox(height: 16),
        _Label('Date de délivrance CIN'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(_dateDelivranceController),
          child: AbsorbPointer(
            child: _Input(controller: _dateDelivranceController, hint: 'JJ/MM/AAAA', icon: Icons.event_outlined, suffixIcon: Icons.calendar_today_outlined),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _PhotoUploadBox(
                label: 'CIN Recto',
                icon: Icons.flip_to_front_rounded,
                hasImage: state.hasCinRecto,
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const TextRecognitionPage()));
                  if (result != null && result is String && result.isNotEmpty) {
                    _cinController.text = result;
                    _viewModel.updateCin(result);
                  }
                  _viewModel.updateHasCinRecto(true);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PhotoUploadBox(
                label: 'CIN Verso',
                icon: Icons.flip_to_back_rounded,
                hasImage: state.hasCinVerso,
                onTap: () => _viewModel.updateHasCinVerso(true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Vidéo en direct (inchangé)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 12)]),
                child: const Icon(Icons.videocam_rounded, color: AppColors.secondary, size: 28),
              ),
              const SizedBox(height: 12),
              const Text('Vidéo de vérification en direct', style: TextStyle(color: Color(0xFF0A2342), fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('Nous allons vous demander de prendre 3 photos face caméra pour confirmer votre identité', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF0A2342), fontSize: 12, height: 1.5)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Take3PhotoPage())),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Lancer la vérification'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: Color(0xFF0A2342), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _DeclarationBox(value: state.confirmeSansAmericanite, onChanged: _viewModel.updateConfirmeSansAmericanite, icon: Icons.gavel_rounded, text: 'Je confirme que je n\'ai aucun indice d\'américanité (non-soumis à FATCA)', color: const Color(0xFF1B6CA8)),
        const SizedBox(height: 12),
        _DeclarationBox(value: state.estClientAutreBanque, onChanged: _viewModel.updateEstClientAutreBanque, icon: Icons.account_balance_rounded, text: 'Je suis client(e) dans une autre banque', color: const Color(0xFF2E7D32)),
      ],
    );
  }
}

// ====================== WIDGETS PRIVÉS (CORRIGÉS) ======================

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 18)),
      );
}

class _StepBadge extends StatelessWidget {
  final int current;
  final int total;
  const _StepBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.secondary.withOpacity(0.5))),
        child: Text('Étape $current / $total', style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class _AccordionSection extends StatelessWidget {
  final int index;
  final bool expanded;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget child;

  const _AccordionSection({required this.index, required this.expanded, required this.icon, required this.title, required this.subtitle, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(expanded ? 0.12 : 0.05), blurRadius: expanded ? 16 : 6, offset: const Offset(0, 3))],
        border: Border.all(color: expanded ? AppColors.secondary.withOpacity(0.4) : Colors.transparent, width: 1.5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: expanded ? AppColors.primary : const Color(0xFFF0EDE6), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: expanded ? AppColors.secondary : AppColors.primary)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${index + 1}. $title', style: TextStyle(color: AppColors.primary, fontWeight: expanded ? FontWeight.bold : FontWeight.w600, fontSize: 14.5)),
                        Text(subtitle, style: const TextStyle(color: Color(0xFF999999), fontSize: 11.5)),
                      ],
                    ),
                  ),
                  Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: expanded ? AppColors.secondary : const Color(0xFFAAAAAA)),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Divider(color: const Color(0xFFEEEAE0), height: 1), const SizedBox(height: 16), child]),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Color(0xFF0A2342), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1));
}

// _Input avec onChanged (obligatoire pour le ViewModel)
class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _Input({required this.controller, required this.hint, required this.icon, this.keyboardType = TextInputType.text, this.suffixIcon, this.inputFormatters, this.onChanged});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14.5, color: Color(0xFF0A2342), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5),
          prefixIcon: Icon(icon, size: 19, color: const Color(0xFF8899AA)),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 17, color: const Color(0xFF8899AA)) : null,
          filled: true,
          fillColor: const Color(0xFFF9F8F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E0D5))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E0D5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5)),
        ),
      );
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({required this.value, required this.items, required this.hint, required this.icon, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: const Color(0xFFF9F8F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E0D5))),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(prefixIcon: Icon(icon, size: 19, color: const Color(0xFF8899AA)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4)),
          hint: Text(hint, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5)),
          style: const TextStyle(color: Color(0xFF0A2342), fontSize: 14.5, fontWeight: FontWeight.w500),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8899AA)),
          onChanged: onChanged,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        ),
      );
}

// Tous les autres widgets (_SelectChip, _CounterButton, _CarteOption, _PhotoUploadBox, _DeclarationBox) sont identiques à ton code original
// (je les ai gardés exactement pareils pour ne rien casser)

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
          decoration: BoxDecoration(color: selected ? const Color(0xFF0A2342) : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? const Color(0xFF0A2342) : const Color(0xFFDDD8CC))),
          child: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF555555), fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
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
        child: Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF0A2342), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 18)),
      );
}

class _CarteOption extends StatelessWidget {
  final String nom;
  final String desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CarteOption({required this.nom, required this.desc, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: selected ? const Color(0xFF0A2342) : const Color(0xFFF9F8F5), borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.secondary : const Color(0xFFE5E0D5), width: selected ? 1.5 : 1)),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: selected ? AppColors.secondary.withOpacity(0.2) : Colors.white, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: selected ? AppColors.secondary : AppColors.primary, size: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom, style: TextStyle(color: selected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(desc, style: TextStyle(color: selected ? Colors.white60 : const Color(0xFF888888), fontSize: 11.5)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20),
            ],
          ),
        ),
      );
}

class _PhotoUploadBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool hasImage;
  final VoidCallback onTap;

  const _PhotoUploadBox({required this.label, required this.icon, required this.hasImage, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(color: hasImage ? AppColors.primary.withOpacity(0.05) : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(14), border: Border.all(color: hasImage ? AppColors.secondary : const Color(0xFFDDD8CC), width: hasImage ? 1.5 : 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(hasImage ? Icons.check_circle_outline : icon, color: hasImage ? AppColors.secondary : const Color(0xFF8899AA), size: 28),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: hasImage ? AppColors.primary : const Color(0xFF888888), fontSize: 12, fontWeight: hasImage ? FontWeight.bold : FontWeight.normal)),
              if (!hasImage) const Text('Appuyer pour télécharger', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 10)),
            ],
          ),
        ),
      );
}

class _DeclarationBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final IconData icon;
  final String text;
  final Color color;

  const _DeclarationBox({required this.value, required this.onChanged, required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: value ? color.withOpacity(0.06) : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(14), border: Border.all(color: value ? color.withOpacity(0.4) : const Color(0xFFDDD8CC), width: value ? 1.5 : 1)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(color: const Color(0xFF333333), fontSize: 12.5, height: 1.5, fontWeight: value ? FontWeight.w600 : FontWeight.normal))),
            Transform.scale(scale: 1.0, child: Checkbox(value: value, onChanged: onChanged, activeColor: color, checkColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), side: BorderSide(color: color.withOpacity(0.5), width: 1.5), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
          ],
        ),
      );
}
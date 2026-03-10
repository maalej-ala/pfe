import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MieuxVousConnaitrePage extends StatefulWidget {
  const MieuxVousConnaitrePage({super.key});

  @override
  State<MieuxVousConnaitrePage> createState() =>
      _MieuxVousConnaitrePageState();
}

class _MieuxVousConnaitrePageState extends State<MieuxVousConnaitrePage> {
  // ── Section 1 – Adresse ──────────────────────────────────────────────────
  final _adresseController = TextEditingController();
  String? _pays = 'Tunisie';
  String? _gouvernorat;
  final _codePostalController = TextEditingController();

  // ── Section 2 – Informations personnelles ───────────────────────────────
  String? _nationalite;
  String? _statutCivil;
  int _nbEnfants = 0;

  // ── Section 3 – Informations financières ────────────────────────────────
  String? _categorieSocioPro;
  final _revenuController = TextEditingController();
  String? _natureActivite;
  String? _secteurActivite;

  // ── Section 4 – Agence & Carte ───────────────────────────────────────────
  String? _agence;
  String? _typeCarte;

  // ── Section 5 – Documents ────────────────────────────────────────────────
  final _cinController = TextEditingController();
  final _dateDelivranceController = TextEditingController();
  String? _cinRectoPath;
  String? _cinVersoPath;
  bool _confirmeSansAmericanite = false;
  bool _estClientAutreBanque = false;

  // ── Expansion ─────────────────────────────────────────────────────────────
  int _expandedSection = 0;

  // ── Data lists ────────────────────────────────────────────────────────────
  final List<String> _gouvernorats = [
    'Ariana', 'Béja', 'Ben Arous', 'Bizerte', 'Gabès', 'Gafsa',
    'Jendouba', 'Kairouan', 'Kasserine', 'Kébili', 'Kef', 'Mahdia',
    'Manouba', 'Médenine', 'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid',
    'Siliana', 'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan',
  ];

  final List<String> _nationalites = [
    'Tunisienne', 'Française', 'Algérienne', 'Marocaine', 'Libyenne',
    'Autre',
  ];

  final List<String> _statutsCivils = [
    'Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf / Veuve',
  ];

  final List<String> _categoriesSocioPro = [
    'Salarié du secteur privé',
    'Fonctionnaire / Salarié du secteur public',
    'Profession libérale',
    'Commerçant / Artisan',
    'Chef d\'entreprise',
    'Retraité(e)',
    'Étudiant(e)',
    'Sans emploi',
  ];

  final List<String> _naturesActivite = [
    'Activité principale', 'Activité secondaire', 'Retraite', 'Rente',
  ];

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
  void dispose() {
    _adresseController.dispose();
    _codePostalController.dispose();
    _revenuController.dispose();
    _cinController.dispose();
    _dateDelivranceController.dispose();
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
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFC9A84C),
            surface: Color(0xFF0A2342),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Stack(
        children: [
          Container(
            height: 210,
            decoration: const BoxDecoration(
              color: Color(0xFF0A2342),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _NavButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      _StepBadge(current: 2, total: 4),
                    ],
                  ),
                ),

                // ── Title ─────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mieux vous connaître',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complétez les 5 sections pour finaliser votre dossier',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Progress ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.50,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFC9A84C)),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Accordion sections ────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _AccordionSection(
                        index: 0,
                        expanded: _expandedSection == 0,
                        icon: Icons.location_on_outlined,
                        title: 'Adresse',
                        subtitle: 'Pays, gouvernorat & code postal',
                        onTap: () =>
                            setState(() => _expandedSection =
                                _expandedSection == 0 ? -1 : 0),
                        child: _buildAdresseSection(),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 1,
                        expanded: _expandedSection == 1,
                        icon: Icons.person_outline_rounded,
                        title: 'Informations personnelles',
                        subtitle: 'Nationalité, statut civil, enfants',
                        onTap: () =>
                            setState(() => _expandedSection =
                                _expandedSection == 1 ? -1 : 1),
                        child: _buildInfoPersonnellesSection(),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 2,
                        expanded: _expandedSection == 2,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Informations financières',
                        subtitle: 'CSP, revenus & secteur d\'activité',
                        onTap: () =>
                            setState(() => _expandedSection =
                                _expandedSection == 2 ? -1 : 2),
                        child: _buildInfoFinancieresSection(),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 3,
                        expanded: _expandedSection == 3,
                        icon: Icons.account_balance_outlined,
                        title: 'Agence & Carte',
                        subtitle: 'Choisissez votre agence et type de carte',
                        onTap: () =>
                            setState(() => _expandedSection =
                                _expandedSection == 3 ? -1 : 3),
                        child: _buildAgenceCarteSection(),
                      ),
                      const SizedBox(height: 10),
                      _AccordionSection(
                        index: 4,
                        expanded: _expandedSection == 4,
                        icon: Icons.badge_outlined,
                        title: 'Mes documents',
                        subtitle: 'CIN, photos & déclarations',
                        onTap: () =>
                            setState(() => _expandedSection =
                                _expandedSection == 4 ? -1 : 4),
                        child: _buildDocumentsSection(),
                      ),
                      const SizedBox(height: 24),

                      // ── CTA ──────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A2342),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continuer',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 18, color: Color(0xFFC9A84C)),
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

  // ── SECTION 1 – Adresse ──────────────────────────────────────────────────
  Widget _buildAdresseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Adresse complète'),
        const SizedBox(height: 8),
        _Input(
          controller: _adresseController,
          hint: 'N° rue, rue, immeuble...',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        _Label('Pays'),
        const SizedBox(height: 8),
        _DropdownField(
          value: _pays,
          items: const ['Tunisie', 'France', 'Algérie', 'Maroc', 'Autre'],
          hint: 'Sélectionner le pays',
          icon: Icons.flag_outlined,
          onChanged: (v) => setState(() => _pays = v),
        ),
        const SizedBox(height: 16),
        _Label('Gouvernorat'),
        const SizedBox(height: 8),
        _DropdownField(
          value: _gouvernorat,
          items: _gouvernorats,
          hint: 'Sélectionner le gouvernorat',
          icon: Icons.map_outlined,
          onChanged: (v) => setState(() => _gouvernorat = v),
        ),
        const SizedBox(height: 16),
        _Label('Code postal'),
        const SizedBox(height: 8),
        _Input(
          controller: _codePostalController,
          hint: 'Ex: 1001',
          icon: Icons.local_post_office_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  // ── SECTION 2 – Informations personnelles ───────────────────────────────
  Widget _buildInfoPersonnellesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Nationalité'),
        const SizedBox(height: 8),
        _DropdownField(
          value: _nationalite,
          items: _nationalites,
          hint: 'Sélectionner la nationalité',
          icon: Icons.public_outlined,
          onChanged: (v) => setState(() => _nationalite = v),
        ),
        const SizedBox(height: 16),
        _Label('Statut civil'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _statutsCivils
              .map((s) => _SelectChip(
                    label: s,
                    selected: _statutCivil == s,
                    onTap: () => setState(() => _statutCivil = s),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        _Label('Nombre d\'enfants'),
        const SizedBox(height: 10),
        Row(
          children: [
            _CounterButton(
              icon: Icons.remove,
              onTap: () => setState(
                  () => _nbEnfants = (_nbEnfants - 1).clamp(0, 20)),
            ),
            const SizedBox(width: 20),
            Text(
              '$_nbEnfants',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2342),
              ),
            ),
            const SizedBox(width: 20),
            _CounterButton(
              icon: Icons.add,
              onTap: () => setState(() => _nbEnfants++),
            ),
            const SizedBox(width: 12),
            Text(
              _nbEnfants <= 1 ? 'enfant' : 'enfants',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  // ── SECTION 3 – Informations financières ────────────────────────────────
  Widget _buildInfoFinancieresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Catégorie socio-professionnelle'),
        const SizedBox(height: 8),
        _DropdownField(
          value: _categorieSocioPro,
          items: _categoriesSocioPro,
          hint: 'Sélectionner votre catégorie',
          icon: Icons.work_outline_rounded,
          onChanged: (v) => setState(() => _categorieSocioPro = v),
        ),
        const SizedBox(height: 16),
        _Label('Revenu net mensuel (TND)'),
        const SizedBox(height: 8),
        _Input(
          controller: _revenuController,
          hint: 'Ex: 2500',
          icon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        _Label('Nature de l\'activité'),
        const SizedBox(height: 8),
        _DropdownField(
          value: _natureActivite,
          items: _naturesActivite,
          hint: 'Sélectionner la nature',
          icon: Icons.category_outlined,
          onChanged: (v) => setState(() => _natureActivite = v),
        ),
        const SizedBox(height: 16),
        _Label('Secteur d\'activité'),
        const SizedBox(height: 8),
        _DropdownField(
          value: _secteurActivite,
          items: _secteursActivite,
          hint: 'Sélectionner le secteur',
          icon: Icons.business_outlined,
          onChanged: (v) => setState(() => _secteurActivite = v),
        ),
      ],
    );
  }

  // ── SECTION 4 – Agence & Carte ────────────────────────────────────────────
  Widget _buildAgenceCarteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Choisir une agence'),
        const SizedBox(height: 8),
        _DropdownField(
          value: _agence,
          items: _agences,
          hint: 'Agence la plus proche',
          icon: Icons.location_city_outlined,
          onChanged: (v) => setState(() => _agence = v),
        ),
        const SizedBox(height: 20),
        _Label('Type de carte bancaire'),
        const SizedBox(height: 12),
        ..._typesCarte.map(
          (carte) => _CarteOption(
            nom: carte['nom'],
            desc: carte['desc'],
            icon: carte['icon'],
            selected: _typeCarte == carte['nom'],
            onTap: () => setState(() => _typeCarte = carte['nom']),
          ),
        ),
      ],
    );
  }

  // ── SECTION 5 – Documents ─────────────────────────────────────────────────
  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Numéro de CIN'),
        const SizedBox(height: 8),
        _Input(
          controller: _cinController,
          hint: '8 chiffres',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
        ),
        const SizedBox(height: 16),
        _Label('Date de délivrance CIN'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(_dateDelivranceController),
          child: AbsorbPointer(
            child: _Input(
              controller: _dateDelivranceController,
              hint: 'JJ/MM/AAAA',
              icon: Icons.event_outlined,
              suffixIcon: Icons.calendar_today_outlined,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // CIN photos
        Row(
          children: [
            Expanded(
              child: _PhotoUploadBox(
                label: 'CIN Recto',
                icon: Icons.flip_to_front_rounded,
                hasImage: _cinRectoPath != null,
                onTap: () => setState(() => _cinRectoPath = 'recto_selected'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PhotoUploadBox(
                label: 'CIN Verso',
                icon: Icons.flip_to_back_rounded,
                hasImage: _cinVersoPath != null,
                onTap: () => setState(() => _cinVersoPath = 'verso_selected'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Vidéo en direct
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2342).withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF0A2342).withOpacity(0.15),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2342),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A2342).withOpacity(0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.videocam_rounded,
                    color: Color(0xFFC9A84C), size: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vidéo de vérification en direct',
                style: TextStyle(
                  color: Color(0xFF0A2342),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nous allons vous demander de prendre 3 photos face caméra pour confirmer votre identité',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF0A2342).withOpacity(0.6),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to Take3Photo page
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Lancer la vérification'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0A2342),
                    side: const BorderSide(color: Color(0xFF0A2342), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Déclarations
        _DeclarationBox(
          value: _confirmeSansAmericanite,
          onChanged: (v) =>
              setState(() => _confirmeSansAmericanite = v ?? false),
          icon: Icons.gavel_rounded,
          text:
              'Je confirme que je n\'ai aucun indice d\'américanité (non-soumis à FATCA)',
          color: const Color(0xFF1B6CA8),
        ),

        const SizedBox(height: 12),

        _DeclarationBox(
          value: _estClientAutreBanque,
          onChanged: (v) =>
              setState(() => _estClientAutreBanque = v ?? false),
          icon: Icons.account_balance_rounded,
          text: 'Je suis client(e) dans une autre banque',
          color: const Color(0xFF2E7D32),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int current;
  final int total;
  const _StepBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC9A84C).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.5)),
      ),
      child: Text(
        'Étape $current / $total',
        style: const TextStyle(
          color: Color(0xFFC9A84C),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccordionSection extends StatelessWidget {
  final int index;
  final bool expanded;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget child;

  const _AccordionSection({
    required this.index,
    required this.expanded,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2342).withOpacity(expanded ? 0.12 : 0.05),
            blurRadius: expanded ? 16 : 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: expanded
              ? const Color(0xFFC9A84C).withOpacity(0.4)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: expanded
                          ? const Color(0xFF0A2342)
                          : const Color(0xFFF0EDE6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: expanded
                          ? const Color(0xFFC9A84C)
                          : const Color(0xFF0A2342),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. $title',
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontWeight: expanded
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: expanded
                        ? const Color(0xFFC9A84C)
                        : const Color(0xFFAAAAAA),
                  ),
                ],
              ),
            ),
          ),

          // Body
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: const Color(0xFFEEEAE0), height: 1),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
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
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0A2342),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const _Input({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF0A2342),
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5),
        prefixIcon: Icon(icon, size: 19, color: const Color(0xFF8899AA)),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 17, color: const Color(0xFF8899AA))
            : null,
        filled: true,
        fillColor: const Color(0xFFF9F8F5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
          borderSide:
              const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
        ),
      ),
    );
  }
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
    return Container(
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        ),
        hint: Text(hint,
            style:
                const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5)),
        style: const TextStyle(
            color: Color(0xFF0A2342),
            fontSize: 14.5,
            fontWeight: FontWeight.w500),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF8899AA)),
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A2342) : const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF0A2342)
                : const Color(0xFFDDD8CC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF555555),
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF0A2342),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0A2342)
              : const Color(0xFFF9F8F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFC9A84C)
                : const Color(0xFFE5E0D5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFC9A84C).withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected
                    ? const Color(0xFFC9A84C)
                    : const Color(0xFF0A2342),
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
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF0A2342),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
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
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFFC9A84C), size: 20),
          ],
        ),
      ),
    );
  }
}

class _PhotoUploadBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool hasImage;
  final VoidCallback onTap;

  const _PhotoUploadBox({
    required this.label,
    required this.icon,
    required this.hasImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: hasImage
              ? const Color(0xFF0A2342).withOpacity(0.05)
              : const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasImage
                ? const Color(0xFFC9A84C)
                : const Color(0xFFDDD8CC),
            width: hasImage ? 1.5 : 1,
            style: hasImage ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasImage ? Icons.check_circle_outline : icon,
              color: hasImage
                  ? const Color(0xFFC9A84C)
                  : const Color(0xFF8899AA),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: hasImage
                    ? const Color(0xFF0A2342)
                    : const Color(0xFF888888),
                fontSize: 12,
                fontWeight: hasImage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (!hasImage)
              const Text(
                'Appuyer pour télécharger',
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeclarationBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final IconData icon;
  final String text;
  final Color color;

  const _DeclarationBox({
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.06) : const Color(0xFFF5F3EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? color.withOpacity(0.4) : const Color(0xFFDDD8CC),
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 12.5,
                height: 1.5,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.0,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side:
                  BorderSide(color: color.withOpacity(0.5), width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:pfe_flutter/pages/mieux_vous_connaitre_page.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({super.key});

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  String _civilite = 'M.';
  bool _accepteMentions = false;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC9A84C),
              surface: Color(0xFF0A2342),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Stack(
        children: [
          // Top navy header band
          Container(
            height: 220,
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
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A84C).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFC9A84C).withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          'Étape 1 / 4',
                          style: TextStyle(
                            color: Color(0xFFC9A84C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title in header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Veuillez renseigner vos informations personnelles',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.25,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFC9A84C)),
                      minHeight: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Form card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A2342).withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Civilité
                          _SectionLabel(text: 'Civilité'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _CiviliteChip(
                                label: 'M.',
                                selected: _civilite == 'M.',
                                onTap: () =>
                                    setState(() => _civilite = 'M.'),
                              ),
                              const SizedBox(width: 12),
                              _CiviliteChip(
                                label: 'Mme',
                                selected: _civilite == 'Mme',
                                onTap: () =>
                                    setState(() => _civilite = 'Mme'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Nom
                          _SectionLabel(text: 'Nom'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _nomController,
                            hint: 'Votre nom de famille',
                            icon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.name,
                          ),

                          const SizedBox(height: 20),

                          // Prénom
                          _SectionLabel(text: 'Prénom'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _prenomController,
                            hint: 'Votre prénom',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.name,
                          ),

                          const SizedBox(height: 20),

                          // Téléphone
                          _SectionLabel(text: 'Numéro de téléphone'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _telController,
                            ////// il faut changer + 216 par le code du pays de l'utilisateur

                            hint: '+216 XX XX XX XX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 20),

                          // Email
                          _SectionLabel(text: 'Adresse e-mail'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _emailController,
                            hint: 'exemple@email.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 20),

                          // Date de naissance
                          _SectionLabel(text: 'Date de naissance'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: _InputField(
                                controller: _dateController,
                                hint: 'JJ/MM/AAAA',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.datetime,
                                suffixIcon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Mentions légales
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3EE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _accepteMentions
                                    ? const Color(0xFFC9A84C).withOpacity(0.5)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.1,
                                  child: Checkbox(
                                    value: _accepteMentions,
                                    onChanged: (val) {
                                      setState(() {
                                        _accepteMentions = val ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFFC9A84C),
                                    checkColor: const Color(0xFF0A2342),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFBBB49A),
                                      width: 1.5,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Color(0xFF555555),
                                        fontSize: 12.5,
                                        height: 1.5,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              'J\'accepte les ',
                                        ),
                                        TextSpan(
                                          text:
                                              'mentions légales relatives à la protection des données personnelles',
                                          style: const TextStyle(
                                            color: Color(0xFFC9A84C),
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                Color(0xFFC9A84C),
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' conformément au RGPD.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Bouton Continuer
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _accepteMentions
                                  ? () {
                                      Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MieuxVousConnaitrePage(),
              ),);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A2342),
                                disabledBackgroundColor:
                                    const Color(0xFFCCCCCC),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Continuer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: _accepteMentions
                                        ? const Color(0xFFC9A84C)
                                        : Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0A2342),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final IconData? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF0A2342),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(
          icon,
          size: 19,
          color: const Color(0xFF8899AA),
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 18, color: const Color(0xFF8899AA))
            : null,
        filled: true,
        fillColor: const Color(0xFFF9F8F5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E0D5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E0D5), width: 1),
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

class _CiviliteChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CiviliteChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0A2342)
              : const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF0A2342)
                : const Color(0xFFDDD8CC),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF666666),
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
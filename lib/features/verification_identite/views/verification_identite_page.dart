import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/shared/app_colors.dart';
import 'package:pfe_flutter/features/3photo/view/take3_photo_page.dart';
import 'package:pfe_flutter/features/TextRecognition/view/text_recognition_page.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';
import '../view_models/verification_identite_view_model.dart';

class VerificationIdentitePage extends StatefulWidget {
  const VerificationIdentitePage({super.key});

  @override
  State<VerificationIdentitePage> createState() =>
      _VerificationIdentitePageState();
}

class _VerificationIdentitePageState extends State<VerificationIdentitePage> {
  late final VerificationIdentiteViewModel _viewModel;

  final _cinController = TextEditingController();
  final _dateDelivranceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = VerificationIdentiteViewModel();
    _viewModel.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _cinController.dispose();
    _dateDelivranceController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
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
      _dateDelivranceController.text = formatted;
      _viewModel.updateDateDelivrance(formatted);
    }
  }

  void _onSoumettre() {
    if (!_viewModel.state.isValid) {
      String msg = 'Veuillez compléter toutes les étapes de vérification.';
      if (_viewModel.state.cin.length != 8) msg = 'Le numéro CIN doit contenir 8 chiffres.';
      else if (_viewModel.state.dateDelivrance.isEmpty) msg = 'Veuillez saisir la date de délivrance.';
      else if (!_viewModel.state.hasCinRecto || !_viewModel.state.hasCinVerso) msg = 'Veuillez télécharger les deux faces de votre CIN.';
      else if (!_viewModel.state.verificationsPhotosCompleted) msg = 'Veuillez compléter la vérification vidéo.';
      else if (!_viewModel.state.confirmeSansAmericanite) msg = 'Veuillez confirmer la déclaration FATCA.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
      return;
    }
    Navigator.pop(context, _viewModel.state);
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
                // Top bar
                PageHeader(currentStep: 6, totalSteps: 8, title: 'Vérification d\'identité', subtitle: 'Confirmez votre identité avec votre CIN'),
                const SizedBox(height: 24),

                // Form
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // CIN Info card
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.badge_outlined,
                              title: 'Informations CIN',
                            ),
                            const SizedBox(height: 16),

                            const _Label('Numéro de CIN'),
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
                              onChanged: _viewModel.updateCin,
                            ),
                            const SizedBox(height: 16),

                            const _Label('Date de délivrance CIN'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectDate,
                              child: AbsorbPointer(
                                child: _Input(
                                  controller: _dateDelivranceController,
                                  hint: 'JJ/MM/AAAA',
                                  icon: Icons.event_outlined,
                                  suffixIcon: Icons.calendar_today_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Photos CIN card
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.photo_camera_outlined,
                              title: 'Photos de la CIN',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _PhotoUploadBox(
                                    label: 'CIN Recto',
                                    icon: Icons.flip_to_front_rounded,
                                    hasImage: state.hasCinRecto,
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TextRecognitionPage(),
                                        ),
                                      );
                                      if (result != null &&
                                          result is String &&
                                          result.isNotEmpty) {
                                        _cinController.text = result;
                                        _viewModel.updateCin(result);
                                        _viewModel.updateHasCinRecto(true);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PhotoUploadBox(
                                    label: 'CIN Verso',
                                    icon: Icons.flip_to_back_rounded,
                                    hasImage: state.hasCinVerso,
                                    onTap: () =>
                                        _viewModel.updateHasCinVerso(true),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Vidéo vérification card
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.videocam_rounded,
                              title: 'Vérification en direct',
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: state.verificationsPhotosCompleted
                                    ? AppColors.secondary.withOpacity(0.07)
                                    : AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: state.verificationsPhotosCompleted
                                      ? AppColors.secondary.withOpacity(0.4)
                                      : AppColors.primary.withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: state.verificationsPhotosCompleted
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.25),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      state.verificationsPhotosCompleted
                                          ? Icons.check_rounded
                                          : Icons.videocam_rounded,
                                      color: state.verificationsPhotosCompleted
                                          ? Colors.white
                                          : AppColors.secondary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.verificationsPhotosCompleted
                                        ? 'Vérification complétée !'
                                        : 'Vidéo de vérification en direct',
                                    style: const TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Nous allons vous demander de prendre 3 photos face caméra pour confirmer votre identité',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (!state.verificationsPhotosCompleted)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const Take3PhotoPage(),
                                            ),
                                          );
                                          _viewModel
                                              .updateVerificationsPhotosCompleted(
                                                  true);
                                        },
                                        icon: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 18),
                                        label:
                                            const Text('Lancer la vérification'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(
                                              color: Color(0xFF0A2342),
                                              width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Déclarations card
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.gavel_rounded,
                              title: 'Déclarations',
                            ),
                            const SizedBox(height: 16),
                            _DeclarationBox(
                              value: state.confirmeSansAmericanite,
                              onChanged: _viewModel.updateConfirmeSansAmericanite,
                              icon: Icons.gavel_rounded,
                              text:
                                  'Je confirme que je n\'ai aucun indice d\'américanité (non-soumis à FATCA)',
                              color: const Color(0xFF1B6CA8),
                            ),
                            const SizedBox(height: 12),
                            _DeclarationBox(
                              value: state.estClientAutreBanque,
                              onChanged: _viewModel.updateEstClientAutreBanque,
                              icon: Icons.account_balance_rounded,
                              text: 'Je suis client(e) dans une autre banque',
                              color: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      PrimaryButton(text:'Soumettre', onPressed: _onSoumettre, enabled: state.isValid),
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0A2342),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _Input({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF0A2342),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5),
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
            borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
          ),
        ),
      );
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(
            color: hasImage
                ? AppColors.primary.withOpacity(0.05)
                : const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasImage ? AppColors.secondary : const Color(0xFFDDD8CC),
              width: hasImage ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasImage ? Icons.check_circle_outline : icon,
                color: hasImage ? AppColors.secondary : const Color(0xFF8899AA),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: hasImage ? AppColors.primary : const Color(0xFF888888),
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
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              value ? color.withOpacity(0.06) : const Color(0xFFF5F3EE),
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
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );
}
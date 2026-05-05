// verification_identite_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/motDePasse/view/mot_de_passe_page.dart';
import 'package:pfe_flutter/features/3photo/view/take3_photo_page.dart';
import 'package:pfe_flutter/features/TextRecognition/view/text_recognition_page.dart';
import 'package:pfe_flutter/features/verification_identite/models/verification_identite_model.dart';
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

  File? _photoCin;
  File? _photoVisageCin;
  File? _photoVisageLive;

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
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: colorScheme.secondary,
            surface: colorScheme.primary,
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

  Future<void> _ouvrirScanCin() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const TextRecognitionPage()),
    );
    if (result != null) {
      setState(() {
        if (result['cinImage'] is File) _photoCin = result['cinImage'];
        if (result['faceImage'] is File) _photoVisageCin = result['faceImage'];
      });
      _viewModel.updateHasCinRecto(true);
    }
  }

  Future<void> _ouvrirVerificationLive() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const Take3PhotoPage()),
    );
    if (result != null) {
      setState(() => _photoVisageLive = result);
      _viewModel.updateVerificationsPhotosCompleted(true);
    }
  }

  Future<void> _onSoumettre() async {
    final s = _viewModel.state;
    if (!s.isValid) {
      String msg = 'Veuillez compléter toutes les étapes.';
      if (s.cin.length != 8)
        msg = 'Le numéro CIN doit contenir 8 chiffres.';
      else if (s.dateDelivrance.isEmpty)
        msg = 'Veuillez saisir la date de délivrance.';
      else if (!s.hasCinRecto)
        msg = 'Veuillez scanner votre CIN.';
      else if (!s.verificationsPhotosCompleted)
        msg = 'Veuillez compléter la vérification vidéo.';
      else if (!s.confirmeSansAmericanite)
        msg = 'Veuillez confirmer la déclaration FATCA.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await _viewModel.submitVerification(
      photoCin: _photoCin,
      photoVisageCin: _photoVisageCin,
      photoVisageLive: _photoVisageLive,
    );

    if (!mounted) return;

    if (success) {
      // // ── Afficher le résultat OCR dans un bottom sheet ─────────────
      // final result = _viewModel.verificationResult;
      // if (result != null) {
      //   await showModalBottomSheet(
      //     context: context,
      //     isScrollControlled: true,
      //     backgroundColor: Colors.transparent,
      //     builder: (_) => _OcrResultBottomSheet(result: result),
      //   );
      // }

      // // ── Si identité vérifiée → continuer ─────────────────────────
      // if (!mounted) return;
      // if (result?.identiteVerifiee == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MotDePassePage()),
        );
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ??
              'Erreur lors de l\'envoi. Vérifiez votre connexion.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
                  currentStep: 6,
                  totalSteps: 8,
                  title: "Vérification d'identité",
                  subtitle: 'Confirmez votre identité avec votre CIN',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // ── 1. Informations CIN ───────────────────────
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

                      // ── 2. Photos CIN ─────────────────────────────
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
                                  child: _StatusBox(
                                    label: 'CIN Recto',
                                    icon: Icons.flip_to_front_rounded,
                                    isDone: state.hasCinRecto,
                                    doneLabel: 'Scanné',
                                    pendingLabel: 'Scanner',
                                    onTap: _ouvrirScanCin,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatusBox(
                                    label: 'CIN Verso',
                                    icon: Icons.flip_to_back_rounded,
                                    isDone: state.hasCinVerso,
                                    doneLabel: 'Confirmé',
                                    pendingLabel: 'Confirmer',
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

                      // ── 3. Vérification live ──────────────────────
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.videocam_rounded,
                              title: 'Vérification en direct',
                            ),
                            const SizedBox(height: 16),
                            _LiveVerificationBox(
                              isDone: state.verificationsPhotosCompleted,
                              onTap: _ouvrirVerificationLive,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 4. Déclarations ───────────────────────────
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
                              onChanged:
                                  _viewModel.updateConfirmeSansAmericanite,
                              icon: Icons.gavel_rounded,
                              text:
                                  "Je confirme que je n'ai aucun indice d'américanité (non-soumis à FATCA)",
                              color: const Color(0xFF1B6CA8),
                            ),
                            const SizedBox(height: 12),
                            _DeclarationBox(
                              value: state.estClientAutreBanque,
                              onChanged: _viewModel.updateEstClientAutreBanque,
                              icon: Icons.account_balance_rounded,
                              text:
                                  "Je suis client(e) dans une autre banque",
                              color: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Bouton soumission ─────────────────────────
                      _viewModel.isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              text: 'Continuer',
                              onPressed: _onSoumettre,
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

// ══════════════════════════════════════════════════════════════
//  BOTTOM SHEET — Résultats OCR
// ══════════════════════════════════════════════════════════════

class _OcrResultBottomSheet extends StatefulWidget {
  final VerificationResultModel result;
  const _OcrResultBottomSheet({required this.result});

  @override
  State<_OcrResultBottomSheet> createState() => _OcrResultBottomSheetState();
}

class _OcrResultBottomSheetState extends State<_OcrResultBottomSheet> {
  bool _showRawText = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final ocr    = result.ocrExtrait;
    final colorScheme = Theme.of(context).colorScheme;

    final bool verified = result.identiteVerifiee;
    final Color statusColor = verified ? Colors.green : Colors.redAccent;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // ── Drag handle ───────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // ── En-tête statut global ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      verified
                          ? Icons.verified_rounded
                          : Icons.warning_amber_rounded,
                      color: statusColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verified
                                ? 'Identité vérifiée ✓'
                                : 'Vérification échouée',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result.message ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: statusColor.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Corps scrollable ──────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [

                  // ── Vérification champ par champ ──────────
                  _SheetSection(
                    title: 'Vérification des champs',
                    icon: Icons.checklist_rounded,
                    child: Column(
                      children: [
                        _VerifRow(
                          label: 'CIN',
                          saisi: result.cinSaisi,
                          extrait: result.cinOcr,
                          valide: result.cinValide,
                        ),
                        _VerifRow(
                          label: 'Nom',
                          saisi: null,
                          extrait: result.nomOcr,
                          valide: result.nomValide,
                          hideSaisi: true,
                        ),
                        _VerifRow(
                          label: 'Prénom',
                          saisi: null,
                          extrait: result.prenomOcr,
                          valide: result.prenomValide,
                          hideSaisi: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Champs extraits par OCR ───────────────
                  if (ocr != null)
                    _SheetSection(
                      title: 'Données extraites de la carte',
                      icon: Icons.document_scanner_outlined,
                      child: Column(
                        children: [
                          _OcrField('Numéro CIN',         ocr.numeroCin),
                          _OcrField('Nom',                ocr.nom),
                          _OcrField('Prénom',             ocr.prenom),
                          _OcrField('Date de naissance',  ocr.dateNaissance),
                          _OcrField('Sexe',               ocr.sexe),
                          _OcrField('Lieu de naissance',  ocr.lieuNaissance),
                          _OcrField('Profession',         ocr.profession),
                          _OcrField('Date établissement', ocr.dateEtablissement),
                          _OcrField('Date expiration',    ocr.dateExpiration),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Texte brut OCR (dépliable) ────────────
                  if (ocr?.rawText != null && ocr!.rawText!.isNotEmpty)
                    _SheetSection(
                      title: 'Texte brut Tesseract',
                      icon: Icons.text_snippet_outlined,
                      trailing: GestureDetector(
                        onTap: () =>
                            setState(() => _showRawText = !_showRawText),
                        child: Text(
                          _showRawText ? 'Masquer' : 'Afficher',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      child: _showRawText
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3EE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFE0DDD6)),
                              ),
                              child: Text(
                                ocr.rawText!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  height: 1.5,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                  const SizedBox(height: 24),

                  // ── Bouton fermer ─────────────────────────
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(verified ? 'Continuer' : 'Fermer'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section avec titre ────────────────────────────────────────
class _SheetSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SheetSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0EDE6)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── Ligne de vérification : saisi vs extrait avec icône ──────
class _VerifRow extends StatelessWidget {
  final String label;
  final String? saisi;
  final String? extrait;
  final bool valide;
  final bool hideSaisi;

  const _VerifRow({
    required this.label,
    required this.saisi,
    required this.extrait,
    required this.valide,
    this.hideSaisi = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = valide ? Colors.green : Colors.redAccent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            valide ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.labelMedium),
                if (!hideSaisi && saisi != null)
                  Text('Saisi : $saisi',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xFF888888))),
                Text(
                  'Carte : ${extrait ?? "non détecté"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
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

// ── Champ OCR simple : label + valeur ────────────────────────
class _OcrField extends StatelessWidget {
  final String label;
  final String? value;
  const _OcrField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                    )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    )),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// WIDGETS DE LA PAGE PRINCIPALE (inchangés)
// ════════════════════════════════════════════════════════════════════

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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
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
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 17, color: iconColor)
            : null,
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone;
  final String doneLabel;
  final String pendingLabel;
  final VoidCallback onTap;

  const _StatusBox({
    required this.label,
    required this.icon,
    required this.isDone,
    required this.doneLabel,
    required this.pendingLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final doneColor = colorScheme.secondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 100,
        decoration: BoxDecoration(
          color: isDone
              ? doneColor.withOpacity(0.07)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone ? doneColor : const Color(0xFFDDD8CC),
            width: isDone ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isDone
                  ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey('done'),
                      color: doneColor, size: 32)
                  : Icon(icon,
                      key: const ValueKey('idle'),
                      color: Theme.of(context).iconTheme.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDone
                          ? colorScheme.primary
                          : const Color(0xFF888888),
                      fontWeight:
                          isDone ? FontWeight.bold : FontWeight.normal,
                    )),
            const SizedBox(height: 2),
            Text(isDone ? doneLabel : pendingLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: isDone ? doneColor : const Color(0xFFAAAAAA),
                    )),
          ],
        ),
      ),
    );
  }
}

class _LiveVerificationBox extends StatelessWidget {
  final bool isDone;
  final VoidCallback onTap;
  const _LiveVerificationBox({required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final doneColor = colorScheme.secondary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDone
            ? doneColor.withOpacity(0.07)
            : colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? doneColor.withOpacity(0.5)
              : colorScheme.primary.withOpacity(0.15),
          width: isDone ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isDone
                ? Container(
                    key: const ValueKey('done'),
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: doneColor, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: doneColor.withOpacity(0.3), blurRadius: 12)],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 28),
                  )
                : Container(
                    key: const ValueKey('idle'),
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: colorScheme.primary.withOpacity(0.25),
                          blurRadius: 12)],
                    ),
                    child: Icon(Icons.videocam_rounded,
                        color: colorScheme.secondary, size: 28),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            isDone ? 'Vérification complétée !' : 'Vidéo de vérification en direct',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDone ? doneColor : null,
                  fontWeight: isDone ? FontWeight.bold : null,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            isDone
                ? 'Vos 3 photos ont été capturées avec succès'
                : 'Nous allons vous demander de prendre 3 photos face caméra',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDone
                      ? doneColor.withOpacity(0.8)
                      : colorScheme.primary,
                ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(
                  isDone ? Icons.refresh_rounded : Icons.camera_alt_outlined,
                  size: 18),
              label: Text(isDone ? 'Recommencer' : 'Lancer la vérification'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isDone ? doneColor : colorScheme.primary,
                    width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
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
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value
              ? color.withOpacity(0.06)
              : Theme.of(context).scaffoldBackgroundColor,
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
              child: Text(text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF333333),
                        fontWeight:
                            value ? FontWeight.w600 : FontWeight.normal,
                      )),
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
// features/signature/view/signature_page.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:pfe_flutter/features/signature/model/signature_state.dart';
import 'package:pfe_flutter/features/signature/view_model/signature_view_model.dart';
import 'package:pfe_flutter/shared/services/device_service.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';

// ══════════════════════════════════════════════════════════════
//  PAGE PRINCIPALE
// ══════════════════════════════════════════════════════════════
class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  late final SignatureEditViewModel _viewModel;
  final _scrollController = ScrollController();
  bool _scrollLocked = false;

  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _viewModel = SignatureEditViewModel();
    _viewModel.addListener(_updateUI);
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    final id = await DeviceService().getDeviceId();
    setState(() => _deviceId = id);
    _viewModel.charger(id);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setScrollLocked(bool locked) {
    if (_scrollLocked != locked) {
      setState(() => _scrollLocked = locked);
    }
  }

  /// Appelé par _SignatureSection après ouverture du pad :
  /// scrolle jusqu'au bas pour rendre le pad entièrement visible.
  void _scrollToBottom() {
    // On attend le prochain frame pour que le pad soit rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onConfirmer() async {
    if (!_viewModel.hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Veuillez apposer votre signature avant de continuer.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    try {
      await _viewModel.confirmerEtTerminer(_deviceId!);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Dossier soumis !',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              'Votre chargé clientèle prendra contact avec vous',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Terminer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                PageHeader(
                  currentStep: 8,
                  totalSteps: 8,
                  title: 'Récapitulatif',
                  subtitle: 'Vérifiez et modifiez vos informations',
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          if (_viewModel.isSaving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_deviceId == null || _viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.error != null) {
      return _ErrorView(
        error: _viewModel.error!,
        onRetry: () => _viewModel.charger(_deviceId!),
      );
    }
    final d = _viewModel.data;
    if (d == null) return const SizedBox();

    return ListView(
      controller: _scrollController,
      physics: _scrollLocked
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _EditableSection(
          icon: Icons.person_outline_rounded,
          title: 'Identité',
          child: _IdentiteSection(data: d, onUpdate: _viewModel.updateField),
        ),
        const SizedBox(height: 16),
        _EditableSection(
          icon: Icons.badge_outlined,
          title: 'Vérification CIN',
          child: _CinSection(data: d, onUpdate: _viewModel.updateField),
        ),
        const SizedBox(height: 16),
        _EditableSection(
          icon: Icons.home_outlined,
          title: 'Adresse',
          child: _AdresseSection(data: d, onUpdate: _viewModel.updateField),
        ),
        const SizedBox(height: 16),
        _EditableSection(
          icon: Icons.people_outline_rounded,
          title: 'Situation personnelle',
          child: _SituationPersonnelleSection(
              data: d, onUpdate: _viewModel.updateField),
        ),
        const SizedBox(height: 16),
        _EditableSection(
          icon: Icons.work_outline_rounded,
          title: 'Situation professionnelle',
          child: _SituationProSection(
              data: d, onUpdate: _viewModel.updateField),
        ),
        const SizedBox(height: 16),
        _SignatureSection(
          signatureBase64: d.signatureBase64,
          onSignatureSaved: _viewModel.setSignature,
          onSignatureCleared: _viewModel.clearSignature,
          onScrollLockChanged: _setScrollLocked,
          // ✅ callback pour scroller vers le bas après ouverture du pad
          onPadOpened: _scrollToBottom,
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          text: 'Confirmer et terminer',
          onPressed: _onConfirmer,
          enabled: !_viewModel.isSaving,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION ÉDITABLE GÉNÉRIQUE
// ══════════════════════════════════════════════════════════════
class _EditableSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _EditableSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  State<_EditableSection> createState() => _EditableSectionState();
}

class _EditableSectionState extends State<_EditableSection> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _editing
              ? colorScheme.secondary.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(widget.icon, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              GestureDetector(
                onTap: () => setState(() => _editing = !_editing),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _editing
                        ? colorScheme.secondary.withOpacity(0.12)
                        : colorScheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _editing
                            ? Icons.check_rounded
                            : Icons.edit_outlined,
                        size: 14,
                        color: _editing
                            ? colorScheme.secondary
                            : colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _editing ? 'Terminer' : 'Modifier',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _editing
                              ? colorScheme.secondary
                              : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0EDE6)),
          const SizedBox(height: 12),
          _EditModeProvider(editing: _editing, child: widget.child),
        ],
      ),
    );
  }
}

class _EditModeProvider extends InheritedWidget {
  final bool editing;
  const _EditModeProvider({required this.editing, required super.child});

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_EditModeProvider>()
            ?.editing ??
        false;
  }

  @override
  bool updateShouldNotify(_EditModeProvider old) => editing != old.editing;
}

// ══════════════════════════════════════════════════════════════
//  SECTION SIGNATURE
// ══════════════════════════════════════════════════════════════
class _SignatureSection extends StatefulWidget {
  final String? signatureBase64;
  final void Function(Uint8List bytes) onSignatureSaved;
  final VoidCallback onSignatureCleared;
  final void Function(bool locked) onScrollLockChanged;
  // ✅ Nouveau : déclenché après que le pad est visible dans l'arbre
  final VoidCallback onPadOpened;

  const _SignatureSection({
    required this.signatureBase64,
    required this.onSignatureSaved,
    required this.onSignatureCleared,
    required this.onScrollLockChanged,
    required this.onPadOpened,
  });

  @override
  State<_SignatureSection> createState() => _SignatureSectionState();
}

class _SignatureSectionState extends State<_SignatureSection> {
  final _control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  bool _padVisible = false;

  @override
  void dispose() {
    widget.onScrollLockChanged(false);
    _control.dispose();
    super.dispose();
  }

  void _openPad() {
    setState(() => _padVisible = true);
    widget.onScrollLockChanged(true);
    // ✅ Scroll vers le bas après le rebuild (pad rendu dans l'arbre)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPadOpened();
    });
  }

  void _closePad() {
    setState(() => _padVisible = false);
    widget.onScrollLockChanged(false);
  }

  Future<void> _saveSignature() async {
    if (!_control.isFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez tracer votre signature.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final byteData = await _control.toImage(
      color: Theme.of(context).colorScheme.primary,
      background: Colors.transparent,
    );
    if (byteData == null) return;
    widget.onSignatureSaved(byteData.buffer.asUint8List());
    _closePad();
  }

  void _clearAndReopen() {
    _control.clear();
    widget.onSignatureCleared();
    _openPad();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasExistingSignature =
        widget.signatureBase64 != null && widget.signatureBase64!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasExistingSignature
              ? Colors.green.withOpacity(0.4)
              : colorScheme.secondary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (hasExistingSignature
                          ? Colors.green
                          : colorScheme.secondary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.draw_outlined,
                  size: 18,
                  color: hasExistingSignature
                      ? Colors.green
                      : colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Signature',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      hasExistingSignature
                          ? 'Signature enregistrée ✓'
                          : 'Requis pour valider le dossier',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasExistingSignature
                            ? Colors.green
                            : colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0EDE6)),
          const SizedBox(height: 16),

          // ── Aperçu signature existante ───────────────────────
          if (hasExistingSignature && !_padVisible) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFFF9F8F5),
                child: Image.memory(
                  base64Decode(widget.signatureBase64!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _clearAndReopen,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Modifier la signature'),
            ),
          ],

          // ── Bouton ouvrir le pad ─────────────────────────────
          if (!hasExistingSignature && !_padVisible)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openPad,
                icon: Icon(Icons.draw_outlined,
                    size: 16, color: colorScheme.secondary),
                label: Text(
                  'Apposer ma signature',
                  style: TextStyle(color: colorScheme.secondary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: colorScheme.secondary.withOpacity(0.5),
                      width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          // ── Pad de signature ─────────────────────────────────
          if (_padVisible) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Signez dans le cadre ci-dessous',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
                GestureDetector(
                  onTap: _closePad,
                  child: Icon(Icons.close_rounded,
                      size: 18,
                      color: colorScheme.primary.withOpacity(0.5)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.secondary.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: HandSignature(
                  control: _control,
                  color: colorScheme.primary,
                  width: 1.5,
                  maxWidth: 4.0,
                  type: SignatureDrawType.shape,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _control.clear,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Effacer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveSignature,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Valider la signature'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SOUS-SECTIONS
// ══════════════════════════════════════════════════════════════

class _IdentiteSection extends StatefulWidget {
  final SignatureEditModel data;
  final void Function(String field, dynamic value) onUpdate;
  const _IdentiteSection({required this.data, required this.onUpdate});
  @override
  State<_IdentiteSection> createState() => _IdentiteSectionState();
}

class _IdentiteSectionState extends State<_IdentiteSection> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telCtrl;
  late final TextEditingController _dateCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _nomCtrl    = TextEditingController(text: d.nom);
    _prenomCtrl = TextEditingController(text: d.prenom);
    _emailCtrl  = TextEditingController(text: d.email);
    _telCtrl    = TextEditingController(text: d.telephone);
    _dateCtrl   = TextEditingController(text: d.dateNaissance);
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
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
      _dateCtrl.text = formatted;
      widget.onUpdate('dateNaissance', formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = _EditModeProvider.of(context);
    final d = widget.data;
    if (!editing) {
      return Column(children: [
        _DataRow(label: 'Civilité',          value: d.civilite),
        _DataRow(label: 'Nom',               value: d.nom),
        _DataRow(label: 'Prénom',            value: d.prenom),
        _DataRow(label: 'Email',             value: d.email),
        _DataRow(label: 'Téléphone',         value: d.telephone),
        _DataRow(label: 'Date de naissance', value: d.dateNaissance),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _EditLabel('Civilité'),
      const SizedBox(height: 8),
      Row(
        children: ['M.', 'Mme'].map((c) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _CiviliteChip(
            label: c,
            selected: d.civilite == c,
            onTap: () => widget.onUpdate('civilite', c),
          ),
        )).toList(),
      ),
      const SizedBox(height: 16),
      _EditLabel('Nom'), const SizedBox(height: 6),
      _EditField(controller: _nomCtrl, icon: Icons.person_outline_rounded,
          onChanged: (v) => widget.onUpdate('nom', v)),
      const SizedBox(height: 12),
      _EditLabel('Prénom'), const SizedBox(height: 6),
      _EditField(controller: _prenomCtrl, icon: Icons.badge_outlined,
          onChanged: (v) => widget.onUpdate('prenom', v)),
      const SizedBox(height: 12),
      _EditLabel('Email'), const SizedBox(height: 6),
      _EditField(controller: _emailCtrl, icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => widget.onUpdate('email', v)),
      const SizedBox(height: 12),
      _EditLabel('Téléphone'), const SizedBox(height: 6),
      _EditField(controller: _telCtrl, icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: (v) => widget.onUpdate('telephone', v)),
      const SizedBox(height: 12),
      _EditLabel('Date de naissance'), const SizedBox(height: 6),
      GestureDetector(
        onTap: () => _pickDate(context),
        child: AbsorbPointer(
          child: _EditField(
            controller: _dateCtrl,
            icon: Icons.cake_outlined,
            suffixIcon: Icons.calendar_today_outlined,
          ),
        ),
      ),
    ]);
  }
}

class _CinSection extends StatefulWidget {
  final SignatureEditModel data;
  final void Function(String, dynamic) onUpdate;
  const _CinSection({required this.data, required this.onUpdate});
  @override
  State<_CinSection> createState() => _CinSectionState();
}

class _CinSectionState extends State<_CinSection> {
  late final TextEditingController _cinCtrl;
  late final TextEditingController _dateCtrl;
  @override
  void initState() {
    super.initState();
    _cinCtrl  = TextEditingController(text: widget.data.cin);
    _dateCtrl = TextEditingController(text: widget.data.dateDelivrance);
  }
  @override
  void dispose() {
    _cinCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final editing = _EditModeProvider.of(context);
    final d = widget.data;
    if (!editing) {
      return Column(children: [
        _DataRow(label: 'Numéro CIN',      value: d.cin),
        _DataRow(label: 'Date délivrance', value: d.dateDelivrance),
        _DataRow(label: 'Client autre banque',
            value: d.estClientAutreBanque ? 'Oui' : 'Non'),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _EditLabel('Numéro CIN'), const SizedBox(height: 6),
      _EditField(controller: _cinCtrl, icon: Icons.credit_card_outlined,
          onChanged: (v) => widget.onUpdate('cin', v)),
      const SizedBox(height: 12),
      _EditLabel('Date de délivrance'), const SizedBox(height: 6),
      _EditField(controller: _dateCtrl, icon: Icons.calendar_month_outlined,
          onChanged: (v) => widget.onUpdate('dateDelivrance', v)),
      const SizedBox(height: 12),
      _BoolToggle(
        label: 'Client autre banque',
        value: d.estClientAutreBanque,
        onChanged: (v) => widget.onUpdate('estClientAutreBanque', v),
      ),
    ]);
  }
}

class _AdresseSection extends StatefulWidget {
  final SignatureEditModel data;
  final void Function(String, dynamic) onUpdate;
  const _AdresseSection({required this.data, required this.onUpdate});
  @override
  State<_AdresseSection> createState() => _AdresseSectionState();
}

class _AdresseSectionState extends State<_AdresseSection> {
  late final TextEditingController _adresseCtrl;
  late final TextEditingController _paysCtrl;
  late final TextEditingController _gouvernoratCtrl;
  late final TextEditingController _cpCtrl;
  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _adresseCtrl     = TextEditingController(text: d.adresse);
    _paysCtrl        = TextEditingController(text: d.paysNom);
    _gouvernoratCtrl = TextEditingController(text: d.gouvernorat);
    _cpCtrl          = TextEditingController(text: d.codePostal);
  }
  @override
  void dispose() {
    _adresseCtrl.dispose();
    _paysCtrl.dispose();
    _gouvernoratCtrl.dispose();
    _cpCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final editing = _EditModeProvider.of(context);
    final d = widget.data;
    if (!editing) {
      return Column(children: [
        _DataRow(label: 'Adresse',     value: d.adresse),
        _DataRow(label: 'Pays',        value: d.paysNom),
        _DataRow(label: 'Gouvernorat', value: d.gouvernorat),
        _DataRow(label: 'Code postal', value: d.codePostal),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _EditLabel('Adresse complète'), const SizedBox(height: 6),
      _EditField(controller: _adresseCtrl, icon: Icons.home_outlined,
          onChanged: (v) => widget.onUpdate('adresse', v)),
      const SizedBox(height: 12),
      _EditLabel('Pays'), const SizedBox(height: 6),
      _EditField(controller: _paysCtrl, icon: Icons.flag_outlined,
          onChanged: (v) => widget.onUpdate('paysNom', v)),
      const SizedBox(height: 12),
      _EditLabel('Gouvernorat'), const SizedBox(height: 6),
      _EditField(controller: _gouvernoratCtrl, icon: Icons.map_outlined,
          onChanged: (v) => widget.onUpdate('gouvernorat', v)),
      const SizedBox(height: 12),
      _EditLabel('Code postal'), const SizedBox(height: 6),
      _EditField(controller: _cpCtrl, icon: Icons.local_post_office_outlined,
          keyboardType: TextInputType.number,
          onChanged: (v) => widget.onUpdate('codePostal', v)),
    ]);
  }
}

class _SituationPersonnelleSection extends StatefulWidget {
  final SignatureEditModel data;
  final void Function(String, dynamic) onUpdate;
  const _SituationPersonnelleSection(
      {required this.data, required this.onUpdate});
  @override
  State<_SituationPersonnelleSection> createState() =>
      _SituationPersonnelleSectionState();
}

class _SituationPersonnelleSectionState
    extends State<_SituationPersonnelleSection> {
  late final TextEditingController _nationaliteCtrl;
  late final TextEditingController _statutCtrl;
  @override
  void initState() {
    super.initState();
    _nationaliteCtrl = TextEditingController(text: widget.data.nationalite);
    _statutCtrl      = TextEditingController(text: widget.data.statutCivil);
  }
  @override
  void dispose() {
    _nationaliteCtrl.dispose();
    _statutCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final editing = _EditModeProvider.of(context);
    final d = widget.data;
    if (!editing) {
      return Column(children: [
        _DataRow(label: 'Nationalité',  value: d.nationalite),
        _DataRow(label: 'Statut civil', value: d.statutCivil),
        _DataRow(label: 'Nb enfants',   value: d.nbEnfants.toString()),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _EditLabel('Nationalité'), const SizedBox(height: 6),
      _EditField(controller: _nationaliteCtrl, icon: Icons.public_outlined,
          onChanged: (v) => widget.onUpdate('nationalite', v)),
      const SizedBox(height: 12),
      _EditLabel('Statut civil'), const SizedBox(height: 6),
      _EditField(controller: _statutCtrl,
          icon: Icons.favorite_border_rounded,
          onChanged: (v) => widget.onUpdate('statutCivil', v)),
      const SizedBox(height: 12),
      _EditLabel("Nombre d'enfants"), const SizedBox(height: 8),
      _NbEnfantsCounter(
          value: d.nbEnfants,
          onChanged: (v) => widget.onUpdate('nbEnfants', v)),
    ]);
  }
}

class _SituationProSection extends StatefulWidget {
  final SignatureEditModel data;
  final void Function(String, dynamic) onUpdate;
  const _SituationProSection({required this.data, required this.onUpdate});
  @override
  State<_SituationProSection> createState() => _SituationProSectionState();
}

class _SituationProSectionState extends State<_SituationProSection> {
  late final TextEditingController _catCtrl;
  late final TextEditingController _revenuCtrl;
  late final TextEditingController _natureCtrl;
  late final TextEditingController _secteurCtrl;
  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _catCtrl     = TextEditingController(text: d.categorieSocioPro);
    _revenuCtrl  = TextEditingController(text: d.revenu);
    _natureCtrl  = TextEditingController(text: d.natureActivite);
    _secteurCtrl = TextEditingController(text: d.secteurActivite);
  }
  @override
  void dispose() {
    _catCtrl.dispose();
    _revenuCtrl.dispose();
    _natureCtrl.dispose();
    _secteurCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final editing = _EditModeProvider.of(context);
    final d = widget.data;
    if (!editing) {
      return Column(children: [
        _DataRow(label: 'Catégorie socio-pro', value: d.categorieSocioPro),
        _DataRow(label: 'Revenu',              value: d.revenu),
        _DataRow(label: 'Nature activité',     value: d.natureActivite),
        _DataRow(label: 'Secteur activité',    value: d.secteurActivite),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _EditLabel('Catégorie socio-professionnelle'), const SizedBox(height: 6),
      _EditField(controller: _catCtrl, icon: Icons.work_outline_rounded,
          onChanged: (v) => widget.onUpdate('categorieSocioPro', v)),
      const SizedBox(height: 12),
      _EditLabel('Revenu'), const SizedBox(height: 6),
      _EditField(controller: _revenuCtrl, icon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          onChanged: (v) => widget.onUpdate('revenu', v)),
      const SizedBox(height: 12),
      _EditLabel("Nature de l'activité"), const SizedBox(height: 6),
      _EditField(controller: _natureCtrl,
          icon: Icons.business_center_outlined,
          onChanged: (v) => widget.onUpdate('natureActivite', v)),
      const SizedBox(height: 12),
      _EditLabel("Secteur d'activité"), const SizedBox(height: 6),
      _EditField(controller: _secteurCtrl, icon: Icons.category_outlined,
          onChanged: (v) => widget.onUpdate('secteurActivite', v)),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS UTILITAIRES
// ══════════════════════════════════════════════════════════════

class _DataRow extends StatelessWidget {
  final String label;
  final String? value;
  const _DataRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
  }
}

class _EditLabel extends StatelessWidget {
  final String text;
  const _EditLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelMedium);
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  const _EditField({
    required this.controller,
    required this.icon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    final iconSize  = Theme.of(context).iconTheme.size;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: iconSize, color: iconColor),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 18, color: iconColor)
            : null,
      ),
    );
  }
}

class _CiviliteChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CiviliteChip(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : const Color(0xFFDDD8CC),
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected
                  ? colorScheme.onPrimary
                  : const Color(0xFF666666),
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            )),
      ),
    );
  }
}

class _BoolToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _BoolToggle(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(children: [
      Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.labelMedium)),
      Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.secondary),
    ]);
  }
}

class _NbEnfantsCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _NbEnfantsCounter({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(children: [
      _CounterBtn(
          icon: Icons.remove_rounded,
          onTap: value > 0 ? () => onChanged(value - 1) : null,
          color: colorScheme.primary),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('$value',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 20)),
      ),
      _CounterBtn(
          icon: Icons.add_rounded,
          onTap: () => onChanged(value + 1),
          color: colorScheme.secondary),
    ]);
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _CounterBtn(
      {required this.icon, required this.onTap, required this.color});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18,
            color: onTap != null ? color : Colors.grey),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text('Impossible de charger le récapitulatif',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(error,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.redAccent),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ]),
      ),
    );
  }
}
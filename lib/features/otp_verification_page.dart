// otp_verification_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/adresse/views/address_page.dart';
import 'package:pfe_flutter/shared/services/notification_service.dart';
import 'package:pfe_flutter/shared/widgets/header_band.dart';
import 'package:pfe_flutter/shared/widgets/page_header.dart';
import 'package:pfe_flutter/shared/widgets/primary_button.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber; // ex: "+216 XX XXX XXX"
  final String initialCountryIso;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.initialCountryIso,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _otpLength = 6;
  static const int _resendDelay = 60; // secondes

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isVerifying = false;
  bool _hasError = false;
  int _secondsLeft = _resendDelay;
  Timer? _timer;

@override
void initState() {
  super.initState();

  _startTimer();

  // Auto-focus sur le premier champ
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _focusNodes[0].requestFocus();
  });

  // === Envoi de la notification OTP après 2 secondes ===
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      sendOtp();
    }
  });
}

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendDelay);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpValue =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpValue.length == _otpLength;

  void _onDigitChanged(int index, String value) {
    setState(() => _hasError = false);

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit quand le dernier chiffre est saisi
    if (index == _otpLength - 1 && value.isNotEmpty) {
      _focusNodes[index].unfocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }
// Quand tu reçois l'OTP (Firebase, API, etc.)
Future<void> sendOtp() async {
  String otp = "556432"; // ton code généré

  await NotificationService.showOtpNotification(
    otpCode: otp,
  );
}
  Future<void> _verify() async {
    if (!_isComplete) return;

    setState(() => _isVerifying = true);

    // ── Simulation délai réseau (à remplacer par l'appel API) ──
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isVerifying = false);

    // TODO: remplacer par la vraie validation backend
    // Pour l'instant on navigue directement vers AdressePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdressePage(
          initialCountryIso: widget.initialCountryIso,
        ),
      ),
    );
  }

  void _resendCode() {
    if (_secondsLeft > 0) return;
    // TODO: appeler le backend pour renvoyer le code
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _hasError = false);
    _focusNodes[0].requestFocus();
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code renvoyé avec succès !'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          HeaderBand(),
          SafeArea(
            child: Column(
              children: [
                PageHeader(
                  currentStep: 2,
                  totalSteps: 8,
                  title: 'Vérification',
                  subtitle: 'Confirmez votre numéro de téléphone',
                  onBack: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // ── Carte principale ──────────────────────
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ── Icône SMS ─────────────────────
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.sms_rounded,
                                  size: 30,
                                  color: colorScheme.secondary,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const SizedBox(height: 14),
// ── Info OTP ───────────────────────────────
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  ),
  decoration: BoxDecoration(
    color: colorScheme.secondary.withOpacity(0.08),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: colorScheme.secondary.withOpacity(0.25),
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.info_outline_rounded,
        size: 18,
        color: colorScheme.secondary,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          'Un code OTP sera envoyé pour vérifier votre numéro de téléphone.',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontSize: 12.8,
            height: 1.4,
          ),
        ),
      ),
    ],
  ),
),

                              // ── Texte explicatif ──────────────
                              Text(
                                'Code envoyé au',
                                style: textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF888888),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.phoneNumber,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ── Champs OTP ────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  _otpLength,
                                  (i) => _OtpBox(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    hasError: _hasError,
                                    onChanged: (v) => _onDigitChanged(i, v),
                                    onKeyEvent: (e) => _onKeyEvent(i, e),
                                  ),
                                ),
                              ),

                              if (_hasError) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline_rounded,
                                        size: 14, color: Colors.redAccent),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Code incorrect. Veuillez réessayer.',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 28),

                              // ── Bouton vérifier ───────────────
                              SizedBox(
                                width: double.infinity,
                                child: _isVerifying
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: colorScheme.secondary,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : PrimaryButton(
                                        text: 'Continuer',
                                        enabled: _isComplete,
                                        onPressed: _isComplete ? _verify : null,
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Renvoi du code ─────────────────────────
                        _ResendSection(
                          secondsLeft: _secondsLeft,
                          onResend: _resendCode,
                        ),
                      ],
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

// ════════════════════════════════════════════════════════════════
//  WIDGET — Case OTP individuelle
// ════════════════════════════════════════════════════════════════

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFilled = controller.text.isNotEmpty;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 54,
        decoration: BoxDecoration(
          color: hasError
              ? Colors.redAccent.withOpacity(0.06)
              : isFilled
                  ? colorScheme.secondary.withOpacity(0.08)
                  : Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError
                ? Colors.redAccent
                : isFilled
                    ? colorScheme.secondary
                    : focusNode.hasFocus
                        ? colorScheme.primary
                        : const Color(0xFFE5E0D5),
            width: isFilled || focusNode.hasFocus ? 1.8 : 1.0,
          ),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onChanged: onChanged,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: hasError ? Colors.redAccent : colorScheme.primary,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  WIDGET — Section renvoi du code
// ════════════════════════════════════════════════════════════════

class _ResendSection extends StatelessWidget {
  final int secondsLeft;
  final VoidCallback onResend;

  const _ResendSection({required this.secondsLeft, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canResend = secondsLeft == 0;

    return Column(
      children: [
        Text(
          'Vous n\'avez pas reçu le code ?',
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFF888888),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        if (!canResend)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined,
                  size: 15, color: const Color(0xFFAAAAAA)),
              const SizedBox(width: 6),
              Text(
                'Renvoyer dans ${secondsLeft}s',
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 12.5,
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: onResend,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: colorScheme.secondary.withOpacity(0.5), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 16, color: colorScheme.secondary),
                  const SizedBox(width: 7),
                  Text(
                    'Renvoyer le code',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
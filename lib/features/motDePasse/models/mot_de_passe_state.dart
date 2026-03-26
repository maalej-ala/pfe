// models/mot_de_passe_state.dart

enum PasswordStrength { empty, weak, medium, strong }

class MotDePasseState {
  final String motDePasse;
  final String confirmation;
  final bool motDePasseVisible;
  final bool confirmationVisible;

  const MotDePasseState({
    this.motDePasse = '',
    this.confirmation = '',
    this.motDePasseVisible = false,
    this.confirmationVisible = false,
  });

  // ── Force du mot de passe ──────────────────────────────────
  PasswordStrength get strength {
    if (motDePasse.isEmpty) return PasswordStrength.empty;

    int score = 0;
    if (motDePasse.length >= 8) score++;
    if (motDePasse.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(motDePasse)) score++;
    if (RegExp(r'[a-z]').hasMatch(motDePasse)) score++;
    if (RegExp(r'[0-9]').hasMatch(motDePasse)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(motDePasse)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  bool get isConfirmationMatch =>
      confirmation.isNotEmpty && motDePasse == confirmation;

  bool get isConfirmationError =>
      confirmation.isNotEmpty && motDePasse != confirmation;

  bool get isValid =>
      motDePasse.isNotEmpty &&
      confirmation.isNotEmpty &&
      motDePasse == confirmation &&
      strength != PasswordStrength.weak;

  // ── Critères détaillés ─────────────────────────────────────
  bool get hasMinLength => motDePasse.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(motDePasse);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(motDePasse);
  bool get hasDigit => RegExp(r'[0-9]').hasMatch(motDePasse);
  bool get hasSpecial =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(motDePasse);

  MotDePasseState copyWith({
    String? motDePasse,
    String? confirmation,
    bool? motDePasseVisible,
    bool? confirmationVisible,
  }) =>
      MotDePasseState(
        motDePasse: motDePasse ?? this.motDePasse,
        confirmation: confirmation ?? this.confirmation,
        motDePasseVisible: motDePasseVisible ?? this.motDePasseVisible,
        confirmationVisible: confirmationVisible ?? this.confirmationVisible,
      );
}
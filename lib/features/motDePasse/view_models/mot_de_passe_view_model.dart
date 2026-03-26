// view_models/mot_de_passe_view_model.dart

import 'package:flutter/foundation.dart';
import '../models/mot_de_passe_state.dart';

class MotDePasseViewModel extends ChangeNotifier {
  MotDePasseState _state = const MotDePasseState();

  MotDePasseState get state => _state;

  // ── Mise à jour du mot de passe ────────────────────────────
  void updateMotDePasse(String value) {
    _state = _state.copyWith(motDePasse: value);
    notifyListeners();
  }

  // ── Mise à jour de la confirmation ─────────────────────────
  void updateConfirmation(String value) {
    _state = _state.copyWith(confirmation: value);
    notifyListeners();
  }

  // ── Toggle visibilité mot de passe ─────────────────────────
  void toggleMotDePasseVisible() {
    _state = _state.copyWith(
      motDePasseVisible: !_state.motDePasseVisible,
    );
    notifyListeners();
  }

  // ── Toggle visibilité confirmation ─────────────────────────
  void toggleConfirmationVisible() {
    _state = _state.copyWith(
      confirmationVisible: !_state.confirmationVisible,
    );
    notifyListeners();
  }

  // ── Soumission (service ou navigation) ────────────────────
  Future<bool> soumettre() async {
    if (!_state.isValid) return false;
    // TODO: appel service (ex: AuthService.setPassword(_state.motDePasse))
    return true;
  }
}
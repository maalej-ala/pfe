import 'package:flutter/foundation.dart';

import '../models/identification_state.dart';

class IdentificationViewModel extends ChangeNotifier {
  IdentificationState _state = const IdentificationState();
  IdentificationState get state => _state;

  void updateCivilite(String value) {
    _state = _state.copyWith(civilite: value);
    notifyListeners();
  }

  void updateAccepteMentions(bool value) {
    _state = _state.copyWith(accepteMentions: value);
    notifyListeners();
  }

  void updateNom(String value) {
    _state = _state.copyWith(nom: value);
    notifyListeners();
  }

  void updatePrenom(String value) {
    _state = _state.copyWith(prenom: value);
    notifyListeners();
  }

  void updateTel(String value) {
    _state = _state.copyWith(tel: value);
    notifyListeners();
  }

  void updateEmail(String value) {
    _state = _state.copyWith(email: value);
    notifyListeners();
  }

  void updateDateNaissance(String value) {
    _state = _state.copyWith(dateNaissance: value);
    notifyListeners();
  }
}
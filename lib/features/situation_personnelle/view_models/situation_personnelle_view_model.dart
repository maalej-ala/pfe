import 'package:flutter/foundation.dart';
import 'package:pfe_flutter/features/situation_personnelle/models/situation_personnelle_model.dart';

class SituationPersonnelleViewModel extends ChangeNotifier {
  SituationPersonnelleState _state = const SituationPersonnelleState();
  SituationPersonnelleState get state => _state;

  void updateNationalite(String? value) {
    _state = _state.copyWith(nationalite: value);
    notifyListeners();
  }

  void updateStatutCivil(String? value) {
    _state = _state.copyWith(statutCivil: value);
    notifyListeners();
  }

  void updateNbEnfants(int value) {
    _state = _state.copyWith(nbEnfants: value);
    notifyListeners();
  }
}
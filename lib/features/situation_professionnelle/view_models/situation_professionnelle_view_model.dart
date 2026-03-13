import 'package:flutter/foundation.dart';
import 'package:pfe_flutter/features/situation_professionnelle/models/situation_professionnelle_model.dart';

class SituationProfessionnelleViewModel extends ChangeNotifier {
  SituationProfessionnelleState _state = const SituationProfessionnelleState();
  SituationProfessionnelleState get state => _state;

  void updateCategorieSocioPro(String? value) {
    _state = _state.copyWith(categorieSocioPro: value);
    notifyListeners();
  }

  void updateRevenu(String value) {
    _state = _state.copyWith(revenu: value);
    notifyListeners();
  }

  void updateNatureActivite(String? value) {
    _state = _state.copyWith(natureActivite: value);
    notifyListeners();
  }

  void updateSecteurActivite(String? value) {
    _state = _state.copyWith(secteurActivite: value);
    notifyListeners();
  }
}
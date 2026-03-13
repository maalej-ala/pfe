import 'package:flutter/foundation.dart';
import 'package:pfe_flutter/features/choix_bancaire/models/choix_bancaire_model.dart';

class ChoixBancaireViewModel extends ChangeNotifier {
  ChoixBancaireState _state = const ChoixBancaireState();
  ChoixBancaireState get state => _state;

  void updateAgence(String? value) {
    _state = _state.copyWith(agence: value);
    notifyListeners();
  }

  void updateTypeCarte(String? value) {
    _state = _state.copyWith(typeCarte: value);
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../models/mieux_vous_connaitre_state.dart';

class MieuxVousConnaitreViewModel extends ChangeNotifier {
  MieuxVousConnaitreState _state = const MieuxVousConnaitreState();
  MieuxVousConnaitreState get state => _state;

  void updateAdresse(String value) {
    _state = _state.copyWith(adresse: value);
    notifyListeners();
  }

  void updatePays(String? value) {
    _state = _state.copyWith(pays: value);
    notifyListeners();
  }

  void updateGouvernorat(String? value) {
    _state = _state.copyWith(gouvernorat: value);
    notifyListeners();
  }

  void updateCodePostal(String value) {
    _state = _state.copyWith(codePostal: value);
    notifyListeners();
  }

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

  void updateAgence(String? value) {
    _state = _state.copyWith(agence: value);
    notifyListeners();
  }

  void updateTypeCarte(String? value) {
    _state = _state.copyWith(typeCarte: value);
    notifyListeners();
  }

  void updateCin(String value) {
    _state = _state.copyWith(cin: value);
    notifyListeners();
  }

  void updateDateDelivrance(String value) {
    _state = _state.copyWith(dateDelivrance: value);
    notifyListeners();
  }

  void updateHasCinRecto(bool value) {
    _state = _state.copyWith(hasCinRecto: value);
    notifyListeners();
  }

  void updateHasCinVerso(bool value) {
    _state = _state.copyWith(hasCinVerso: value);
    notifyListeners();
  }

void updateConfirmeSansAmericanite(bool? value) {
  _state = _state.copyWith(confirmeSansAmericanite: value ?? false);
  notifyListeners();
}

void updateEstClientAutreBanque(bool? value) {
  _state = _state.copyWith(estClientAutreBanque: value ?? false);
  notifyListeners();
}

  void updateExpandedSection(int value) {
    _state = _state.copyWith(expandedSection: value);
    notifyListeners();
  }
}
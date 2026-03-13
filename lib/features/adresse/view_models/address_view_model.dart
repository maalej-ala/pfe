import 'package:flutter/foundation.dart';
import 'package:pfe_flutter/features/adresse/models/address_model.dart';

class AdresseViewModel extends ChangeNotifier {
  AdresseState _state = const AdresseState();
  AdresseState get state => _state;

  final List<String> pays = [
    'Tunisie',
    'France',
    'Algérie',
    'Maroc',
    'Autre'
  ];

  final List<String> gouvernorats = [
    'Ariana','Béja','Ben Arous','Bizerte','Gabès','Gafsa',
    'Jendouba','Kairouan','Kasserine','Kébili','Kef','Mahdia',
    'Manouba','Médenine','Monastir','Nabeul','Sfax','Sidi Bouzid',
    'Siliana','Sousse','Tataouine','Tozeur','Tunis','Zaghouan'
  ];
  
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
}
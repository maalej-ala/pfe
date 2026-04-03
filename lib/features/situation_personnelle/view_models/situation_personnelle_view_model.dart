import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/features/situation_personnelle/models/situation_personnelle_model.dart';

class SituationPersonnelleViewModel extends ChangeNotifier {
  SituationPersonnelleState _state = const SituationPersonnelleState();
  SituationPersonnelleState get state => _state;

Future<void> submitSituationPersonnelle() async {
  final response = await http.post(
    Uri.parse('http://10.20.30.18:8080/api/situation-personnelle'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nationalite': _state.nationalite,
      'statutCivil': _state.statutCivil,
      'nbEnfants':   _state.nbEnfants,
    }),
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Erreur inconnue');
  }
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
  
}
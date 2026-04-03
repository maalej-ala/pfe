import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/features/situation_professionnelle/models/situation_professionnelle_model.dart';

class SituationProfessionnelleViewModel extends ChangeNotifier {
  SituationProfessionnelleState _state = const SituationProfessionnelleState();
  SituationProfessionnelleState get state => _state;

Future<void> submitSituationProfessionnelle() async {
  try {
    final response = await http.post(
      Uri.parse('http://10.20.30.18:8080/api/situation-professionnelle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'categorieSocioPro': _state.categorieSocioPro,
        'revenu':            _state.revenu,
        'natureActivite':    _state.natureActivite,
        'secteurActivite':   _state.secteurActivite,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur inconnue');
    }
  } catch (e) {
    if (kDebugMode) print('Erreur submit: $e');
    rethrow;
  }
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
}
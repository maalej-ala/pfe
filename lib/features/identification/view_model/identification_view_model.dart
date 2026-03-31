import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/identification_state.dart';

class IdentificationViewModel extends ChangeNotifier {
  IdentificationState _state = const IdentificationState();
  IdentificationState get state => _state;

  // 🔹 URL de ton backend
  final String _baseUrl = "http://10.20.30.18:8080/api/identification"; 
  // ⚠️ Sur vrai appareil, remplacer localhost par l'IP de ton PC

  // ─────────── Mise à jour de l'état ───────────
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

void updatePhone(String full, String code, String number) {
  _state = _state.copyWith(
    fullPhone: full,
    countryCode: code,
    phoneNumber: number,
  );
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

  // ─────────── Service pour envoyer l'identification ───────────
  String formatDateForBackend(String date) {
  // date est "JJ/MM/AAAA"
  final parts = date.split('/');
  if (parts.length != 3) return date; // fallback
  final day = parts[0].padLeft(2, '0');
  final month = parts[1].padLeft(2, '0');
  final year = parts[2];
  return '$year-$month-$day'; // format yyyy-MM-dd
}
  Future<void> submitIdentification() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'civilite': _state.civilite,
          'nom': _state.nom,
          'prenom': _state.prenom,
          'email': _state.email,
          'telephone': _state.fullPhone,
  'dateNaissance': formatDateForBackend(_state.dateNaissance), // ✅ format ISO
          'accepteMentions': _state.accepteMentions,
        }),
      );

if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Succès");
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? "Erreur inconnue");
    }

  } catch (e) {
    if (kDebugMode) {
      print("Erreur HTTP : $e");
    }
    rethrow; // 🔥 important pour que le UI catch l'erreur
  }
  }
}
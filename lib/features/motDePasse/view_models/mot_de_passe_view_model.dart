// features/motDePasse/view_models/mot_de_passe_view_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/shared/constantes.dart';
import 'package:pfe_flutter/shared/services/device_service.dart';
import '../models/mot_de_passe_state.dart';

class MotDePasseViewModel extends ChangeNotifier {
  MotDePasseState _state = const MotDePasseState();
  MotDePasseState get state => _state;

  static const String _baseUrl =
      '${AppConstants.baseUrl}/api/mot-de-passe';

  // ── Mise à jour mot de passe ──────────────────────────────
  void updateMotDePasse(String value) {
    _state = _state.copyWith(motDePasse: value);
    notifyListeners();
  }

  // ── Mise à jour confirmation ──────────────────────────────
  void updateConfirmation(String value) {
    _state = _state.copyWith(confirmation: value);
    notifyListeners();
  }

  // ── Toggle visibilité mot de passe ────────────────────────
  void toggleMotDePasseVisible() {
    _state = _state.copyWith(motDePasseVisible: !_state.motDePasseVisible);
    notifyListeners();
  }

  // ── Toggle visibilité confirmation ────────────────────────
  void toggleConfirmationVisible() {
    _state =
        _state.copyWith(confirmationVisible: !_state.confirmationVisible);
    notifyListeners();
  }

  // ── Soumission + appel backend ────────────────────────────
  //
  // Retourne (true, null)       → succès
  // Retourne (false, null)      → validation locale échouée
  // Retourne (false, "message") → erreur réseau / serveur
  //
  Future<(bool success, String? errorMessage)> soumettre() async {
                final deviceId = await DeviceService().getDeviceId(); // 🔥 ici
  
    // 1. Validation locale
    if (!_state.isValid) return (false, null);

    try {
      final uri = Uri.parse(_baseUrl);

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'motDePasse': _state.motDePasse,
              'deviceId': deviceId
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Délai dépassé. Vérifiez votre connexion.'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ MotDePasse enregistré');
        return (true, null);
      }

      // Essaie de lire le message d'erreur Spring
      String serverMsg = 'Erreur ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        serverMsg = body['message'] ?? body['error'] ?? serverMsg;
      } catch (_) {}

      debugPrint('❌ Erreur serveur: $serverMsg');
      return (false, serverMsg);
    } catch (e) {
      debugPrint('🔥 Exception: $e');
      return (false, e.toString());
    }
  }
}
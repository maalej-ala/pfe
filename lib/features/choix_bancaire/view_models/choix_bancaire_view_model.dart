import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:pfe_flutter/features/choix_bancaire/models/choix_bancaire_model.dart';
import 'package:pfe_flutter/shared/constantes.dart';
import 'package:pfe_flutter/shared/services/device_service.dart';

class ChoixBancaireViewModel extends ChangeNotifier {

  ChoixBancaireState _state =
      const ChoixBancaireState();

  ChoixBancaireState get state => _state;

  // ═══════════════════════════════════════
  // UPDATE AGENCE
  // ═══════════════════════════════════════

  void updateAgence(String? value) {

    _state = _state.copyWith(
      agence: value,
    );

    notifyListeners();
  }

  // ═══════════════════════════════════════
  // UPDATE TYPE COMPTE
  // ═══════════════════════════════════════

  void updateTypeCompte(String? value) {

    _state = _state.copyWith(
      typeCompte: value,
    );

    notifyListeners();
  }

  // ═══════════════════════════════════════
  // UPDATE TYPE CARTE
  // ═══════════════════════════════════════

  void updateTypeCarte(String? value) {

    _state = _state.copyWith(
      typeCarte: value,
    );

    notifyListeners();
  }

  // ═══════════════════════════════════════
  // SAVE API
  // ═══════════════════════════════════════

  Future<bool> saveChoixBancaire() async {

    try {

      // validation
      if (!_state.isValid) {

        _state = _state.copyWith(
          error: 'Veuillez remplir tous les champs',
        );

        notifyListeners();

        return false;
      }

      // loading start
      _state = _state.copyWith(
        isLoading: true,
        error: null,
      );

      notifyListeners();

      // device id
    final deviceId = await DeviceService().getDeviceId();


      // request
      final response = await http.post(

        Uri.parse(
          '${AppConstants.baseUrl}/api/choix-bancaire',
        ),

        headers: {
          'Content-Type': 'application/json',
        },

        body: jsonEncode({

          'agence': _state.agence,

          'typeCompte': _state.typeCompte,

          'typeCarte': _state.typeCarte,

          'deviceId': deviceId,
        }),
      );

      // success
      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        _state = _state.copyWith(
          isLoading: false,
        );

        notifyListeners();

        return true;
      }

      // error api
      _state = _state.copyWith(
        isLoading: false,
        error:
            'Erreur serveur : ${response.statusCode}',
      );

      notifyListeners();

      return false;

    } catch (e) {

      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      notifyListeners();

      return false;
    }
  }

  // ═══════════════════════════════════════
  // RESET
  // ═══════════════════════════════════════

  void reset() {

    _state = const ChoixBancaireState();

    notifyListeners();
  }
}
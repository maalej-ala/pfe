// lib/features/verification_identite/view_models/verification_identite_view_model.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/features/verification_identite/models/verification_identite_model.dart';
import 'package:pfe_flutter/shared/services/device_service.dart';

class VerificationIdentiteViewModel extends ChangeNotifier {
  VerificationIdentiteState _state = const VerificationIdentiteState();
  VerificationIdentiteState get state => _state;

  // ── Soumission backend ────────────────────────────────────────────
  Future<bool> submitVerification({
    File? photoCin,
    File? photoVisageCin,
    File? photoVisageLive,
  }) async {
   // return true;  //////supreimer cette ligne et decommenter le code ci-dessous pour faire la vraie requete
    try {
                  final deviceId = await DeviceService().getDeviceId(); // 🔥 ici

      final uri = Uri.parse(
        'http://10.20.30.18:8080/api/verification-identite',
      );

      final request = http.MultipartRequest('POST', uri);

      // ── Champs texte ─────────────────────────────────────────────
      request.fields['cin'] = _state.cin;
      request.fields['deviceId'] = deviceId;  

      // Conversion "dd/MM/yyyy" → "yyyy-MM-dd" (format LocalDate Java)
      request.fields['dateDelivrance'] = _convertDate(_state.dateDelivrance);

      request.fields['estClientAutreBanque'] =
          _state.estClientAutreBanque.toString();

      // ── Images ───────────────────────────────────────────────────
      if (photoCin != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photoCin',
          photoCin.path,
        ));
      }

      if (photoVisageCin != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photoVisageCin',
          photoVisageCin.path,
        ));
      }

      if (photoVisageLive != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photoVisageLive',
          photoVisageLive.path,
        ));
      }

      // ── Envoi ────────────────────────────────────────────────────
      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Délai dépassé. Vérifiez votre connexion.'),
      );

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        debugPrint('✅ Succès: ${response.body}');
        return true;
      } else {
        debugPrint('❌ Erreur ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('🔥 Exception: $e');
      return false;
    }
  }

  // ── Utilitaire : "dd/MM/yyyy" → "yyyy-MM-dd" ─────────────────────
  String _convertDate(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return date; // déjà au bon format ou vide
  }

  // ── Mise à jour de l'état ─────────────────────────────────────────
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

  void updateVerificationsPhotosCompleted(bool value) {
    _state = _state.copyWith(verificationsPhotosCompleted: value);
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
}
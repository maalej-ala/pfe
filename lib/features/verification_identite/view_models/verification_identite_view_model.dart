// lib/features/verification_identite/view_models/verification_identite_view_model.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/features/verification_identite/models/verification_identite_model.dart';
import 'package:pfe_flutter/shared/constantes.dart';
import 'package:pfe_flutter/shared/services/device_service.dart';

class VerificationIdentiteViewModel extends ChangeNotifier {
  static const String _baseUrl = AppConstants.baseUrl; // 🔥 à ajuster selon votre config

  VerificationIdentiteState _state = const VerificationIdentiteState();
  VerificationIdentiteState get state => _state;

  // ── Résultat du backend après soumission ──────────────────────────
  VerificationResultModel? verificationResult;
  bool isSubmitting = false;
  String? errorMessage;

  // ── Soumission backend ────────────────────────────────────────────
  Future<bool> submitVerification({
    File? photoCin,
    File? photoVisageCin,
    File? photoVisageLive,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    verificationResult = null;
    notifyListeners();

    try {
      final deviceId = await DeviceService().getDeviceId();

      final uri = Uri.parse('$_baseUrl/api/verification-identite');
      final request = http.MultipartRequest('POST', uri);

      // ── Champs texte ─────────────────────────────────────────────
      request.fields['cin']                  = _state.cin;
      request.fields['deviceId']             = deviceId;
      request.fields['dateDelivrance']       = _convertDate(_state.dateDelivrance);
      request.fields['estClientAutreBanque'] = _state.estClientAutreBanque.toString();

      // ── Images ───────────────────────────────────────────────────
      if (photoCin != null) {
        request.files.add(
            await http.MultipartFile.fromPath('photoCin', photoCin.path));
      }
      if (photoVisageCin != null) {
        request.files.add(
            await http.MultipartFile.fromPath('photoVisageCin', photoVisageCin.path));
      }
      if (photoVisageLive != null) {
        request.files.add(
            await http.MultipartFile.fromPath('photoVisageLive', photoVisageLive.path));
      }

      // ── Envoi ────────────────────────────────────────────────────
      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () =>
            throw Exception('Délai dépassé. Vérifiez votre connexion.'),
      );

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        verificationResult = VerificationResultModel.fromJson(json);
        debugPrint('✅ OCR result: identiteVerifiee=${verificationResult!.identiteVerifiee}');
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Erreur ${response.statusCode} : ${response.body}';
        debugPrint('❌ $errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('🔥 Exception: $e');
      notifyListeners();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Utilitaire : "dd/MM/yyyy" → "yyyy-MM-dd" ─────────────────────
  String _convertDate(String date) {
    final parts = date.split('/');
    if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
    return date;
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
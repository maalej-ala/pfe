// features/recapitulatif/view_model/signature_edit_view_model.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/features/signature/model/signature_state.dart';
import 'package:pfe_flutter/shared/constantes.dart';

// ══════════════════════════════════════════════════════════════
//  SERVICE (intégré au ViewModel selon votre architecture)
// ══════════════════════════════════════════════════════════════
class _SignatureEditService {
  static const String _baseUrl = '${AppConstants.baseUrl}/api/signature';

  /// Charge les données existantes
  Future<SignatureEditModel> charger(String deviceId) async {
    final uri = Uri.parse('$_baseUrl/$deviceId');
    final response = await http.get(uri).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Délai dépassé. Vérifiez votre connexion.'),
        );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SignatureEditModel.fromJson(json);
    }
    throw Exception('Erreur ${response.statusCode} : ${response.body}');
  }

  /// Met à jour les données modifiées + signature
  Future<void> mettreAJour(String deviceId, SignatureEditModel model) async {
    final uri = Uri.parse('$_baseUrl/$deviceId');
    final response = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(model.toJson()),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Délai dépassé. Vérifiez votre connexion.'),
        );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }
  }

  /// Soumet le dossier final (confirmer et terminer)
  Future<void> soumettre(String deviceId) async {
    final uri = Uri.parse('$_baseUrl/$deviceId/soumettre');
    final response = await http.post(uri).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Délai dépassé. Vérifiez votre connexion.'),
        );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  VIEWMODEL
// ══════════════════════════════════════════════════════════════
class SignatureEditViewModel extends ChangeNotifier {
  final _service = _SignatureEditService();

  SignatureEditModel? _data;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────
  SignatureEditModel? get data => _data;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get hasSignature => _data?.hasSignature ?? false;

  // ── Chargement ────────────────────────────────────────────────
  Future<void> charger(String deviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.charger(deviceId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Mise à jour champ par champ ───────────────────────────────
  void updateField(String field, dynamic value) {
    if (_data == null) return;
    _data = _data!.copyWith(
      civilite:            field == 'civilite'           ? value as String? : null,
      nom:                 field == 'nom'                ? value as String? : null,
      prenom:              field == 'prenom'             ? value as String? : null,
      email:               field == 'email'              ? value as String? : null,
      telephone:           field == 'telephone'          ? value as String? : null,
      dateNaissance:       field == 'dateNaissance'      ? value as String? : null,
      cin:                 field == 'cin'                ? value as String? : null,
      dateDelivrance:      field == 'dateDelivrance'     ? value as String? : null,
      estClientAutreBanque:field == 'estClientAutreBanque'? value as bool? : null,
      adresse:             field == 'adresse'            ? value as String? : null,
      paysNom:             field == 'paysNom'            ? value as String? : null,
      gouvernorat:         field == 'gouvernorat'        ? value as String? : null,
      codePostal:          field == 'codePostal'         ? value as String? : null,
      nationalite:         field == 'nationalite'        ? value as String? : null,
      statutCivil:         field == 'statutCivil'        ? value as String? : null,
      nbEnfants:           field == 'nbEnfants'          ? value as int?    : null,
      categorieSocioPro:   field == 'categorieSocioPro'  ? value as String? : null,
      revenu:              field == 'revenu'             ? value as String? : null,
      natureActivite:      field == 'natureActivite'     ? value as String? : null,
      secteurActivite:     field == 'secteurActivite'    ? value as String? : null,
    );
    notifyListeners();
  }

  // ── Signature ─────────────────────────────────────────────────
  /// Reçoit les bytes PNG du SignaturePad et les encode en base64
  void setSignature(Uint8List pngBytes) {
    if (_data == null) return;
    final base64Str = base64Encode(pngBytes);
    _data = _data!.copyWith(signatureBase64: base64Str);
    notifyListeners();
  }

  void clearSignature() {
    if (_data == null) return;
    _data = _data!.copyWith(signatureBase64: '');
    notifyListeners();
  }

  // ── Sauvegarde des modifications ──────────────────────────────
  Future<void> sauvegarder(String deviceId) async {
    if (_data == null) return;
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.mettreAJour(deviceId, _data!);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Sauvegarde + soumission finale
  Future<void> confirmerEtTerminer(String deviceId) async {
    if (_data == null) return;
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.mettreAJour(deviceId, _data!);
      await _service.soumettre(deviceId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
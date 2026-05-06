import 'package:flutter/foundation.dart';
import 'package:pfe_flutter/shared/services/device_service.dart';
import '../models/identification_state.dart';
import '../models/identification_model.dart';
import '../services/identification_service.dart';

class IdentificationViewModel extends ChangeNotifier {
  IdentificationModel _model = const IdentificationModel();
  IdentificationModel get model => _model;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 🔹 URL de ton backend
  // final String _baseUrl = "${AppConstants.baseUrl}/api/identification"; 
  // ⚠️ Sur vrai appareil, remplacer localhost par l'IP de ton PC

  // ─────────── Mise à jour de l'état ───────────
  void updateCivilite(String value) {
    _model = _model.copyWith(civilite: value);
    notifyListeners();
  }

  void updateAccepteMentions(bool value) {
    _model = _model.copyWith(accepteMentions: value);
    notifyListeners();
  }

  void updateNom(String value) {
    _model = _model.copyWith(nom: value);
    notifyListeners();
  }

  void updatePrenom(String value) {
    _model = _model.copyWith(prenom: value);
    notifyListeners();
  }

void updatePhone(String full, String code, String number) {
  _model = _model.copyWith(
    fullPhone: full,
    countryCode: code,
    phoneNumber: number,
  );
  notifyListeners();
}

  void updateEmail(String value) {
    _model = _model.copyWith(email: value);
    notifyListeners();
  }

  void updateDateNaissance(String value) {
    _model = _model.copyWith(dateNaissance: value);
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
    final deviceId = await DeviceService().getDeviceId();
    
    try {
      final identificationModel = IdentificationModel(
        civilite: _model.civilite,
        nom: _model.nom,
        prenom: _model.prenom,
        email: _model.email,
        fullPhone: _model.fullPhone,
        dateNaissance: formatDateForBackend(_model.dateNaissance),
        accepteMentions: _model.accepteMentions,
        deviceId: deviceId,
      );

      await IdentificationService.saveIdentification(identificationModel);

      if (kDebugMode) {
        print("Identification sauvegardée avec succès");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la sauvegarde : $e");
      }
      rethrow;
    }
  }

  // ─────────── Charger les données depuis le backend ───────────
  Future<void> loadIdentificationFromBackend() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final deviceId = await DeviceService().getDeviceId();
      final identificationModel = await IdentificationService.getIdentification(deviceId);

      if (identificationModel != null) {
        // Convertir la date du format ISO (yyyy-MM-dd) vers le format UI (dd/MM/yyyy)
        String formattedDate = '';
        if (identificationModel.dateNaissance != null && identificationModel.dateNaissance!.isNotEmpty) {
          formattedDate = formatDateForUI(identificationModel.dateNaissance!);
        }

        // Séparer le numéro de téléphone complet
        String countryCode = '';
        String phoneNumber = '';
        String fullPhone = identificationModel.fullPhone ?? '';
        
        if (fullPhone.isNotEmpty) {
          // Supposer que le format est +216XXXXXXXX
          if (fullPhone.startsWith('+')) {
            // Extraire le code pays (ex: +216)
            final match = RegExp(r'^\+(\d{1,4})(.*)').firstMatch(fullPhone);
            if (match != null) {
              countryCode = match.group(1) ?? '';
              phoneNumber = match.group(2) ?? '';
            }
          } else {
            phoneNumber = fullPhone;
          }
        }

        _model = _model.copyWith(
          civilite: identificationModel.civilite ?? 'M',
          nom: identificationModel.nom ?? '',
          prenom: identificationModel.prenom ?? '',
          email: identificationModel.email ?? '',
          phoneNumber: phoneNumber,
          fullPhone: fullPhone,
          countryCode: countryCode,
          dateNaissance: formattedDate,
        );
      } else {
        // Aucune donnée trouvée pour ce deviceId, c'est normal pour un nouvel utilisateur
        if (kDebugMode) {
          print("Aucune donnée d'identification trouvée pour ce device");
        }
      }
    } catch (e) {
      _errorMessage = "Erreur lors du chargement des données: $e";
      if (kDebugMode) {
        print("Erreur lors du chargement des données d'identification: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Convertir la date du format ISO (yyyy-MM-dd) vers le format UI (dd/MM/yyyy)
  String formatDateForUI(String isoDate) {
    try {
      final parts = isoDate.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1];
        final day = parts[2];
        return '$day/$month/$year';
      }
      return isoDate;
    } catch (e) {
      return isoDate;
    }
  }

bool get isFormValid {
  return _model.civilite.isNotEmpty &&
         _model.nom.trim().isNotEmpty &&
         _model.prenom.trim().isNotEmpty &&
         _model.fullPhone.trim().isNotEmpty &&
         _model.email.trim().isNotEmpty &&
         _model.dateNaissance.trim().isNotEmpty &&
         _model.accepteMentions;
}

}
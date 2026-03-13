import 'package:flutter/foundation.dart';
import 'package:pfe_flutter/features/verification_identite/models/verification_identite_model.dart';

class VerificationIdentiteViewModel extends ChangeNotifier {
  VerificationIdentiteState _state = const VerificationIdentiteState();
  VerificationIdentiteState get state => _state;

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
import 'dart:convert';

import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/features/adresse/models/address_model.dart';

class AdresseViewModel extends ChangeNotifier {
  Future<void> submitAdresse() async {
  final response = await http.post(
    Uri.parse('http://10.20.30.18:8080/api/adresse'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'adresse':     _state.adresse,
      'paysNom':     _state.paysNom,
      'gouvernorat': _state.gouvernorat,
      'codePostal':  _state.codePostal,
    }),
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Erreur inconnue');
  }
}
  AdresseState _state = const AdresseState();
  AdresseState get state => _state;

  // ── Country / State data ─────────────────────────────────
  List<csc.Country> _allCountries = [];
  List<csc.State>   _statesOfCountry = [];

  List<csc.Country> get allCountries   => _allCountries;
  List<csc.State>   get statesOfCountry => _statesOfCountry;

  String? _pendingIso; // ← ajoute ce champ

  AdresseViewModel() {
    _init();
  }

Future<void> _init() async {
  _allCountries = await csc.getAllCountries();

  // ← applique l'ISO en attente si présent
  if (_pendingIso != null) {
    await setCountryFromIso(_pendingIso!);
    _pendingIso = null;
  } else {
    notifyListeners();
  }
}

  Future<void> _loadStates(String isoCode) async {
    _statesOfCountry = await csc.getStatesOfCountry(isoCode);
    // Reset gouvernorat when country changes
    _state = _state.copyWith(gouvernorat: null, clearGouvernorat: true);
    notifyListeners();
  }

  // ── Update handlers ──────────────────────────────────────
  void updateAdresse(String v) {
    _state = _state.copyWith(adresse: v);
    notifyListeners();
  }

Future<void> updatePays(csc.Country country) async {
  _state = _state.copyWith(
    paysIso: country.isoCode,
    paysNom: country.name,
    currency: country.currency, // ✅ AJOUT
  );
  await _loadStates(country.isoCode);
}

  void updateGouvernorat(String? v) {
    _state = _state.copyWith(gouvernorat: v);
    notifyListeners();
  }

  void updateCodePostal(String v) {
    _state = _state.copyWith(codePostal: v);
    notifyListeners();
  }

  Future<void> updateCountryFromPhone(String isoCode) async {
  if (_allCountries.isEmpty) return;

  try {
    final country = _allCountries.firstWhere(
      (c) => c.isoCode == isoCode,
    );

    _state = _state.copyWith(
      paysIso: country.isoCode,
      paysNom: country.name,
    );

    await _loadStates(country.isoCode);
  } catch (e) {
    // si pays non trouvé → ignore
  }
}




// Même chose dans setCountryFromIso et updateCountryFromPhone :
Future<void> setCountryFromIso(String isoCode) async {
  if (_allCountries.isEmpty) {
    _pendingIso = isoCode;
    return;
  }
  try {
    final country = _allCountries.firstWhere((c) => c.isoCode == isoCode);
    _state = _state.copyWith(
      paysIso: country.isoCode,
      paysNom: country.name,
      currency: country.currency , // ✅ AJOUT
    );
    await _loadStates(country.isoCode);
  } catch (_) {}
}


// Getter currency du pays sélectionné
String get selectedCurrency {
  if (_state.paysIso == null || _allCountries.isEmpty) return 'USD';
  try {
    final country = _allCountries.firstWhere(
      (c) => c.isoCode == _state.paysIso,
    );
    return country.currency ?? 'USD';
  } catch (_) {
    return 'USD';
  }
}

}
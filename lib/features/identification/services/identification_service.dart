import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pfe_flutter/shared/constantes.dart';
import '../models/identification_model.dart';

class IdentificationService {
  static const String _baseUrl = "${AppConstants.baseUrl}/api/identification";

  /// Récupère les données d'identification pour un deviceId donné
  static Future<IdentificationModel?> getIdentification(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/$deviceId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return IdentificationModel.fromJson(data);
      } else if (response.statusCode == 404) {
        // Aucune donnée trouvée pour ce deviceId
        return null;
      } else {
        throw Exception("Erreur lors du chargement des données: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion: $e");
    }
  }

  /// Sauvegarde les données d'identification
  static Future<void> saveIdentification(IdentificationModel identification) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(identification.toJson()),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? "Erreur inconnue");
      }
    } catch (e) {
      throw Exception("Erreur lors de la sauvegarde: $e");
    }
  }
}
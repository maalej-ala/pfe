import 'dart:io';

class TextRecognitionModel {
  final String? numero;
  final String? nom;
  final String? prenom;
  final String? dateNaissance;
  final String? sexe;
  final String? lieuNaissance;
  final String? profession;
  final String? dateDelivrance;
  final String? dateExpiration;

  // 🔥 NEW
  final File? cinImage;
  final File? faceImage;

  const TextRecognitionModel({
    this.numero,
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.sexe,
    this.lieuNaissance,
    this.profession,
    this.dateDelivrance,
    this.dateExpiration,
    this.cinImage,
    this.faceImage,
  });

  factory TextRecognitionModel.fromMap(
    Map<String, String?> map, {
    File? cinImage,
    File? faceImage,
  }) {
    return TextRecognitionModel(
      numero: map['numero'],
      nom: map['nom'],
      prenom: map['prenom'],
      dateNaissance: map['date_naissance'],
      sexe: map['sexe'],
      lieuNaissance: map['lieu_naissance'],
      profession: map['profession'],
      dateDelivrance: map['date_etablissement'],
      dateExpiration: map['date_expiration'],
      cinImage: cinImage,     // ✅ NEW
      faceImage: faceImage,   // ✅ NEW
    );
  }
}
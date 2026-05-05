// lib/features/verification_identite/models/verification_result_model.dart

class OcrExtraitModel {
  final String? numeroCin;
  final String? nom;
  final String? prenom;
  final String? dateNaissance;
  final String? sexe;
  final String? lieuNaissance;
  final String? profession;
  final String? dateEtablissement;
  final String? dateExpiration;
  final String? rawText;

  const OcrExtraitModel({
    this.numeroCin,
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.sexe,
    this.lieuNaissance,
    this.profession,
    this.dateEtablissement,
    this.dateExpiration,
    this.rawText,
  });

  factory OcrExtraitModel.fromJson(Map<String, dynamic> json) =>
      OcrExtraitModel(
        numeroCin:         json['numeroCin'],
        nom:               json['nom'],
        prenom:            json['prenom'],
        dateNaissance:     json['dateNaissance'],
        sexe:              json['sexe'],
        lieuNaissance:     json['lieuNaissance'],
        profession:        json['profession'],
        dateEtablissement: json['dateEtablissement'],
        dateExpiration:    json['dateExpiration'],
        rawText:           json['rawText'],
      );
}

class VerificationResultModel {
  final OcrExtraitModel? ocrExtrait;
  final String? cinSaisi;
  final String? dateDelivranceSaisie;
  final bool cinValide;
  final bool nomValide;
  final bool prenomValide;
  final bool identiteVerifiee;
  final String? message;
  final String? cinOcr;
  final String? nomOcr;
  final String? prenomOcr;

  const VerificationResultModel({
    this.ocrExtrait,
    this.cinSaisi,
    this.dateDelivranceSaisie,
    this.cinValide = false,
    this.nomValide = false,
    this.prenomValide = false,
    this.identiteVerifiee = false,
    this.message,
    this.cinOcr,
    this.nomOcr,
    this.prenomOcr,
  });

  factory VerificationResultModel.fromJson(Map<String, dynamic> json) =>
      VerificationResultModel(
        ocrExtrait: json['ocrExtrait'] != null
            ? OcrExtraitModel.fromJson(json['ocrExtrait'])
            : null,
        cinSaisi:            json['cinSaisi'],
        dateDelivranceSaisie:json['dateDelivranceSaisie'],
        cinValide:           json['cinValide'] ?? false,
        nomValide:           json['nomValide'] ?? false,
        prenomValide:        json['prenomValide'] ?? false,
        identiteVerifiee:    json['identiteVerifiee'] ?? false,
        message:             json['message'],
        cinOcr:              json['cinOcr'],
        nomOcr:              json['nomOcr'],
        prenomOcr:           json['prenomOcr'],
      );
}
class VerificationIdentiteState {
  final String cin;
  final String dateDelivrance;
  final bool hasCinRecto;
  final bool hasCinVerso;
  final bool verificationsPhotosCompleted;
  final bool confirmeSansAmericanite;
  final bool estClientAutreBanque;

  const VerificationIdentiteState({
    this.cin = '',
    this.dateDelivrance = '',
    this.hasCinRecto = false,
    this.hasCinVerso = false,
    this.verificationsPhotosCompleted = false,
    this.confirmeSansAmericanite = false,
    this.estClientAutreBanque = false,
  });

  VerificationIdentiteState copyWith({
    String? cin,
    String? dateDelivrance,
    bool? hasCinRecto,
    bool? hasCinVerso,
    bool? verificationsPhotosCompleted,
    bool? confirmeSansAmericanite,
    bool? estClientAutreBanque,
  }) {
    return VerificationIdentiteState(
      cin: cin ?? this.cin,
      dateDelivrance: dateDelivrance ?? this.dateDelivrance,
      hasCinRecto: hasCinRecto ?? this.hasCinRecto,
      hasCinVerso: hasCinVerso ?? this.hasCinVerso,
      verificationsPhotosCompleted:
          verificationsPhotosCompleted ?? this.verificationsPhotosCompleted,
      confirmeSansAmericanite:
          confirmeSansAmericanite ?? this.confirmeSansAmericanite,
      estClientAutreBanque:
          estClientAutreBanque ?? this.estClientAutreBanque,
    );
  }

  bool get isValid => true;
}
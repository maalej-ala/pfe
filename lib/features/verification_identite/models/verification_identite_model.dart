// lib/features/verification_identite/models/verification_result_model.dart

// Model for the API response from GET /api/verification-identite/device/{deviceId}
class VerificationIdentiteApiResponse {
  final int? id;
  final String? cin;
  final String? dateDelivrance;
  final String? dateExpiration;
  final bool estClientAutreBanque;
  final String? photoCinPath;
  final String? photoVisageCinPath;
  final String? photoVisageLivePath;
  final IdentificationData? identification;

  const VerificationIdentiteApiResponse({
    this.id,
    this.cin,
    this.dateDelivrance,
    this.dateExpiration,
    this.estClientAutreBanque = false,
    this.photoCinPath,
    this.photoVisageCinPath,
    this.photoVisageLivePath,
    this.identification,
  });

  factory VerificationIdentiteApiResponse.fromJson(Map<String, dynamic> json) {
    return VerificationIdentiteApiResponse(
      id: json['id'],
      cin: json['cin'],
      dateDelivrance: json['dateDelivrance'],
      dateExpiration: json['dateExpiration'],
      estClientAutreBanque: json['estClientAutreBanque'] ?? false,
      photoCinPath: json['photoCinPath'],
      photoVisageCinPath: json['photoVisageCinPath'],
      photoVisageLivePath: json['photoVisageLivePath'],
      identification: json['identification'] != null
          ? IdentificationData.fromJson(json['identification'])
          : null,
    );
  }
}

class IdentificationData {
  final int? id;
  final String? civilite;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final String? dateNaissance;
  final bool accepteMentions;
  final String? deviceId;

  const IdentificationData({
    this.id,
    this.civilite,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.dateNaissance,
    this.accepteMentions = false,
    this.deviceId,
  });

  factory IdentificationData.fromJson(Map<String, dynamic> json) {
    return IdentificationData(
      id: json['id'],
      civilite: json['civilite'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      dateNaissance: json['dateNaissance'],
      accepteMentions: json['accepteMentions'] ?? false,
      deviceId: json['deviceId'],
    );
  }
}

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
  final String dateExpiration;
  final bool hasCinRecto;
  final bool hasCinVerso;
  final bool verificationsPhotosCompleted;
  final bool confirmeSansAmericanite;
  final bool estClientAutreBanque;

  const VerificationIdentiteState({
    this.cin = '',
    this.dateExpiration = '',
    this.hasCinRecto = false,
    this.hasCinVerso = false,
    this.verificationsPhotosCompleted = false,
    this.confirmeSansAmericanite = false,
    this.estClientAutreBanque = false,
  });

  VerificationIdentiteState copyWith({
    String? cin,
    String? dateExpiration,
    bool? hasCinRecto,
    bool? hasCinVerso,
    bool? verificationsPhotosCompleted,
    bool? confirmeSansAmericanite,
    bool? estClientAutreBanque,
  }) {
    return VerificationIdentiteState(
      cin: cin ?? this.cin,
      dateExpiration: dateExpiration ?? this.dateExpiration,
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
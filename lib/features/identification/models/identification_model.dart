class IdentificationModel {
  final String civilite;
  final bool accepteMentions;
  final String nom;
  final String prenom;

  final String fullPhone;
  final String countryCode;
  final String phoneNumber;

  final String email;
  final String dateNaissance;
  final String cin;
  final String dateExpiration;

  final String deviceId;

  const IdentificationModel({
    this.civilite = 'M.',
    this.accepteMentions = false,
    this.nom = '',
    this.prenom = '',
    this.fullPhone = '',
    this.countryCode = '',
    this.phoneNumber = '',
    this.email = '',
    this.dateNaissance = '',
    this.cin = '9876-543-2198',
    this.dateExpiration = '01/01/2030',
    this.deviceId = '',
  });

  // ✅ copyWith (STATE MANAGEMENT)
  IdentificationModel copyWith({
    String? civilite,
    bool? accepteMentions,
    String? nom,
    String? prenom,
    String? fullPhone,
    String? countryCode,
    String? phoneNumber,
    String? email,
    String? dateNaissance,
    String? cin,
    String? dateExpiration,
    String? deviceId,
  }) {
    return IdentificationModel(
      civilite: civilite ?? this.civilite,
      accepteMentions: accepteMentions ?? this.accepteMentions,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      fullPhone: fullPhone ?? this.fullPhone,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      cin: cin ?? this.cin,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  // ✅ JSON
  factory IdentificationModel.fromJson(Map<String, dynamic> json) {
    return IdentificationModel(
      civilite: json['civilite'] ?? 'M.',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      fullPhone: json['telephone'] ?? '',
      dateNaissance: json['dateNaissance'] ?? '',
    // ✅ CORRECTION ICI
    cin: json['cin'] ?? '9876-543-2198',
    dateExpiration: json['dateExpiration'] ?? '01/01/2030',

      accepteMentions: json['accepteMentions'] ?? false,
      deviceId: json['deviceId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'civilite': civilite,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': fullPhone,
      'dateNaissance': dateNaissance,
      'cin': cin,
      'dateExpiration': dateExpiration,
      'accepteMentions': accepteMentions,
      'deviceId': deviceId,
    };
  }
}
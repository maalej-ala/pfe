class IdentificationState {
  final String civilite;
  final bool accepteMentions;
  final String nom;
  final String prenom;

  final String fullPhone;     // ✅ +21612345678
  final String countryCode;   // ✅ +216
  final String phoneNumber;   // ✅ 12345678

  final String email;
  final String dateNaissance;

  const IdentificationState({
    this.civilite = 'M.',
    this.accepteMentions = false,
    this.nom = '',
    this.prenom = '',
    this.fullPhone = '',
    this.countryCode = '',
    this.phoneNumber = '',
    this.email = '',
    this.dateNaissance = '',
  });

  IdentificationState copyWith({
    String? civilite,
    bool? accepteMentions,
    String? nom,
    String? prenom,
    String? fullPhone,
    String? countryCode,
    String? phoneNumber,
    String? email,
    String? dateNaissance,
  }) {
    return IdentificationState(
      civilite: civilite ?? this.civilite,
      accepteMentions: accepteMentions ?? this.accepteMentions,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      fullPhone: fullPhone ?? this.fullPhone,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dateNaissance: dateNaissance ?? this.dateNaissance,
    );
  }
}
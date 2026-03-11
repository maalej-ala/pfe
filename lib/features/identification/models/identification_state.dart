class IdentificationState {
  final String civilite;
  final bool accepteMentions;
  final String nom;
  final String prenom;
  final String tel;
  final String email;
  final String dateNaissance;

  const IdentificationState({
    this.civilite = 'M.',
    this.accepteMentions = false,
    this.nom = '',
    this.prenom = '',
    this.tel = '',
    this.email = '',
    this.dateNaissance = '',
  });

  IdentificationState copyWith({
    String? civilite,
    bool? accepteMentions,
    String? nom,
    String? prenom,
    String? tel,
    String? email,
    String? dateNaissance,
  }) {
    return IdentificationState(
      civilite: civilite ?? this.civilite,
      accepteMentions: accepteMentions ?? this.accepteMentions,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      tel: tel ?? this.tel,
      email: email ?? this.email,
      dateNaissance: dateNaissance ?? this.dateNaissance,
    );
  }
}
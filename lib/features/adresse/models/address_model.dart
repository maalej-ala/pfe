class AdresseState {
  final String adresse;
  final String? pays;
  final String? gouvernorat;
  final String codePostal;

  const AdresseState({
    this.adresse = '',
    this.pays = 'Tunisie',
    this.gouvernorat,
    this.codePostal = '',
  });

  AdresseState copyWith({
    String? adresse,
    String? pays,
    String? gouvernorat,
    String? codePostal,
  }) {
    return AdresseState(
      adresse: adresse ?? this.adresse,
      pays: pays ?? this.pays,
      gouvernorat: gouvernorat ?? this.gouvernorat,
      codePostal: codePostal ?? this.codePostal,
    );
  }

  bool get isValid =>
      adresse.isNotEmpty &&
      pays != null &&
      gouvernorat != null &&
      codePostal.isNotEmpty;
}
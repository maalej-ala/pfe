class AdresseState {
  final String adresse;
  final String? paysIso;
  final String? paysNom;
  final String? gouvernorat;
  final String codePostal;
  final String currency; // ✅ AJOUT

  const AdresseState({
    this.adresse = '',
    this.paysIso,
    this.paysNom,
    this.gouvernorat,
    this.codePostal = '',
    this.currency = 'USD', // ✅ VALEUR PAR DÉFAUT
  });

  bool get isValid =>true;
      //adresse.isNotEmpty &&
     // paysIso != null &&
      //gouvernorat != null &&
      //codePostal.isNotEmpty;

  AdresseState copyWith({
    String? adresse,
    String? paysIso,
    String? paysNom,
    String? gouvernorat,
    String? codePostal,
    // Flag to explicitly null-out gouvernorat on country change
    bool clearGouvernorat = false,
        String? currency, // ✅ AJOUT

  }) =>
      AdresseState(
        adresse:      adresse      ?? this.adresse,
        paysIso:      paysIso      ?? this.paysIso,
        paysNom:      paysNom      ?? this.paysNom,
        gouvernorat:  clearGouvernorat ? null : (gouvernorat ?? this.gouvernorat),
        codePostal:   codePostal   ?? this.codePostal,
              currency: currency ?? this.currency, // ✅ AJOUT

      );
}
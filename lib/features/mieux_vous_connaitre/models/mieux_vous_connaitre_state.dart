class MieuxVousConnaitreState {
  final String adresse;
  final String? pays;
  final String? gouvernorat;
  final String codePostal;
  final String? nationalite;
  final String? statutCivil;
  final int nbEnfants;
  final String? categorieSocioPro;
  final String revenu;
  final String? natureActivite;
  final String? secteurActivite;
  final String? agence;
  final String? typeCarte;
  final String cin;
  final String dateDelivrance;
  final bool hasCinRecto;
  final bool hasCinVerso;
  final bool confirmeSansAmericanite;
  final bool estClientAutreBanque;
  final int expandedSection;

  const MieuxVousConnaitreState({
    this.adresse = '',
    this.pays = 'Tunisie',
    this.gouvernorat,
    this.codePostal = '',
    this.nationalite,
    this.statutCivil,
    this.nbEnfants = 0,
    this.categorieSocioPro,
    this.revenu = '',
    this.natureActivite,
    this.secteurActivite,
    this.agence,
    this.typeCarte,
    this.cin = '',
    this.dateDelivrance = '',
    this.hasCinRecto = false,
    this.hasCinVerso = false,
    this.confirmeSansAmericanite = false,
    this.estClientAutreBanque = false,
    this.expandedSection = 0,
  });

  MieuxVousConnaitreState copyWith({
    String? adresse,
    String? pays,
    String? gouvernorat,
    String? codePostal,
    String? nationalite,
    String? statutCivil,
    int? nbEnfants,
    String? categorieSocioPro,
    String? revenu,
    String? natureActivite,
    String? secteurActivite,
    String? agence,
    String? typeCarte,
    String? cin,
    String? dateDelivrance,
    bool? hasCinRecto,
    bool? hasCinVerso,
    bool? confirmeSansAmericanite,
    bool? estClientAutreBanque,
    int? expandedSection,
  }) {
    return MieuxVousConnaitreState(
      adresse: adresse ?? this.adresse,
      pays: pays ?? this.pays,
      gouvernorat: gouvernorat ?? this.gouvernorat,
      codePostal: codePostal ?? this.codePostal,
      nationalite: nationalite ?? this.nationalite,
      statutCivil: statutCivil ?? this.statutCivil,
      nbEnfants: nbEnfants ?? this.nbEnfants,
      categorieSocioPro: categorieSocioPro ?? this.categorieSocioPro,
      revenu: revenu ?? this.revenu,
      natureActivite: natureActivite ?? this.natureActivite,
      secteurActivite: secteurActivite ?? this.secteurActivite,
      agence: agence ?? this.agence,
      typeCarte: typeCarte ?? this.typeCarte,
      cin: cin ?? this.cin,
      dateDelivrance: dateDelivrance ?? this.dateDelivrance,
      hasCinRecto: hasCinRecto ?? this.hasCinRecto,
      hasCinVerso: hasCinVerso ?? this.hasCinVerso,
      confirmeSansAmericanite: confirmeSansAmericanite ?? this.confirmeSansAmericanite,
      estClientAutreBanque: estClientAutreBanque ?? this.estClientAutreBanque,
      expandedSection: expandedSection ?? this.expandedSection,
    );
  }
}
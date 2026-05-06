// features/recapitulatif/model/signature_edit_model.dart

class SignatureEditModel {
  // ── Identité ──────────────────────────────────────────────────
  final String? civilite;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final String? dateNaissance;

  // ── CIN ───────────────────────────────────────────────────────
  final String? cin;
  final String? dateExpiration;
  final bool estClientAutreBanque;

  // ── Adresse ───────────────────────────────────────────────────
  final String? adresse;
  final String? paysNom;
  final String? gouvernorat;
  final String? codePostal;

  // ── Situation personnelle ─────────────────────────────────────
  final String? nationalite;
  final String? statutCivil;
  final int nbEnfants;

  // ── Situation professionnelle ─────────────────────────────────
  final String? categorieSocioPro;
  final String? revenu;
  final String? natureActivite;
  final String? secteurActivite;

  // ── Signature ────────────────────────────────────────────────
  final String? signatureBase64; // PNG encodé en base64

  const SignatureEditModel({
    this.civilite,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.dateNaissance,
    this.cin,
    this.dateExpiration,
    this.estClientAutreBanque = false,
    this.adresse,
    this.paysNom,
    this.gouvernorat,
    this.codePostal,
    this.nationalite,
    this.statutCivil,
    this.nbEnfants = 0,
    this.categorieSocioPro,
    this.revenu,
    this.natureActivite,
    this.secteurActivite,
    this.signatureBase64,
  });

  factory SignatureEditModel.fromJson(Map<String, dynamic> json) =>
      SignatureEditModel(
        civilite: json['civilite'],
        nom: json['nom'],
        prenom: json['prenom'],
        email: json['email'],
        telephone: json['telephone'],
        dateNaissance: json['dateNaissance'],
        cin: json['cin'],
        dateExpiration: json['dateExpiration'],
        estClientAutreBanque: json['estClientAutreBanque'] ?? false,
        adresse: json['adresse'],
        paysNom: json['paysNom'],
        gouvernorat: json['gouvernorat'],
        codePostal: json['codePostal'],
        nationalite: json['nationalite'],
        statutCivil: json['statutCivil'],
        nbEnfants: json['nbEnfants'] ?? 0,
        categorieSocioPro: json['categorieSocioPro'],
        revenu: json['revenu'],
        natureActivite: json['natureActivite'],
        secteurActivite: json['secteurActivite'],
        signatureBase64: json['signatureBase64'],
      );

  Map<String, dynamic> toJson() => {
        'civilite': civilite,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'dateNaissance': dateNaissance,
        'cin': cin,
        'dateExpiration': dateExpiration,
        'estClientAutreBanque': estClientAutreBanque,
        'adresse': adresse,
        'paysNom': paysNom,
        'gouvernorat': gouvernorat,
        'codePostal': codePostal,
        'nationalite': nationalite,
        'statutCivil': statutCivil,
        'nbEnfants': nbEnfants,
        'categorieSocioPro': categorieSocioPro,
        'revenu': revenu,
        'natureActivite': natureActivite,
        'secteurActivite': secteurActivite,
        'signatureBase64': signatureBase64,
      };

  /// Copie avec modification de champs spécifiques
  SignatureEditModel copyWith({
    String? civilite,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? dateNaissance,
    String? cin,
    String? dateExpiration,
    bool? estClientAutreBanque,
    String? adresse,
    String? paysNom,
    String? gouvernorat,
    String? codePostal,
    String? nationalite,
    String? statutCivil,
    int? nbEnfants,
    String? categorieSocioPro,
    String? revenu,
    String? natureActivite,
    String? secteurActivite,
    String? signatureBase64,
  }) =>
      SignatureEditModel(
        civilite: civilite ?? this.civilite,
        nom: nom ?? this.nom,
        prenom: prenom ?? this.prenom,
        email: email ?? this.email,
        telephone: telephone ?? this.telephone,
        dateNaissance: dateNaissance ?? this.dateNaissance,
        cin: cin ?? this.cin,
        dateExpiration: dateExpiration ?? this.dateExpiration,
        estClientAutreBanque: estClientAutreBanque ?? this.estClientAutreBanque,
        adresse: adresse ?? this.adresse,
        paysNom: paysNom ?? this.paysNom,
        gouvernorat: gouvernorat ?? this.gouvernorat,
        codePostal: codePostal ?? this.codePostal,
        nationalite: nationalite ?? this.nationalite,
        statutCivil: statutCivil ?? this.statutCivil,
        nbEnfants: nbEnfants ?? this.nbEnfants,
        categorieSocioPro: categorieSocioPro ?? this.categorieSocioPro,
        revenu: revenu ?? this.revenu,
        natureActivite: natureActivite ?? this.natureActivite,
        secteurActivite: secteurActivite ?? this.secteurActivite,
        signatureBase64: signatureBase64 ?? this.signatureBase64,
      );

  bool get hasSignature =>
      signatureBase64 != null && signatureBase64!.isNotEmpty;
}
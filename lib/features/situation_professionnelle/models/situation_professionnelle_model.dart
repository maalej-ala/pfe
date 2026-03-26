class SituationProfessionnelleState {
  final String? categorieSocioPro;
  final String revenu;
  final String? natureActivite;
  final String? secteurActivite;

  const SituationProfessionnelleState({
    this.categorieSocioPro,
    this.revenu = '',
    this.natureActivite,
    this.secteurActivite,
  });

  SituationProfessionnelleState copyWith({
    String? categorieSocioPro,
    String? revenu,
    String? natureActivite,
    String? secteurActivite,
  }) {
    return SituationProfessionnelleState(
      categorieSocioPro: categorieSocioPro ?? this.categorieSocioPro,
      revenu: revenu ?? this.revenu,
      natureActivite: natureActivite ?? this.natureActivite,
      secteurActivite: secteurActivite ?? this.secteurActivite,
    );
  }

  bool get isValid =>true;
      // categorieSocioPro != null &&
      // revenu.isNotEmpty &&
      // natureActivite != null &&
      // secteurActivite != null;
}
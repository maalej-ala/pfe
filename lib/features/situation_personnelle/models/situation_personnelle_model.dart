class SituationPersonnelleState {
  final String? nationalite;
  final String? statutCivil;
  final String? statutResidence;
  final int nbEnfants;

  const SituationPersonnelleState({
    this.nationalite='Tunisienne',
    this.statutCivil,
    this.statutResidence,
    this.nbEnfants = 0,
  });

  SituationPersonnelleState copyWith({
    String? nationalite,
    String? statutCivil,
    String? statutResidence,

    int? nbEnfants,
  }) {
    return SituationPersonnelleState(
      nationalite: nationalite ?? this.nationalite,
      statutCivil: statutCivil ?? this.statutCivil,
      statutResidence: statutResidence ?? this.statutResidence,
      nbEnfants: nbEnfants ?? this.nbEnfants,
    );
  }

  bool get isValid => nationalite != null && statutCivil != null && statutResidence != null;
}
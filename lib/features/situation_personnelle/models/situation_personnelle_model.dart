class SituationPersonnelleState {
  final String? nationalite;
  final String? statutCivil;
  final int nbEnfants;

  const SituationPersonnelleState({
    this.nationalite,
    this.statutCivil,
    this.nbEnfants = 0,
  });

  SituationPersonnelleState copyWith({
    String? nationalite,
    String? statutCivil,
    int? nbEnfants,
  }) {
    return SituationPersonnelleState(
      nationalite: nationalite ?? this.nationalite,
      statutCivil: statutCivil ?? this.statutCivil,
      nbEnfants: nbEnfants ?? this.nbEnfants,
    );
  }

  bool get isValid => nationalite != null && statutCivil != null;
}
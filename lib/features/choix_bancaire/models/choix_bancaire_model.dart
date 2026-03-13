class ChoixBancaireState {
  final String? agence;
  final String? typeCarte;

  const ChoixBancaireState({
    this.agence,
    this.typeCarte,
  });

  ChoixBancaireState copyWith({
    String? agence,
    String? typeCarte,
  }) {
    return ChoixBancaireState(
      agence: agence ?? this.agence,
      typeCarte: typeCarte ?? this.typeCarte,
    );
  }

  bool get isValid => agence != null && typeCarte != null;
}
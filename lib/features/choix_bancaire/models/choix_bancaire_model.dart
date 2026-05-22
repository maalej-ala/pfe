class ChoixBancaireState {
  final String? agence;
  final String? typeCompte;
  final String? typeCarte;

  final bool isLoading;
  final String? error;

  const ChoixBancaireState({
    this.agence,
    this.typeCompte,
    this.typeCarte,
    this.isLoading = false,
    this.error,
  });

  ChoixBancaireState copyWith({
    String? agence,
    String? typeCompte,
    String? typeCarte,
    bool? isLoading,
    String? error,
  }) {
    return ChoixBancaireState(
      agence: agence ?? this.agence,
      typeCompte: typeCompte ?? this.typeCompte,
      typeCarte: typeCarte ?? this.typeCarte,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isValid =>
      agence != null &&
      typeCompte != null &&
      typeCarte != null;
}
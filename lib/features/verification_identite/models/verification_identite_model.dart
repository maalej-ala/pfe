class VerificationIdentiteState {
  final String cin;
  final String dateDelivrance;
  final bool hasCinRecto;
  final bool hasCinVerso;
  final bool verificationsPhotosCompleted;
  final bool confirmeSansAmericanite;
  final bool estClientAutreBanque;

  const VerificationIdentiteState({
    this.cin = '',
    this.dateDelivrance = '',
    this.hasCinRecto = false,
    this.hasCinVerso = false,
    this.verificationsPhotosCompleted = false,
    this.confirmeSansAmericanite = false,
    this.estClientAutreBanque = false,
  });

  VerificationIdentiteState copyWith({
    String? cin,
    String? dateDelivrance,
    bool? hasCinRecto,
    bool? hasCinVerso,
    bool? verificationsPhotosCompleted,
    bool? confirmeSansAmericanite,
    bool? estClientAutreBanque,
  }) {
    return VerificationIdentiteState(
      cin: cin ?? this.cin,
      dateDelivrance: dateDelivrance ?? this.dateDelivrance,
      hasCinRecto: hasCinRecto ?? this.hasCinRecto,
      hasCinVerso: hasCinVerso ?? this.hasCinVerso,
      verificationsPhotosCompleted:
          verificationsPhotosCompleted ?? this.verificationsPhotosCompleted,
      confirmeSansAmericanite:
          confirmeSansAmericanite ?? this.confirmeSansAmericanite,
      estClientAutreBanque: estClientAutreBanque ?? this.estClientAutreBanque,
    );
  }

  bool get isValid =>true;
      // cin.length == 8 &&
      // dateDelivrance.isNotEmpty &&
      // hasCinRecto &&
      // hasCinVerso &&
      // verificationsPhotosCompleted &&
      // confirmeSansAmericanite;
}
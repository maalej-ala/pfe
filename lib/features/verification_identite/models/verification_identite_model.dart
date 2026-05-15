// lib/features/verification_identite/models/verification_result_model.dart

// Model for the API response from GET /api/verification-identite/device/{deviceId}
class VerificationIdentiteApiResponse {
  final int? id;

  final bool estClientAutreBanque;

  final String? photoVisageLivePath;

  const VerificationIdentiteApiResponse({
    this.id,

    this.estClientAutreBanque = false,
    this.photoVisageLivePath,
  });

  factory VerificationIdentiteApiResponse.fromJson(Map<String, dynamic> json) {
    return VerificationIdentiteApiResponse(
      id: json['id'],

      estClientAutreBanque: json['estClientAutreBanque'] ?? false,
      photoVisageLivePath: json['photoVisageLivePath'],

    );
  }
}


class VerificationIdentiteState {

  final bool verificationsPhotosCompleted;
  final bool confirmeSansAmericanite;
  final bool estClientAutreBanque;

  const VerificationIdentiteState({

    this.verificationsPhotosCompleted = false,
    this.confirmeSansAmericanite = false,
    this.estClientAutreBanque = false,
  });

  VerificationIdentiteState copyWith({

    bool? verificationsPhotosCompleted,
    bool? confirmeSansAmericanite,
    bool? estClientAutreBanque,
  }) {
    return VerificationIdentiteState(

      verificationsPhotosCompleted:
          verificationsPhotosCompleted ?? this.verificationsPhotosCompleted,
      confirmeSansAmericanite:
          confirmeSansAmericanite ?? this.confirmeSansAmericanite,
      estClientAutreBanque:
          estClientAutreBanque ?? this.estClientAutreBanque,
    );
  }

  bool get isValid => true;
}
import 'dart:io';

enum LightLevel {
  tooDark,
  good,
  tooLight,
}
class FaceCaptureState {
  final String faceDirection;
  final String? facePhotoPath;
  final String? gauchePhotoPath;
  final String? droitePhotoPath;
  final File? frontFaceExtracted;

  const FaceCaptureState({
    this.faceDirection = '',
    this.facePhotoPath,
    this.gauchePhotoPath,
    this.droitePhotoPath,
    this.frontFaceExtracted,
  });

  FaceCaptureState copyWith({
    String? faceDirection,
    String? facePhotoPath,
    String? gauchePhotoPath,
    String? droitePhotoPath,
    File? frontFaceExtracted,
  }) {
    return FaceCaptureState(
      faceDirection: faceDirection ?? this.faceDirection,
      facePhotoPath: facePhotoPath ?? this.facePhotoPath,
      gauchePhotoPath: gauchePhotoPath ?? this.gauchePhotoPath,
      droitePhotoPath: droitePhotoPath ?? this.droitePhotoPath,
      frontFaceExtracted: frontFaceExtracted ?? this.frontFaceExtracted,
    );
  }
}
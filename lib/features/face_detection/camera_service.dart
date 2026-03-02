import 'package:camera/camera.dart';
import 'dart:typed_data';

class CameraService {
  CameraController? controller;

  Future<void> initializeCamera(CameraDescription camera) async {
    controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller!.initialize();
  }

  void startImageStream(Function(CameraImage) onImage) {
    controller?.startImageStream(onImage);
  }

  void dispose() {
    controller?.dispose();
  }

  Uint8List convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;
    final int yRowStride = image.planes[0].bytesPerRow;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final Uint8List nv21 = Uint8List(width * height * 3 ~/ 2);

    // Copy Y plane
    for (int y = 0; y < height; y++) {
      final int yOffset = y * yRowStride;
      final int nv21YIndex = y * width;
      nv21.setRange(nv21YIndex, nv21YIndex + width, yPlane, yOffset);
    }

    // Copy interleaved VU plane
    int uvIndex = width * height;
    for (int y = 0; y < height ~/ 2; y++) {
      for (int x = 0; x < width ~/ 2; x++) {
        final int uvOffset = y * uvRowStride + x * uvPixelStride;
        nv21[uvIndex++] = vPlane[uvOffset];
        nv21[uvIndex++] = uPlane[uvOffset];
      }
    }

    return nv21;
  }
}
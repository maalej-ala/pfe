import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _cachedDeviceId; // 🔥 cache

  Future<String> getDeviceId() async {
    // ✅ retourne direct si déjà récupéré
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      _cachedDeviceId = android.id ?? 'unknown';
    } else if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      _cachedDeviceId = ios.identifierForVendor ?? 'unknown';
    } else {
      _cachedDeviceId = 'unknown';
    }

    return _cachedDeviceId!;
  }
}
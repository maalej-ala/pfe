import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialisation
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // ou ton icône

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

await _notificationsPlugin.initialize(
  settings: initializationSettings,
  onDidReceiveNotificationResponse: onNotificationTap,
);
  }

  // Action quand on tape sur la notification
  static void onNotificationTap(NotificationResponse response) {
    // Tu peux ici naviguer vers une page de vérification par exemple
    print("Notification tapped: ${response.payload}");
  }

  // Afficher une notification OTP
  static Future<void> showOtpNotification({
    required String otpCode,
    String title = "Code de vérification",
    String channelId = "otp_channel",
    String channelName = "OTP Notifications",
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'otp_channel', // channel id (doit être unique)
      'OTP Notifications', // channel name
      channelDescription: 'Notifications pour les codes de vérification',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      // Style BigText pour que tout le message soit visible
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final String body = "Votre code de vérification est : $otpCode\n"
        "Ce code expire dans 5 minutes.";

    await _notificationsPlugin.show(
  id: 1,
  title: title,
  body: body,
  notificationDetails: platformDetails,
  payload: otpCode,
);
  }
}
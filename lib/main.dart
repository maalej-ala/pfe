import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/home/view/home_page.dart';
import 'package:pfe_flutter/shared/theme/app_theme.dart';
import 'package:pfe_flutter/shared/services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  runApp(const BankApp());
}

class BankApp extends StatelessWidget {
  const BankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compte Bancaire',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // ✅ ici

      home: const HomePage(),
    );
  }
}
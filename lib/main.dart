import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfe_flutter/features/home/view/home_page.dart';
import 'package:pfe_flutter/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 Bloquer l'application en mode portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
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
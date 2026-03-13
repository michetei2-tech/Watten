import 'package:flutter/material.dart';

import 'pages/start_page.dart';
import 'widgets/responsive_scaler.dart';
import 'services/pwa_install_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PWA-Install-Service aktivieren
  PwaInstallService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spiel Dokumentation',

      // GLOBALER RESPONSIVE-SCALER
      builder: (context, child) {
        return ResponsiveScaler(
          child: child!,
        );
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      home: const StartPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/start_page.dart';
import 'widgets/responsive_scaler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase korrekt initialisieren
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

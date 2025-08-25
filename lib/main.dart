import 'package:clicker_game/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase if not already initialized (e.g., during hot reload)
  try {
    Firebase.apps.isEmpty
        ? await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          )
        : null;
  } catch (_) {
    // ignore init errors; the app has a local fallback for leaderboard
  }
  // Lock to portrait for simplicity
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Ensure Flame is initialized before running the app
  await Flame.device.fullScreen();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clicker Game',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEC4899),
          tertiary: Color(0xFF10B981),
          surface: Color(0xFF1F2937),
          background: Color(0xFF111827),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black54,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

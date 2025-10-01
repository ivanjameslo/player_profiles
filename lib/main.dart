import 'package:flutter/material.dart';
import 'profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player Profiles',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF214D45,
          <int, Color>{
            50: Color(0xFFE1F5E4),
            100: Color(0xFFB9EBD1),
            200: Color(0xFF8ED1B8),
            300: Color(0xFF62BFA0),
            400: Color(0xFF4DAE8D),
            500: Color(0xFF33B96D),
            600: Color(0xFF2DAA61),
            700: Color(0xFF249B54),
            800: Color(0xFF1C8B47),
            900: Color(0xFF147A3A),
          },
        ),
      ),
      home: const ProfilePage(),
    );
  }
}

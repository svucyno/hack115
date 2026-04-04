import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/health_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthProvider()),
      ],
      child: const LifeguardApp(),
    ),
  );
}

class LifeguardApp extends StatelessWidget {
  const LifeguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifeguard AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00C8FF),
        scaffoldBackgroundColor: const Color(0xFF020408),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white70),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C8FF),
          secondary: Color(0xFF39FF14),
          surface: Color(0xFF020408),
          error: Color(0xFFFF003C),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

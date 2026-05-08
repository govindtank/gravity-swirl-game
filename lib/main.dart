import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/storage_service.dart';
import 'core/theme_manager.dart';
import 'ui/screens/home_screen.dart';

const defaultTheme = GameTheme(
  id: 'default',
  name: 'Default',
  background: Color(0xFF0A0A2A),
  surface: Color(0xFF1A1A2E),
  primary: Color(0xFF6366F1),
  secondary: Color(0xFF8B5CF6),
  accent: Color(0xFFF59E0B),
  particleColor: Colors.white,
  goalColor: Color(0xFF3B82F6),
  hazardColor: Color(0xFFEF4444),
  textPrimary: Colors.white,
  textSecondary: Color(0xFFB0B0B0),
  isDark: true,
);

// ========================================================
// MAIN ENTRY POINT
// ========================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const GravitySwirlApp());
}

class GravitySwirlApp extends StatelessWidget {
  const GravitySwirlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gravity Swirl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

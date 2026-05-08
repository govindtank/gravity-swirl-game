import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/storage_service.dart';
import 'core/theme_manager.dart';
import 'ui/screens/home_screen.dart';

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

  // Initialize storage
  final storage = StorageService();
  await storage.init();

  // Initialize theme manager
  final themeManager = ThemeManager(storage);
  await themeManager.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider<ThemeManager>.value(value: themeManager),
      ],
      child: const GravitySwirlApp(),
    ),
  );
}

class GravitySwirlApp extends StatelessWidget {
  const GravitySwirlApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return MaterialApp(
      title: 'Gravity Swirl',
      debugShowCheckedModeBanner: false,
      theme: themeManager.currentTheme.toThemeData(),
      home: const HomeScreen(),
    );
  }
}

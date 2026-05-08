import 'package:flutter/material.dart';
import 'storage_service.dart';

// ========================================================
// GAME THEME DEFINITIONS
// ========================================================

class GameTheme {
  final String id;
  final String name;
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color particleColor;
  final Color goalColor;
  final Color hazardColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const GameTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.particleColor,
    required this.goalColor,
    required this.hazardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  // Generate Flutter ThemeData from GameTheme
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: false,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: accent,
        error: hazardColor,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: textPrimary),
        displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: textPrimary),
        headlineLarge: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withOpacity(0.3),
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withOpacity(0.5);
          }
          return textSecondary.withOpacity(0.3);
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
        contentTextStyle: TextStyle(fontSize: 14, color: textSecondary),
      ),
    );
  }
}

// ========================================================
// AVAILABLE THEMES
// ========================================================

class GameThemes {
  static const Map<String, GameTheme> themes = {
    'cosmic_dark': GameTheme(
      id: 'cosmic_dark',
      name: 'Cosmic Dark',
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
    ),
    'nebula_light': GameTheme(
      id: 'nebula_light',
      name: 'Nebula Light',
      background: Color(0xFFF0F4FF),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF4F46E5),
      secondary: Color(0xFF7C3AED),
      accent: Color(0xFFD97706),
      particleColor: Color(0xFF1E1B4B),
      goalColor: Color(0xFF2563EB),
      hazardColor: Color(0xFFDC2626),
      textPrimary: Color(0xFF1E1B4B),
      textSecondary: Color(0xFF64748B),
      isDark: false,
    ),
    'neon_night': GameTheme(
      id: 'neon_night',
      name: 'Neon Night',
      background: Color(0xFF0D0D0D),
      surface: Color(0xFF1A1A1A),
      primary: Color(0xFF00FFFF),
      secondary: Color(0xFFFF00FF),
      accent: Color(0xFFFFFF00),
      particleColor: Color(0xFF00FF00),
      goalColor: Color(0xFF00FFFF),
      hazardColor: Color(0xFFFF0066),
      textPrimary: Colors.white,
      textSecondary: Color(0xFF888888),
      isDark: true,
    ),
    'sunset_glow': GameTheme(
      id: 'sunset_glow',
      name: 'Sunset Glow',
      background: Color(0xFF1A0A1F),
      surface: Color(0xFF2D1B36),
      primary: Color(0xFFFF6B6B),
      secondary: Color(0xFFFFA500),
      accent: Color(0xFFFFD700),
      particleColor: Color(0xFFFFE4E1),
      goalColor: Color(0xFFFF8C00),
      hazardColor: Color(0xFFFF1744),
      textPrimary: Color(0xFFFFF5F5),
      textSecondary: Color(0xFFCCB0B0),
      isDark: true,
    ),
    'ocean_depth': GameTheme(
      id: 'ocean_depth',
      name: 'Ocean Depth',
      background: Color(0xFF0A192F),
      surface: Color(0xFF112240),
      primary: Color(0xFF64FFDA),
      secondary: Color(0xFF00BCD4),
      accent: Color(0xFFFFAB40),
      particleColor: Color(0xFFE6F1FF),
      goalColor: Color(0xFF64FFDA),
      hazardColor: Color(0xFFFF5252),
      textPrimary: Color(0xFFE6F1FF),
      textSecondary: Color(0xFF8892B0),
      isDark: true,
    ),
    'forest_moss': GameTheme(
      id: 'forest_moss',
      name: 'Forest Moss',
      background: Color(0xFF0F1A0F),
      surface: Color(0xFF1A2F1A),
      primary: Color(0xFF4ADE80),
      secondary: Color(0xFF22C55E),
      accent: Color(0xFFEAB308),
      particleColor: Color(0xFFD9F99D),
      goalColor: Color(0xFF4ADE80),
      hazardColor: Color(0xFFF97316),
      textPrimary: Color(0xFFF0FDF4),
      textSecondary: Color(0xFF86EFAC),
      isDark: true,
    ),
  };

  static GameTheme get(String id) =>
      themes[id] ?? themes['cosmic_dark']!;

  static List<GameTheme> get all => themes.values.toList();

  static List<GameTheme> get darkThemes =>
      all.where((t) => t.isDark).toList();

  static List<GameTheme> get lightThemes =>
      all.where((t) => !t.isDark).toList();
}

// ========================================================
// THEME MANAGER - Provider for Theme State
// ========================================================

class ThemeManager extends ChangeNotifier {
  final StorageService _storage;
  GameTheme _currentTheme = GameThemes.themes['cosmic_dark']!;
  bool _isInitialized = false;

  ThemeManager(this._storage);

  GameTheme get currentTheme => _currentTheme;
  bool get isInitialized => _isInitialized;
  bool get isDarkMode => _currentTheme.isDark;

  Future<void> init() async {
    final themeId = await _storage.getSelectedTheme();
    _currentTheme = GameThemes.get(themeId);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    if (GameThemes.themes.containsKey(themeId)) {
      _currentTheme = GameThemes.themes[themeId]!;
      await _storage.setSelectedTheme(themeId);
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    if (_currentTheme.isDark) {
      // Switch to first light theme
      final lightTheme = GameThemes.lightThemes.firstOrNull;
      if (lightTheme != null) {
        setTheme(lightTheme.id);
      }
    } else {
      // Switch to first dark theme
      final darkTheme = GameThemes.darkThemes.firstOrNull;
      if (darkTheme != null) {
        setTheme(darkTheme.id);
      }
    }
  }
}

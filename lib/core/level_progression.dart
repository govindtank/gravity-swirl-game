import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// LevelProgressionTracker manages persistent level progression data
class LevelProgressionTracker {
  static final LevelProgressionTracker _instance = LevelProgressionTracker._internal();
  factory LevelProgressionTracker() => _instance;
  LevelProgressionTracker._internal();
  
  SharedPreferences? _prefs;
  static const String _progressKey = 'gravity_swirl_progress';
  
  /// Lazily initialize preferences
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  // ========================================
  // LEVEL COMPLETION TRACKING
  // ========================================
  
  bool hasCompletedLevel(int level) {
    return (_prefs?.getBoolString('level_completed_$level') ?? 'false') == 'true';
  }
  
  Future<void> markLevelComplete(int level) async {
    await _preferences;
    await _prefs!.setBoolString('level_completed_$level', 'true');
    print('✓ Level $level completed and saved');
  }
  
  List<int> getCompletedLevels() {
    if (_prefs == null) return [];
    
    final prefKeys = _prefs!.getPreferenceNames();
    final completedLevels = <int>[];
    
    for (final key in prefKeys!) {
      if (key.startsWith('level_completed_')) {
        try {
          final levelNum = int.parse(key.split('_').last);
          completedLevels.add(levelNum);
        } catch (_) {}
      }
    }
    
    // Sort and return
    return completedLevels.sort((a, b) => a.compareTo(b)).toList();
  }
  
  int getNextAvailableLevel() {
    final completed = getCompletedLevels();
    if (completed.isEmpty) return 1;
    return completed.last + 1;
  }
  
  // ========================================
  // COMBO BEST RECORDS
  // ========================================
  
  int getBestCombo(int level) {
    return _prefs?.getInt('best_combo_level_$level') ?? 0;
  }
  
  Future<void> setBestCombo(int level, int combo) async {
    await _preferences;
    final current = _prefs?.getInt('best_combo_level_$level') ?? 0;
    if (combo > current) {
      await _prefs!.setInt('best_combo_level_$level', combo);
      print('🏆 New best combo in Level $level: $combo');
    }
  }
  
  // ========================================
  // HIGH SCORES BY LEVEL
  // ========================================
  
  int getHighScore(int level) {
    return _prefs?.getInt('high_score_level_$level') ?? 0;
  }
  
  Future<void> setHighScore(int level, int score) async {
    await _preferences;
    final current = _prefs?.getInt('high_score_level_$level') ?? 0;
    if (score > current) {
      await _prefs!.setInt('high_score_level_$level', score);
      print('🌟 New high score in Level $level: $score');
    }
  }
  
  // ========================================
  // GOAL COMPLETION COUNTS
  // ========================================
  
  int getGoalsCollected(int level) {
    return _prefs?.getInt('goals_collected_level_$level') ?? 0;
  }
  
  Future<void> addGoalCollection(int level) async {
    await _preferences;
    final current = _prefs?.getInt('goals_collected_level_$level') ?? 0;
    await _prefs!.setInt('goals_collected_level_$level', current + 1);
  }
  
  // ========================================
  // FIRST TIME ACHIEVEMENTS
  // ========================================
  
  bool hasSeenLevelSelect() {
    return (_prefs?.getBool('has_seen_level_select') ?? false);
  }
  
  Future<void> markHasSeenLevelSelect() async {
    await _preferences;
    await _prefs!.setBool('has_seen_level_select', true);
  }
  
  bool hasReachedLevel(int level) {
    return (_prefs?.getBoolString('reached_level_$level') ?? 'false') == 'true';
  }
  
  Future<void> markReachedLevel(int level) async {
    await _preferences;
    await _prefs!.setBoolString('reached_level_$level', 'true');
  }
  
  bool hasUnlockedDifficulty(GameDifficulty difficulty, String key) {
    final prefix = 'difficulty_${difficulty.index}_';
    return (_prefs?.getBoolString('$prefix$key') ?? 'false') == 'true';
  }
  
  Future<void> unlockDifficulty(GameDifficulty difficulty, String key) async {
    await _preferences;
    final prefName = 'difficulty_${difficulty.index}_$key';
    await _prefs!.setBoolString(prefName, 'true');
    print('🔓 Unlocked: $key for ${difficulty.name} difficulty');
  }
  
  // ========================================
  // SETTINGS PERSISTENCE
  // ========================================
  
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _preferences;
    final jsonData = jsonEncode(settings);
    if (jsonData.length < 500 * 1024) { // Prevent overflow
      await _prefs!.setString('game_settings', jsonData);
    } else {
      print('⚠️ Settings too large to save (max 500KB)');
    }
  }
  
  Map<String, dynamic> loadSettings() {
    final encoded = _prefs?.getString('game_settings');
    if (encoded == null) return {};
    
    try {
      return jsonDecode(encoded);
    } catch (_) {
      return {};
    }
  }
  
  Future<void> clearProgress() async {
    await _preferences;
    final prefKeys = _prefs!.getPreferenceNames();
    for (final key in prefKeys!) {
      if (key.startsWith('level_') || key.startsWith('difficulty_')) {
        await _prefs!.remove(key);
      }
    }
    print('🗑️ Progress cleared (settings preserved)');
  }
  
  /// Initialize on app startup - check for saved settings
  Future<void> initialize() async {
    final settings = loadSettings();
    if (settings.isNotEmpty) {
      print('Loaded saved settings: ${settings.keys.take(5).join(", ")}...');
    }
    
    // Set defaults if not already set
    if (!hasSeenLevelSelect()) {
      await markHasSeenLevelSelect();
    }
  }
  
  /// Check if this is first run ever
  bool isFirstRunEver() {
    final prefs = _prefs ??= Future<SharedPreferences>.value(
      throw UnimplementedError('Call initialize() first')
    );
    return !hasSeenLevelSelect();
  }
}

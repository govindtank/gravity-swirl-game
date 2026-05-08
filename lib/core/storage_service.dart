import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_profile.dart';

// ========================================================
// STORAGE SERVICE - SharedPreferences Wrapper
// ========================================================

class StorageService {
  static const String _profileKey = 'player_profile';
  static const String _themeKey = 'selected_theme';
  static const String _soundVolumeKey = 'sound_volume';
  static const String _musicVolumeKey = 'music_volume';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== Player Profile ==========

  Future<PlayerProfile> loadProfile() async {
    _prefs ??= await SharedPreferences.getInstance();

    final json = _prefs!.getString(_profileKey);
    if (json != null) {
      try {
        return PlayerProfile.fromJson(jsonDecode(json));
      } catch (e) {
        // Corrupted data, return defaults
        return PlayerProfile.defaults();
      }
    }
    return PlayerProfile.defaults();
  }

  Future<void> saveProfile(PlayerProfile profile) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // ========== Quick Settings Access ==========

  Future<String> getSelectedTheme() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(_themeKey) ?? 'cosmic_dark';
  }

  Future<void> setSelectedTheme(String themeId) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_themeKey, themeId);
  }

  Future<double> getSoundVolume() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getDouble(_soundVolumeKey) ?? 0.8;
  }

  Future<void> setSoundVolume(double volume) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setDouble(_soundVolumeKey, volume);
  }

  Future<double> getMusicVolume() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getDouble(_musicVolumeKey) ?? 0.5;
  }

  Future<void> setMusicVolume(double volume) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setDouble(_musicVolumeKey, volume);
  }

  // ========== High Scores ==========

  Future<int> getHighScore() async {
    final profile = await loadProfile();
    return profile.highScore;
  }

  Future<void> updateHighScore(int score) async {
    final profile = await loadProfile();
    if (score > profile.highScore) {
      profile.highScore = score;
      await saveProfile(profile);
    }
  }

  Future<int> getHighestLevel() async {
    final profile = await loadProfile();
    return profile.highestLevel;
  }

  Future<void> updateHighestLevel(int level) async {
    final profile = await loadProfile();
    if (level > profile.highestLevel) {
      profile.highestLevel = level;
      await saveProfile(profile);
    }
  }

  // ========== Statistics ==========

  Future<void> incrementGamesPlayed() async {
    final profile = await loadProfile();
    profile.totalGamesPlayed++;
    await saveProfile(profile);
  }

  Future<void> addGoalsCollected(int count) async {
    final profile = await loadProfile();
    profile.totalGoalsCollected += count;
    await saveProfile(profile);
  }

  Future<void> addPlayTime(int seconds) async {
    final profile = await loadProfile();
    profile.totalPlayTime += seconds;
    await saveProfile(profile);
  }

  Future<void> updateLongestCombo(int combo) async {
    final profile = await loadProfile();
    if (combo > profile.longestCombo) {
      profile.longestCombo = combo;
      await saveProfile(profile);
    }
  }

  // ========== Unlocks ==========

  Future<void> unlockAchievement(String achievementId) async {
    final profile = await loadProfile();
    profile.unlockedAchievements.add(achievementId);
    await saveProfile(profile);
  }

  Future<bool> isAchievementUnlocked(String achievementId) async {
    final profile = await loadProfile();
    return profile.unlockedAchievements.contains(achievementId);
  }

  Future<void> unlockParticleStyle(String styleId) async {
    final profile = await loadProfile();
    profile.unlockedParticleStyles.add(styleId);
    await saveProfile(profile);
  }

  Future<void> unlockTrailEffect(String effectId) async {
    final profile = await loadProfile();
    profile.unlockedTrailEffects.add(effectId);
    await saveProfile(profile);
  }

  Future<void> unlockBackground(String backgroundId) async {
    final profile = await loadProfile();
    profile.unlockedBackgrounds.add(backgroundId);
    await saveProfile(profile);
  }

  Future<void> unlockGoalStyle(String styleId) async {
    final profile = await loadProfile();
    profile.unlockedGoalStyles.add(styleId);
    await saveProfile(profile);
  }

  // ========== Reset ==========

  Future<void> resetAllProgress() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_profileKey);
  }
}

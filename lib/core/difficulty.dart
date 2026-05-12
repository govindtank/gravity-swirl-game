import 'package:flutter/material.dart';

/// GameDifficulty preset for gameplay tuning
enum GameDifficulty {
  /// Relaxed gameplay - slower speeds, easier collection
  easy(
    speedMultiplier: 0.7,
    comboDecay: 2.5,
    goalSizeMin: 40.0,
    goalSizeMax: 60.0,
    powerupSpawnRate: 180, // frames
  ),

  /// Standard gameplay (default)
  normal(
    speedMultiplier: 1.0,
    comboDecay: 2.0,
    goalSizeMin: 50.0,
    goalSizeMax: 70.0,
    powerupSpawnRate: 140, // frames
  ),

  /// Challenging gameplay - faster speeds, harder timing
  hard(
    speedMultiplier: 1.3,
    comboDecay: 1.5,
    goalSizeMin: 60.0,
    goalSizeMax: 80.0,
    powerupSpawnRate: 100, // frames
  ),
  
  /// Insane difficulty for expert players
  insane(
    speedMultiplier: 1.5,
    comboDecay: 1.2,
    goalSizeMin: 70.0,
    goalSizeMax: 90.0,
    powerupSpawnRate: 80, // frames
  );

  final double speedMultiplier;
  final double comboDecay;
  final double goalSizeMin;
  final double goalSizeMax;
  final int powerupSpawnRate;
}

/// PowerupType for diverse ability enhancements
enum PowerupType {
  /// Slow down all objects temporarily
  slowMotion('⏸️', 2.0, Color(0xFFFF6B35), () {
    return {'speedModifier': 0.3};
  }),

  /// Remove obstacles in a radius around player
  clearPath('💨', 1.0, Color(0xFF10B981), () {
    return {'clearRadius': 150.0};
  }),

  /// Infinite combo time
  infiniteCombo('♾️', 3.0, Color(0xFF6366F1), () {
    return {'comboTimerMultiplier': 2.0};
  }),

  /// Slowly score points automatically
  autoScore('✨', 5.0, Color(0xFFF59E0B), () {
    return {'autoScoreRate': 0.5}; // points per frame
  }),

  /// Make goals larger and easier to collect
  giantGoals('🎯', 2.0, Color(0xFFEC4899), () {
    return {'goalSizeMultiplier': 3.0};
  }),

  /// Attract nearby goals toward player
  magnet('🧲', 1.5, Color(0xFF8B5CF6), () {
    return {'magnetRadius': 200.0, 'magnetForce': 10.0};
  });

  final String emoji;
  final double durationMultiplier;
  final Color color;
  final Map<String, dynamic> createProperties();

  PowerupType(this.emoji, this.durationMultiplier, this.color, this.createProperties);
}

/// DifficultySettings holds runtime configuration
class DifficultySettings {
  /// Current difficulty preset
  GameDifficulty get difficulty => _difficulty;
  
  /// Speed modifier (0.5 to 2.0)
  double get speedMultiplier => 
    difficulty.speedMultiplier * (1.0 + (_customSpeedModifier ?? 0.0));
  
  set speedMultiplier(double value) {
    if (value < 0.5) _customSpeedModifier = -0.4;
    else if (value > 2.0) _customSpeedModifier = 1.6;
    else _customSpeedModifier = value / difficulty.speedMultiplier - 1.0;
  }

  /// Combo decay time modifier
  double get comboDecay => difficulty.comboDecay * (1.0 + (_customComboModifier ?? 0.0));
  
  set comboDecay(double value) {
    if (value < 1.5) _customComboModifier = -0.4;
    else if (value > 3.0) _customComboModifier = 1.6;
    else _customComboModifier = value / difficulty.comboDecay - 1.0;
  }

  GameDifficulty _difficulty;
  double? _customSpeedModifier;
  double? _customComboModifier;

  DifficultySettings({this._difficulty = GameDifficulty.normal});

  /// Configure with custom parameters
  DifficultySettings.fromParams({
    required this._difficulty,
    double? speedMultiplier,
    double? comboDecay,
  }) {
    if (speedMultiplier != null) _customSpeedModifier = 
      speedMultiplier / difficulty.speedMultiplier - 1.0;
    if (comboDecay != null) _customComboModifier = 
      comboDecay / difficulty.comboDecay - 1.0;
  }

  /// Save custom settings to persistence key
  Map<String, dynamic> toJson() {
    return {
      'difficulty': _difficulty.index,
      'speedMod': _customSpeedModifier,
      'comboMod': _customComboModifier,
    };
  }

  /// Load from persistence key
  static DifficultySettings? fromJson(Map<String, dynamic> data) {
    if (data['difficulty'] == null) return null;
    final difficulty = GameDifficulty.values[data['difficulty'] as int];
    return DifficultySettings.fromParams(
      difficulty: difficulty,
      speedMultiplier: data['speedMod'],
      comboDecay: data['comboMod'],
    );
  }

  factory DifficultySettings.defaultPreset(GameDifficulty preset) {
    return DifficultySettings(difficulty: preset);
  }
}

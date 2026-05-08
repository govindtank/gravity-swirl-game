import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/storage_service.dart';
import '../../core/theme_manager.dart';
import '../../engine/game_engine.dart';
import '../../models/game_objects.dart';
import '../painters/game_painter.dart';
import '../widgets/game_hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GravitySwirlGameEngine _game;
  late final AnimationController _animationController;
  Size _gameSize = const Size(800, 600);
  double _animationTime = 0;

  @override
  void initState() {
    super.initState();
    _game = GravitySwirlGameEngine();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animationController.addListener(_onTick);

    // Setup game callbacks
    _game.onLevelComplete = _onLevelComplete;
    _game.onGameOver = _onGameOver;
    _game.onPowerupCollected = _onPowerupCollected;
    _game.onComboMilestone = _onComboMilestone;
  }

  void _onTick() {
    _animationTime += 0.016;
    _game.update(0.016, _gameSize);
  }

  void _onLevelComplete() {
    // Save progress
    _saveProgress();

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _onGameOver() {
    _saveProgress();
  }

  void _onPowerupCollected(PowerupType type) {
    HapticFeedback.lightImpact();
  }

  void _onComboMilestone(int combo) {
    HapticFeedback.heavyImpact();
  }

  Future<void> _saveProgress() async {
    final storage = context.read<StorageService>();
    await storage.updateHighScore(_game.state.score);
    await storage.updateHighestLevel(_game.state.currentLevel);
    await storage.updateLongestCombo(_game.state.combo.longestCombo);
    await storage.addGoalsCollected(_game.state.goalsCollectedThisLevel);
  }

  @override
  void dispose() {
    _animationController.removeListener(_onTick);
    _animationController.dispose();
    super.dispose();
  }

  void _pauseGame() {
    _game.pause();
    _animationController.stop();
  }

  void _resumeGame() {
    _game.resume();
    _animationController.repeat();
  }

  void _restartGame() {
    _game.restart(_gameSize);
    _animationController.repeat();
  }

  void _quitGame() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _gameSize = Size(constraints.maxWidth, constraints.maxHeight);

          // Initialize game on first build
          if (_game.state.levelData == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _game.startGame(gameSize: _gameSize);
            });
          }

          return Stack(
            children: [
              // Game canvas
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) {
                    _game.addPathPoint(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _game.addPathPoint(details.localPosition);
                  },
                  onPanEnd: (_) {
                    _game.scheduleClearPath();
                  },
                  child: ListenableBuilder(
                    listenable: _game,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: GamePainter(
                          state: _game.state,
                          theme: theme,
                          animationTime: _animationTime,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // HUD
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ListenableBuilder(
                  listenable: _game,
                  builder: (context, child) {
                    return GameHUD(
                      state: _game.state,
                      theme: theme,
                      onPause: _pauseGame,
                    );
                  },
                ),
              ),

              // Instructions hint
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _game.state.currentLevel <= 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Tap & drag to guide particles',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Level complete overlay
              ListenableBuilder(
                listenable: _game,
                builder: (context, child) {
                  if (_game.state.isLevelComplete) {
                    return LevelCompleteOverlay(
                      level: _game.state.currentLevel,
                      score: _game.state.score,
                      perfectLevel: _game.state.particlesLostThisLevel == 0,
                      theme: theme,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Pause menu
              ListenableBuilder(
                listenable: _game,
                builder: (context, child) {
                  if (_game.state.isPaused) {
                    return PauseMenu(
                      theme: theme,
                      onResume: _resumeGame,
                      onRestart: _restartGame,
                      onQuit: _quitGame,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

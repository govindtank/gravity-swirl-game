import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme_manager.dart';
import '../../engine/game_engine.dart';
import '../../models/game_objects.dart';

// ========================================================
// ANIMATED SCORE DISPLAY
// ========================================================

class AnimatedScoreDisplay extends StatelessWidget {
  final int score;
  final GameTheme theme;

  const AnimatedScoreDisplay({
    super.key,
    required this.score,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: score),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.accent.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.accent.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, color: theme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ========================================================
// LEVEL BADGE
// ========================================================

class LevelBadge extends StatelessWidget {
  final int level;
  final GameTheme theme;

  const LevelBadge({
    super.key,
    required this.level,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Level $level',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// COMBO INDICATOR
// ========================================================

class ComboIndicator extends StatelessWidget {
  final int combo;
  final double multiplier;
  final GameTheme theme;

  const ComboIndicator({
    super.key,
    required this.combo,
    required this.multiplier,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (combo == 0) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.2, end: 1.0),
      duration: const Duration(milliseconds: 200),
      key: ValueKey(combo),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.accent,
                  Colors.orange,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.accent.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${combo}x',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${multiplier.toStringAsFixed(1)}x)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ========================================================
// ACTIVE POWERUPS BAR
// ========================================================

class ActivePowerupsBar extends StatelessWidget {
  final List<ActivePowerup> powerups;
  final GameTheme theme;

  const ActivePowerupsBar({
    super.key,
    required this.powerups,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (powerups.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: powerups.map((p) => _PowerupChip(powerup: p)).toList(),
    );
  }
}

class _PowerupChip extends StatelessWidget {
  final ActivePowerup powerup;

  const _PowerupChip({required this.powerup});

  @override
  Widget build(BuildContext context) {
    final color = Powerup.getColor(powerup.type);
    final name = Powerup.getName(powerup.type);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIcon(powerup.type), color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${powerup.remainingTime.toStringAsFixed(1)}s',
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(PowerupType type) {
    switch (type) {
      case PowerupType.shield:
        return Icons.shield;
      case PowerupType.multiplier:
        return Icons.looks_two;
      case PowerupType.slowMotion:
        return Icons.hourglass_bottom;
      case PowerupType.magnet:
        return Icons.swap_calls;
      case PowerupType.particleBurst:
        return Icons.auto_awesome;
      default:
        return Icons.help;
    }
  }
}

// ========================================================
// FULL GAME HUD
// ========================================================

class GameHUD extends StatelessWidget {
  final GameState state;
  final GameTheme theme;
  final VoidCallback onPause;

  const GameHUD({
    super.key,
    required this.state,
    required this.theme,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LevelBadge(level: state.currentLevel, theme: theme),
                AnimatedScoreDisplay(score: state.score, theme: theme),
                IconButton(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause_circle_filled, size: 32),
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ComboIndicator(
                  combo: state.combo.currentCombo,
                  multiplier: state.combo.calculateMultiplier(),
                  theme: theme,
                ),
                ActivePowerupsBar(
                  powerups: state.activePowerups,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================
// LEVEL COMPLETE OVERLAY
// ========================================================

class LevelCompleteOverlay extends StatelessWidget {
  final int level;
  final int score;
  final bool perfectLevel;
  final GameTheme theme;

  const LevelCompleteOverlay({
    super.key,
    required this.level,
    required this.score,
    required this.perfectLevel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Level $level Complete!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      shadows: [
                        Shadow(
                          color: theme.primary.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (perfectLevel)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.accent, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'PERFECT!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 24,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Loading next level...',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ========================================================
// PAUSE MENU
// ========================================================

class PauseMenu extends StatelessWidget {
  final GameTheme theme;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseMenu({
    super.key,
    required this.theme,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paused',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              _MenuButton(
                label: 'Resume',
                icon: Icons.play_arrow,
                color: theme.primary,
                onPressed: onResume,
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'Restart',
                icon: Icons.refresh,
                color: theme.secondary,
                onPressed: onRestart,
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'Quit',
                icon: Icons.home,
                color: theme.hazardColor,
                onPressed: onQuit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

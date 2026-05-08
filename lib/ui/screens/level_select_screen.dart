import 'package:flutter/material.dart';
import '../../core/theme_manager.dart';
import '../../main.dart';

/// Level select screen with level list and difficulty indicators
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = defaultTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.surface.withOpacity(0.8),
                    theme.background,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [theme.primary, theme.secondary],
                    ).createShader(bounds),
                    child: const Icon(Icons.auto_level_up, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEVEL SELECT',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose your challenge',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.close, color: theme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // Level list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 10, // Demo: 10 levels
                itemBuilder: (context, index) {
                  final isLocked = index >= 3; // First 3 levels unlocked
                  
                  return _LevelTile(
                    levelNumber: index + 1,
                    isUnlocked: !isLocked,
                    difficulty: _getDifficulty(index),
                    theme: theme,
                    onTap: () {
                      if (!isLocked) {
                        Navigator.pop(context); // Return to main menu
                      }
                    },
                  );
                },
              ),
            ),

            // Legend footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface.withOpacity(0.3),
                border: Border(top: BorderSide(color: theme.primary.withOpacity(0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendItem(
                    icon: Icons.lock_open,
                    color: AppConstants.neonGreen,
                    label: 'Unlocked',
                  ),
                  Container(width: 1, height: 30, color: theme.textSecondary.withOpacity(0.3)),
                  const LegendItem(
                    icon: Icons.lock,
                    color: Colors.grey,
                    label: 'Locked',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficulty(int index) {
    if (index < 3) return 'Easy';
    if (index < 6) return 'Medium';
    return 'Hard';
  }
}

class _LevelTile extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final String difficulty;
  final GameTheme theme;
  final VoidCallback onTap;

  const _LevelTile({
    required this.levelNumber,
    required this.isUnlocked,
    required this.difficulty,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isUnlocked 
              ? theme.surface.withOpacity(0.4) 
              : Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked 
                ? theme.primary.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked ? theme.primary.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  levelNumber.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? theme.primary : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(levelNumber.toString())),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getDifficultyColor(difficulty).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getDifficultyColor(difficulty),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy': return AppConstants.neonGreen;
      case 'Medium': return AppConstants.primaryColor;
      case 'Hard': return AppConstants.hazardColor;
      default: return Colors.grey;
    }
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

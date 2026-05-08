import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage_service.dart';
import '../../core/theme_manager.dart';
import '../../models/player_profile.dart';
import '../../main.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlayerProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // final storage = context.read<StorageService>();
    // final profile = await storage.loadProfile();
    // setState(() => _profile = profile);
    // Disabled for simplicity
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showLevelSelectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(        backgroundColor: defaultTheme.surface,        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A2A4E),
                defaultTheme.background,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.list_alt, color: defaultTheme.primary, size: 48),
              const SizedBox(height: 16),
              Text(
                'SELECT LEVEL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a level to start playing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.play_arrow),
                label: Text('Start New Game'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: defaultTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame() {
    _showLevelSelectDialog();
  }
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _navigateToAchievements() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
  }

  void _navigateToLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = defaultTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              color: theme.background,
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [theme.primary, theme.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child:
                            const Icon(Icons.swipe, size: 60, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [theme.primary, theme.secondary, theme.accent],
                      ).createShader(bounds),
                      child: const Text(
                        'Gravity Swirl',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Master the Physics of the Cosmos',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),

                    // Quick stats
                    if (_profile != null) ...[
                      const SizedBox(height: 24),
                      _QuickStats(profile: _profile!, theme: theme),
                    ],

                    const SizedBox(height: 48),

                    // Start Game Button
                    _AnimatedButton(
                      onPressed: _navigateToGame,
                      icon: Icons.play_arrow_rounded,
                      label: 'START GAME',
                      isPrimary: true,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    // Secondary buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IconButton(
                          icon: Icons.emoji_events,
                          label: 'Scores',
                          onPressed: _navigateToLeaderboard,
                          theme: theme,
                        ),
                        const SizedBox(width: 16),
                        _IconButton(
                          icon: Icons.stars,
                          label: 'Achieve',
                          onPressed: _navigateToAchievements,
                          theme: theme,
                        ),
                        const SizedBox(width: 16),
                        _IconButton(
                          icon: Icons.settings,
                          label: 'Settings',
                          onPressed: _navigateToSettings,
                          theme: theme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Features row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FeatureChip(
                            icon: Icons.swipe, label: '60 FPS', theme: theme),
                        const SizedBox(width: 12),
                        _FeatureChip(
                            icon: Icons.all_inclusive,
                            label: 'Endless',
                            theme: theme),
                        const SizedBox(width: 12),
                        _FeatureChip(
                            icon: Icons.auto_awesome,
                            label: '8 Objects',
                            theme: theme),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Theme toggle - disabled
          // Positioned(
          //   top: 16,
          //   right: 16,
          //   child: SafeArea(
          //     child: IconButton(
          //       icon: Icon(
          //         theme.isDark ? Icons.light_mode : Icons.dark_mode,
          //         color: theme.textSecondary,
          //       ),
          //       onPressed: () {
          //         context.read<ThemeManager>().toggleDarkMode();
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ========================================================
// BACKGROUND PAINTER
// ========================================================

class _BackgroundPainter extends CustomPainter {
  final GameTheme theme;
  final double animationValue;

  _BackgroundPainter({required this.theme, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.surface,
          theme.background,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Animated stars
    final random = Random(42);
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle =
          0.2 + 0.8 * sin(animationValue * 2 * pi + i * 0.5).abs();

      canvas.drawCircle(
        Offset(x, y),
        1 + random.nextDouble(),
        Paint()..color = Colors.white.withOpacity(twinkle * 0.4),
      );
    }

    // Floating particles
    for (int i = 0; i < 15; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final drift = sin(animationValue * 2 * pi + i) * 20;

      canvas.drawCircle(
        Offset(baseX + drift, baseY),
        2 + random.nextDouble() * 2,
        Paint()..color = theme.primary.withOpacity(0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}

// ========================================================
// QUICK STATS WIDGET
// ========================================================

class _QuickStats extends StatelessWidget {
  final PlayerProfile profile;
  final GameTheme theme;

  const _QuickStats({required this.profile, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatItem(
            icon: Icons.emoji_events,
            value: '${profile.highScore}',
            label: 'Best',
            theme: theme,
          ),
          Container(
            width: 1,
            height: 30,
            color: theme.textSecondary.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _StatItem(
            icon: Icons.stars,
            value: '${profile.highestLevel}',
            label: 'Level',
            theme: theme,
          ),
          Container(
            width: 1,
            height: 30,
            color: theme.textSecondary.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _StatItem(
            icon: Icons.local_fire_department,
            value: '${profile.longestCombo}x',
            label: 'Combo',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final GameTheme theme;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.accent, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ========================================================
// BUTTONS
// ========================================================

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final GameTheme theme;

  const _AnimatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.theme,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme.primary,
            minimumSize: const Size(280, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 28),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final GameTheme theme;

  const _IconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final GameTheme theme;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage_service.dart';
import '../../core/theme_manager.dart';
import '../../models/player_profile.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late PlayerProfile _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final storage = context.read<StorageService>();
    final profile = await storage.loadProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('High Scores', style: TextStyle(color: theme.textPrimary)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHighScoreCard(theme),
                  const SizedBox(height: 24),
                  _buildStatsGrid(theme),
                  const SizedBox(height: 24),
                  _buildRecordsList(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildHighScoreCard(GameTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary,
            theme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'BEST SCORE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_profile.highScore}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Highest Level: ${_profile.highestLevel}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(GameTheme theme) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.sports_esports,
            label: 'Games Played',
            value: '${_profile.totalGamesPlayed}',
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            label: 'Play Time',
            value: _profile.formattedPlayTime,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList(GameTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _RecordRow(
          icon: Icons.flag,
          label: 'Total Goals Collected',
          value: '${_profile.totalGoalsCollected}',
          theme: theme,
        ),
        _RecordRow(
          icon: Icons.local_fire_department,
          label: 'Longest Combo',
          value: '${_profile.longestCombo}x',
          theme: theme,
          highlight: _profile.longestCombo >= 10,
        ),
        _RecordRow(
          icon: Icons.verified,
          label: 'Achievements Unlocked',
          value: '${_profile.achievementCount}',
          theme: theme,
        ),
        _RecordRow(
          icon: Icons.palette,
          label: 'Items Unlocked',
          value: '${_countUnlockedItems()}',
          theme: theme,
        ),
      ],
    );
  }

  int _countUnlockedItems() {
    return _profile.unlockedParticleStyles.length +
        _profile.unlockedTrailEffects.length +
        _profile.unlockedBackgrounds.length +
        _profile.unlockedGoalStyles.length;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final GameTheme theme;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final GameTheme theme;
  final bool highlight;

  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? theme.accent.withOpacity(0.1)
            : theme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: theme.accent.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: highlight ? theme.accent : theme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: theme.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: highlight ? theme.accent : theme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

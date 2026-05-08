import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage_service.dart';
import '../../core/theme_manager.dart';
import '../../models/achievement.dart';
import '../../models/player_profile.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PlayerProfile _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Achievements', style: TextStyle(color: theme.textPrimary)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primary,
          labelColor: theme.primary,
          unselectedLabelColor: theme.textSecondary,
          tabs: const [
            Tab(text: 'Progression'),
            Tab(text: 'Skill'),
            Tab(text: 'Discovery'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildProgressHeader(theme),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAchievementList(
                        Achievements.getByCategory(AchievementCategory.progression),
                        theme,
                      ),
                      _buildAchievementList(
                        Achievements.getByCategory(AchievementCategory.skill),
                        theme,
                      ),
                      _buildAchievementList(
                        Achievements.getByCategory(AchievementCategory.discovery),
                        theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressHeader(GameTheme theme) {
    final unlockedCount = Achievements.unlockedCount(_profile.unlockedAchievements);
    final totalCount = Achievements.totalCount;
    final progress = unlockedCount / totalCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(0.2),
            theme.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: theme.accent, size: 28),
              const SizedBox(width: 12),
              Text(
                '$unlockedCount / $totalCount',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.surface,
              valueColor: AlwaysStoppedAnimation(theme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}% Complete',
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements, GameTheme theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isUnlocked = _profile.unlockedAchievements.contains(achievement.id);

        return _AchievementCard(
          achievement: achievement,
          isUnlocked: isUnlocked,
          theme: theme,
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final GameTheme theme;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? theme.primary.withOpacity(0.15)
            : theme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? theme.primary.withOpacity(0.5)
              : theme.surface,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? theme.primary
                  : theme.textSecondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? Colors.white : theme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? theme.textPrimary : theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnlocked
                        ? theme.textSecondary
                        : theme.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(Icons.check_circle, color: theme.primary, size: 28),
        ],
      ),
    );
  }
}

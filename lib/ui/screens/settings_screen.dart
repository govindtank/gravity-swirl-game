import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage_service.dart';
import '../../core/theme_manager.dart';
import '../../models/player_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  Future<void> _saveProfile() async {
    final storage = context.read<StorageService>();
    await storage.saveProfile(_profile);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final theme = themeManager.currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: theme.textPrimary)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Appearance', theme),
                  _buildThemeSelector(themeManager, theme),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Audio', theme),
                  _buildSlider(
                    label: 'Sound Effects',
                    value: _profile.soundVolume,
                    icon: Icons.volume_up,
                    theme: theme,
                    onChanged: (value) {
                      setState(() => _profile.soundVolume = value);
                      _saveProfile();
                    },
                  ),
                  _buildSlider(
                    label: 'Music',
                    value: _profile.musicVolume,
                    icon: Icons.music_note,
                    theme: theme,
                    onChanged: (value) {
                      setState(() => _profile.musicVolume = value);
                      _saveProfile();
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Gameplay', theme),
                  _buildToggle(
                    label: 'Show FPS',
                    value: _profile.showFPS,
                    icon: Icons.speed,
                    theme: theme,
                    onChanged: (value) {
                      setState(() => _profile.showFPS = value);
                      _saveProfile();
                    },
                  ),
                  _buildToggle(
                    label: 'Haptic Feedback',
                    value: _profile.hapticFeedback,
                    icon: Icons.vibration,
                    theme: theme,
                    onChanged: (value) {
                      setState(() => _profile.hapticFeedback = value);
                      _saveProfile();
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Data', theme),
                  _buildDangerButton(
                    label: 'Reset All Progress',
                    icon: Icons.delete_forever,
                    theme: theme,
                    onPressed: () => _showResetConfirmation(context, theme),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: theme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeManager themeManager, GameTheme currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette, color: currentTheme.textSecondary),
            const SizedBox(width: 12),
            Text(
              'Theme',
              style: TextStyle(
                fontSize: 16,
                color: currentTheme.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: currentTheme.primary,
              ),
              onPressed: () => themeManager.toggleDarkMode(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: GameThemes.themes.values.map((theme) {
            final isSelected = theme.id == currentTheme.id;
            return GestureDetector(
              onTap: () => themeManager.setTheme(theme.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme.primary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.primary.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primary, theme.secondary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      theme.name.split(' ').first,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required IconData icon,
    required GameTheme theme,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textPrimary,
                  ),
                ),
                Slider(
                  value: value,
                  onChanged: onChanged,
                  activeColor: theme.primary,
                  inactiveColor: theme.primary.withOpacity(0.3),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required IconData icon,
    required GameTheme theme,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: theme.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton({
    required String label,
    required IconData icon,
    required GameTheme theme,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.hazardColor,
          side: BorderSide(color: theme.hazardColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, GameTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          'Reset Progress?',
          style: TextStyle(color: theme.textPrimary),
        ),
        content: Text(
          'This will delete all your high scores, achievements, and unlocked items. This action cannot be undone.',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final storage = context.read<StorageService>();
              await storage.resetAllProgress();
              if (mounted) {
                Navigator.pop(context);
                _loadProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Progress reset'),
                    backgroundColor: theme.hazardColor,
                  ),
                );
              }
            },
            child: Text('Reset', style: TextStyle(color: theme.hazardColor)),
          ),
        ],
      ),
    );
  }
}

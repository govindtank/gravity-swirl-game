import 'package:flutter/material.dart';

/// Settings Screen for game configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _difficultyMultiplier = 1.0;
  int _particlesCount = 60;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Audio & Haptics'),
            ToggleSetting(
              label: 'Sound Effects',
              value: _soundEnabled,
              onChanged: (value) => setState(() => _soundEnabled = value),
            ),
            const SizedBox(height: 16),
            ToggleSetting(
              label: 'Haptic Feedback',
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
            ),
            
            const Divider(height: 32),
            
            _SectionHeader(title: 'Game Settings'),
            SettingRow(
              label: 'Difficulty Multiplier',
              value: '${_difficultyMultiplier}x',
              onChanged: (value) {
                final double newVal = double.tryParse(value) ?? 1.0;
                setState(() => _difficultyMultiplier = newVal.clamp(0.5, 3.0));
              },
            ),
            const SizedBox(height: 16),
            SliderSetting(
              label: 'Particle Count',
              value: _particlesCount.toDouble(),
              min: 20,
              max: 120,
              divisions: 10,
              onChanged: (value) {
                setState(() => _particlesCount = value.toInt());
              },
            ),
            
            const Divider(height: 32),
            
            _SectionHeader(title: 'About'),
            SettingRow(
              label: 'Version',
              value: '1.0.0',
            ),
            SettingRow(
              label: 'GitHub',
              value: 'github.com/govindtank/gravity-swirl-game',
              onTap: () {
                // Open in browser
                debugPrint('Opening GitHub');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class ToggleSetting extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const ToggleSetting({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      subtitle: const Text('Toggle audio or haptic feedback'),
      value: value,
      onChanged: onChanged,
    );
  }
}

class SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  
  const SettingRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value),
      onTap: onChanged == null ? onTap : () => _handleOnChanged(context),
      onLongPress: onTap,
    );
  }
}

class SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  
  const SliderSetting({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: onChanged,
        ),
        Text(
          '${value.toInt()} items',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }
}

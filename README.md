# Gravity Swirl Game

## Overview
A captivating physics-based puzzle game featuring swirling gravity mechanics. Test your skills in this engaging platformer with dynamic gravity systems.

## Features
- 🌀 Dynamic gravity swirl mechanics
- ⭐ Smooth, 60fps animations
- 🎮 Touch and swipe controls
- 💫 Particle effects and visual feedback
- 🔐 Progressive difficulty levels
- 🎨 Beautiful, hand-crafted art style

## Gameplay
Navigate through carefully designed levels where gravity shifts in mesmerizing patterns. Use the swirl mechanics to your advantage as you guide your character through challenging puzzles.

## Getting Started

### Prerequisites
- [Flutter](https://flutter.dev) SDK >= 3.5.0
- [Dart](https://dart.dev) SDK >= 3.5.0

### Installation
```bash
git clone https://github.com/govind/gravity-swirl-game.git
cd gravity-swirl-game
flutter pub get
flutter run
```

### Development
```bash
# Run on device or emulator
flutter run -d <device_id>

# Debug mode
flutter run --debug

# Hot reload
flutter run
```

## Project Structure
```
gravity_swirl_game/
├── lib/
│   ├── main.dart              # App entry point
│   ├── game/                  # Game logic
│   │   ├── swirl_engine.dart  # Gravity mechanics
│   │   └── physics_controller.dart
│   ├── screens/               # UI layers
│   │   ├── game_screen.dart
│   │   └── menu_screen.dart
│   └── assets/                # Game assets
├── pubspec.yaml              # Dependencies and metadata
├── analysis_options.yaml     # Linting rules
└── README.md                # This file
```

## Dependencies
- `flutter`: Flutter SDK
- Additional packages listed in pubspec.yaml for:
  - Animation framework
  - Particle effects
  - Asset management

## Controls
- **Swipe**: Guide character movement
- **Tap**: Trigger special abilities
- **Hold**: Maintain gravity direction

## Level Progression
- 10 hand-crafted levels
- Hidden collectibles
- Speed challenges
- Secret areas to discover

## Tips for Success
1. Learn each level's gravity pattern
2. Plan multi-step solutions
3. Use collectibles to restore health
4. Experiment with different approaches

## Contributing
Pull requests are welcome! Please open an issue first to discuss major changes.

## License
MIT License - See LICENSE file for details.

# 🌀 Gravity Swirl

![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?style=flat-square&logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Mobile-FF6B6B?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

### 🌐 **Live Demo**: [https://govindtank.github.io/gravity-swirl-game/](https://govindtank.github.io/gravity-swirl-game/)

---

A captivating physics-based puzzle game featuring swirling gravity mechanics. Guide particles through cosmic gravity wells by drawing paths with your finger or mouse. Built with pure Flutter using CustomPaint — no external game engine required.

![Game Preview](https://img.shields.io/badge/Game-Physics%20Puzzle-6366F1?style=for-the-badge)

---

## ✨ Features

- 🌀 **Dynamic Gravity Physics** - Particles respond realistically to multiple gravity wells with inverse-square attraction
- 🎮 **Path Drawing** - Tap and drag to draw paths that influence particle movement
- ⭐ **Progressive Difficulty** - Procedurally generated levels with increasing complexity
- 💫 **Smooth 60 FPS** - Optimized CustomPaint-based animations for fluid performance
- 🎨 **Beautiful Dark Theme** - Stunning cosmic visuals with gradient effects
- 📱 **Cross-Platform** - Works on Web, iOS, Android, and Desktop
- ⚡ **Instant Play** - No installation required, play directly in browser

---

## 🎯 Gameplay

Navigate particles through space by guiding them with touch/mouse input. The particles are attracted to gravity wells placed around the level. Your goal is to collect all goal markers to complete each level.

### Controls
- **Tap & Drag** - Draw a path to influence particle movement
- **Release** - Path fades after 2 seconds
- **Collect All Stars** - Complete the level and advance

---

## 🛠 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.24** | Cross-platform UI framework |
| **CustomPaint** | Hardware-accelerated canvas rendering |
| **ChangeNotifier** | Reactive state management |
| **Dart** | Programming language |
| **GitHub Actions** | CI/CD automation |
| **GitHub Pages** | Static hosting |

---

## 📁 Project Structure

```
gravity_swirl_game/
├── lib/
│   └── main.dart          # Single-file game: physics engine, UI, screens
├── web/
│   └── index.html         # Web entry point
├── pubspec.yaml           # Dependencies & metadata
├── analysis_options.yaml  # Linting rules
├── .github/
│   └── workflows/
│       └── deploy.yml     # GitHub Actions CI/CD workflow
└── README.md              # Documentation
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.5.0 or higher
- Dart SDK 3.5.0 or higher

### Installation & Running

```bash
# Clone the repository
git clone https://github.com/govindtank/gravity-swirl-game.git
cd gravity-swirl-game

# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on connected device
flutter run

# Build for production (Web)
flutter build web --release --base-href /gravity-swirl-game/
```

### Development

```bash
# Run with hot reload
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 🎮 Game Architecture

### Core Components

| Component | Description |
|-----------|-------------|
| `GravitySwirlGameEngine` | Physics engine with gravity well simulation and particle movement |
| `GameState` | Holds game data: score, level, particles, goals, repulsion zones |
| `GameCanvas` | StatefulWidget with AnimationController for 60fps game loop |
| `GamePainter` | CustomPainter rendering all game elements to canvas |
| `HomeScreen` | Animated landing page with gradient background |

### Physics System

- **Gravity Wells**: Points that attract particles with inverse-square force
- **Path Influence**: User-drawn paths create temporary force fields
- **Repulsion Zones**: Rectangular areas that push particles away (higher levels)
- **Damping**: Velocity multiplied by 0.95 per frame for stable physics

---

## 🎨 UI Components

- **HomeScreen**: Animated logo, gradient background, animated buttons
- **GameScreen**: Full-screen canvas with HUD overlay showing level and score
- **GameCanvas**: GestureDetector + CustomPaint for game rendering
- **Responsive Design**: LayoutBuilder adapts to all screen sizes

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
```

---

## 🔄 CI/CD Pipeline

The project uses GitHub Actions for automated deployment:

1. **Trigger**: Push to `main` branch or manual workflow dispatch
2. **Build**: Flutter web build with `--base-href /gravity-swirl-game/`
3. **Deploy**: Upload artifact to GitHub Pages

View the workflow: [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)

---

## 💡 Usage Examples

### Using Sound Effects

```dart
import 'package:gravity_swirl_game/sounds/audio_manager.dart';

// Create audio manager singleton
final audioManager = AudioManager();

// Play sound when particle is collected
audioManager.play(AudioManager.Effect.particleCollect);

// Toggle mute globally
audioManager.toggleMute(true);
```

### Using Settings Screen

```dart
import 'package:gravity_swirl_game/settings/settings_screen.dart';

// Add to app navigation
Scaffold(
  body: Stack(
    children: [
      GameCanvas(),
      Positioned(
        top: 10,
        right: 10,
        child: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SettingsScreen()),
          ),
        ),
      ),
    ],
  ),
);
```

### Customizing Physics

Modify force magnitudes in `GravitySwirlGameEngine.update()`:

```dart
// Adjust gravity well attraction strength
double forceMagnitude = 1.5 / (distance * distance);

// Adjust damping rate
particle.velocity = particle.velocity * 0.95; // Try: 0.92 for stronger damping
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Govind Tank** - [GitHub](https://github.com/govindtank)

---

<p align="center">
  <strong>Made with ❤️ using Flutter</strong>
</p>

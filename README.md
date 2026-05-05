# 🌀 Gravity Swirl

![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?style=flat-square&logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Mobile-FF6B6B?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![Deploy](https://github.com/govindtank/gravity-swirl-game/actions/workflows/deploy.yml/badge.svg)](https://github.com/govindtank/gravity-swirl-game/actions/workflows/deploy.yml)

### 🌐 **Live Demo**: [https://govindtank.github.io/gravity-swirl-game/](https://govindtank.github.io/gravity-swirl-game/)

---

A captivating physics-based puzzle game featuring swirling gravity mechanics. Guide particles through cosmic gravity wells in this engaging game built with Flutter and Flame engine.

![Game Preview](https://img.shields.io/badge/Game-Physics%20Puzzle-6366F1?style=for-the-badge)

---

## ✨ Features

- 🌀 **Dynamic Gravity Physics** - Particles respond realistically to multiple gravity wells
- 🎮 **Intuitive Controls** - Tap and drag to guide particles through the cosmic void
- ⭐ **Progressive Difficulty** - Procedurally generated levels with increasing complexity
- 💫 **Smooth 60 FPS** - Optimized animations for a fluid gaming experience
- 🎨 **Beautiful Dark Theme** - Stunning cosmic visuals with gradient effects
- 📱 **Cross-Platform** - Works on Web, iOS, Android, and Desktop
- ⚡ **Instant Play** - No installation required, play directly in browser

---

## 🎯 Gameplay

Navigate particles through space by guiding them with touch/mouse input. The particles are attracted to gravity wells placed around the level. Your goal is to collect all goal markers to complete each level.

### Controls
- **Tap & Drag** - Guide particle movement
- **Release** - Let physics take over
- **Collect All Stars** - Complete the level

---

## 🛠 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.24** | Cross-platform UI framework |
| **Flame 1.10** | 2D game engine for Flutter |
| **Dart** | Programming language |
| **GitHub Actions** | CI/CD automation |
| **GitHub Pages** | Static hosting |

---

## 📁 Project Structure

```
gravity_swirl_game/
├── lib/
│   └── main.dart          # Main game code with physics engine, UI components
├── web/
│   └── index.html         # Web entry point with custom loading screen
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

# Run in debug mode
flutter run --debug

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
| `GravitySwirlGame` | Main game engine extending FlameGame |
| `Particle` | Physics unit with gravity simulation |
| `ParticleEmitterComponent` | Manages particle system |
| `GoalMarker` | Collectible objectives |
| `ProceduralGenerator` | Generates dynamic levels |

### Physics System

- **Gravity Wells**: Points that attract particles with inverse-square force
- **Path Influence**: User-drawn paths create temporary force fields
- **Repulsion Zones**: Areas that push particles away
- **Damping**: Simulates friction for stable physics

---

## 🎨 UI Components

- **HomeScreen**: Animated landing page with gradient backgrounds
- **GameGameWrapper**: Game canvas with HUD overlay
- **Responsive Design**: Adapts to all screen sizes

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.10.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## 🔄 CI/CD Pipeline

The project uses GitHub Actions for automated deployment:

1. **Trigger**: Push to `main` branch or manual workflow dispatch
2. **Build**: Flutter web build with `--base-href /gravity-swirl-game/`
3. **Deploy**: Upload artifact to GitHub Pages

View the workflow: [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)

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

## 🙏 Acknowledgments

- [Flame Engine](https://github.com/flame-engine/flame) - Amazing 2D game engine
- [Flutter](https://flutter.dev) - Google's UI toolkit
- Open source community

---

<p align="center">
  <strong>Made with ❤️ using Flutter & Flame</strong>
</p>

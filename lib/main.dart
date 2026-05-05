import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// ========================================================
// CONSTANTS & THEME
// ========================================================

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color backgroundColor = Color(0xFF0F0F23);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -1),
        displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      ),
    );
  }
}

// ========================================================
// DATA STRUCTURES
// ========================================================

class GameRect {
  final double x, y, width, height;
  GameRect(this.x, this.y, this.width, this.height);
  bool contains(Offset point) {
    return point.dx >= x && point.dx <= x + width && point.dy >= y && point.dy <= y + height;
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double radius;
  
  Particle({required this.position, required this.velocity, required this.radius});
}

class GoalMarker {
  Offset position;
  int value;
  bool collected = false;
  
  GoalMarker({required this.position, required this.value});
  
  bool checkCollection(Offset particlePos) {
    return (particlePos - position).distance < 40;
  }
}

// ========================================================
// GAME STATE
// ========================================================

class GameState {
  int score = 0;
  int currentLevel = 1;
  List<Offset> gravityWells = [];
  List<Particle> particles = [];
  List<GoalMarker> goals = [];
  List<GameRect> repulsionZones = [];
  Color backgroundColor = const Color(0xFF0A0A2A);
}

// ========================================================
// GAME ENGINE
// ========================================================

class GravitySwirlGameEngine extends ChangeNotifier {
  GameState state = GameState();
  final Random _random = Random();
  List<Offset> pathPoints = [];
  
  void startGame() {
    loadLevel(1);
  }
  
  void loadLevel(int level) {
    state = GameState();
    state.currentLevel = level;
    
    final double sizeX = 800;
    final double sizeY = 600;
    
    // Generate gravity wells
    if (level < 2) {
      state.backgroundColor = const Color(0xFF0A0A2A);
      state.gravityWells = [
        Offset(_random.nextDouble() * sizeX * 0.4 + 50, _random.nextDouble() * sizeY * 0.4 + 50),
        Offset(_random.nextDouble() * sizeX * 0.3 + sizeX * 0.5, _random.nextDouble() * sizeY * 0.3 + 100),
        Offset(_random.nextDouble() * sizeX * 0.2 + sizeX * 0.7, _random.nextDouble() * sizeY * 0.1 + 50),
      ];
    } else if (level < 4) {
      state.backgroundColor = const Color(0xFF1A0A3A);
      state.gravityWells = [
        Offset(_random.nextDouble() * sizeX * 0.3 + 50, _random.nextDouble() * sizeY * 0.4 + 50),
        Offset(_random.nextDouble() * sizeX * 0.4 + sizeX * 0.4, _random.nextDouble() * sizeY * 0.2 + 100),
        Offset(_random.nextDouble() * sizeX * 0.3 + sizeX * 0.6, _random.nextDouble() * sizeY * 0.4 + 50),
      ];
    } else {
      state.backgroundColor = const Color(0xFF1A0A1F);
      state.gravityWells = [
        Offset(_random.nextDouble() * sizeX * 0.2 + 50, _random.nextDouble() * sizeY * 0.3 + 50),
        Offset(_random.nextDouble() * sizeX * 0.4 + sizeX * 0.4, _random.nextDouble() * sizeY * 0.2 + 100),
        Offset(_random.nextDouble() * sizeX * 0.2 + sizeX * 0.6, _random.nextDouble() * sizeY * 0.3 + 50),
        Offset(_random.nextDouble() * sizeX * 0.1 + 100, _random.nextDouble() * sizeY * 0.4 + 50),
      ];
    }
    
    // Generate goal markers
    int numGoals = level < 3 ? 3 : (level < 5 ? 4 : 6);
    for (int i = 0; i < numGoals; i++) {
      state.goals.add(GoalMarker(
        position: Offset(
          _random.nextDouble() * (sizeX * 0.8) + sizeX * 0.1,
          _random.nextDouble() * (sizeY * 0.8) + sizeY * 0.1,
        ),
        value: 5 + level * 2,
      ));
    }
    
    // Generate repulsion zones for higher levels
    if (level >= 2) {
      int numZones = level < 4 ? 1 : (level < 5 ? 2 : 3);
      for (int i = 0; i < numZones; i++) {
        state.repulsionZones.add(GameRect(
          _random.nextDouble() * (sizeX * 0.3) + _random.nextDouble() * (sizeX * 0.2),
          _random.nextDouble() * (sizeY * 0.25) + _random.nextDouble() * (sizeY * 0.1),
          _random.nextDouble() * (sizeX * 0.3) + sizeX * 0.1,
          _random.nextDouble() * (sizeY * 0.25) + sizeY * 0.05,
        ));
      }
    }
    
    // Create particles
    for (int i = 0; i < 60; i++) {
      state.particles.add(Particle(
        position: Offset(
          _random.nextDouble() * sizeX * 0.8 + sizeX * 0.1,
          _random.nextDouble() * sizeY * 0.8 + sizeY * 0.1,
        ),
        velocity: Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1) * 3,
        radius: 3.0 + _random.nextDouble() * 2,
      ));
    }
    
    notifyListeners();
  }
  
  void update(double dt, Size gameSize) {
    for (var particle in state.particles) {
      Offset totalForce = Offset.zero;
      
      // Gravity well forces
      for (var well in state.gravityWells) {
        Offset direction = well - particle.position;
        double distance = direction.distance;
        if (distance > 1.0) {
          double forceMagnitude = 1.5 / (distance * distance);
          totalForce += direction / distance * forceMagnitude;
        }
      }
      
      // Path influence
      if (pathPoints.isNotEmpty) {
        Offset lastPoint = pathPoints.last;
        Offset toPathCenter = lastPoint - particle.position;
        totalForce += Offset(toPathCenter.dx / 150, toPathCenter.dy / 150);
      }
      
      // Repulsion zones
      for (var zone in state.repulsionZones) {
        if (zone.contains(particle.position)) {
          Offset zoneCenter = Offset(zone.x + zone.width / 2, zone.y + zone.height / 2);
          Offset displacement = particle.position - zoneCenter;
          double distFromCenter = displacement.distance;
          if (distFromCenter > 5) {
            double forceMagnitude = 3.0 / (1 + (distFromCenter - 5).clamp(0, 20) * 0.05);
            totalForce += displacement / distFromCenter * forceMagnitude;
          }
        }
      }
      
      // Apply physics
      particle.velocity = particle.velocity * 0.95 + totalForce * 0.016;
      particle.position = particle.position + particle.velocity * 0.016;
      
      // Boundary clamping
      particle.position = Offset(
        particle.position.dx.clamp(-5, gameSize.width + 5),
        particle.position.dy.clamp(-5, gameSize.height + 5),
      );
    }
    
    // Check goal collection
    for (var goal in state.goals) {
      if (!goal.collected) {
        for (var particle in state.particles) {
          if (goal.checkCollection(particle.position)) {
            goal.collected = true;
            state.score += goal.value;
            break;
          }
        }
      }
    }
    
    // Check win condition
    if (state.goals.every((g) => g.collected)) {
      Future.delayed(const Duration(seconds: 1), () {
        loadLevel(state.currentLevel + 1);
      });
    }
    
    notifyListeners();
  }
  
  void addPathPoint(Offset point) {
    pathPoints.add(point);
    if (pathPoints.length > 50) {
      pathPoints.removeAt(0);
    }
  }
  
  void clearPath() {
    pathPoints.clear();
  }
}

// ========================================================
// GAME CANVAS WIDGET
// ========================================================

class GameCanvas extends StatefulWidget {
  const GameCanvas({super.key});

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> with SingleTickerProviderStateMixin {
  late final GravitySwirlGameEngine _game;
  late final AnimationController _controller;
  Size _gameSize = const Size(800, 600);
  final GlobalKey _canvasKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _game = GravitySwirlGameEngine();
    _game.startGame();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    _controller.addListener(_onTick);
  }
  
  void _onTick() {
    _game.update(0.016, _gameSize);
  }
  
  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }
  
  void _updateGameSize() {
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _gameSize = renderBox.size;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _gameSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        return GestureDetector(
          onPanStart: (details) {
            _game.addPathPoint(details.localPosition);
          },
          onPanUpdate: (details) {
            _game.addPathPoint(details.localPosition);
          },
          onPanEnd: (_) {
            Future.delayed(const Duration(seconds: 2), () {
              _game.clearPath();
            });
          },
          child: ListenableBuilder(
            listenable: _game,
            builder: (context, child) {
              return CustomPaint(
                key: _canvasKey,
                size: Size.infinite,
                painter: GamePainter(
                  state: _game.state,
                  pathPoints: _game.pathPoints,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class GamePainter extends CustomPainter {
  final GameState state;
  final List<Offset> pathPoints;
  
  GamePainter({required this.state, required this.pathPoints});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = state.backgroundColor,
    );
    
    // Repulsion zones
    for (var zone in state.repulsionZones) {
      canvas.drawRect(
        Rect.fromLTWH(zone.x, zone.y, zone.width, zone.height),
        Paint()..color = Colors.red.withOpacity(0.2),
      );
    }
    
    // Path
    if (pathPoints.length > 1) {
      final path = Path();
      path.moveTo(pathPoints.first.dx, pathPoints.first.dy);
      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.yellow.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    
    // Gravity wells
    for (var well in state.gravityWells) {
      // Glow
      canvas.drawCircle(
        well,
        30,
        Paint()..color = Colors.redAccent.withOpacity(0.3),
      );
      // Core
      canvas.drawCircle(
        well,
        20,
        Paint()..color = Colors.redAccent.withOpacity(0.6),
      );
    }
    
    // Goal markers
    for (var goal in state.goals) {
      if (!goal.collected) {
        canvas.drawCircle(
          goal.position,
          25,
          Paint()..color = Colors.blueAccent.withOpacity(0.9),
        );
        // Star effect
        canvas.drawCircle(
          goal.position,
          30,
          Paint()
            ..color = Colors.blue.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    
    // Particles
    for (var particle in state.particles) {
      canvas.drawCircle(
        particle.position,
        particle.radius,
        Paint()..color = Colors.white.withOpacity(0.8),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

// ========================================================
// GAME SCREEN
// ========================================================

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GravitySwirlGameEngine _game = GravitySwirlGameEngine();
  
  @override
  void initState() {
    super.initState();
    _game.startGame();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game canvas
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _game,
              builder: (context, child) {
                return GestureDetector(
                  onPanStart: (details) {
                    _game.addPathPoint(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _game.addPathPoint(details.localPosition);
                  },
                  onPanEnd: (_) {
                    Future.delayed(const Duration(seconds: 2), () {
                      _game.clearPath();
                    });
                  },
                  child: CustomPaint(
                    painter: GamePainter(
                      state: _game.state,
                      pathPoints: _game.pathPoints,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // HUD
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                child: ListenableBuilder(
                  listenable: _game,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
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
                                "Level ${_game.state.currentLevel}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Score
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.accentColor.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, color: AppTheme.accentColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "${_game.state.score}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Tap & drag to guide particles",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// HOME SCREEN
// ========================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F23)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Animated Logo
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
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.swipe, size: 60, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor, AppTheme.accentColor],
                    ).createShader(bounds),
                    child: const Text(
                      "Gravity Swirl",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Master the Physics of the Cosmos",
                    style: TextStyle(fontSize: 16, color: Colors.white60, letterSpacing: 1),
                  ),
                  const SizedBox(height: 48),

                  // Start Game Button
                  _AnimatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return const GameScreen();
                          },
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    icon: Icons.play_arrow_rounded,
                    label: "START GAME",
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),

                  // High Scores Button
                  _AnimatedButton(
                    onPressed: () => _showComingSoonDialog(context),
                    icon: Icons.emoji_events_outlined,
                    label: "HIGH SCORES",
                    isPrimary: false,
                  ),
                  const SizedBox(height: 16),

                  // Settings Button
                  _AnimatedButton(
                    onPressed: () => _showComingSoonDialog(context),
                    icon: Icons.settings_outlined,
                    label: "SETTINGS",
                    isPrimary: false,
                  ),
                  const SizedBox(height: 48),

                  // Features row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeatureChip(icon: Icons.swipe, label: "60 FPS"),
                      SizedBox(width: 16),
                      _FeatureChip(icon: Icons.auto_awesome, label: "5+ Levels"),
                      SizedBox(width: 16),
                      _FeatureChip(icon: Icons.public, label: "Web Ready"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.construction, color: AppTheme.accentColor),
            SizedBox(width: 12),
            Text("Coming Soon", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "This feature is under development. Stay tuned for updates!",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it!", style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _AnimatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
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
        child: widget.isPrimary
            ? ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(minimumSize: const Size(280, 60)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 28),
                    const SizedBox(width: 12),
                    Text(widget.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              )
            : OutlinedButton(
                onPressed: widget.onPressed,
                style: OutlinedButton.styleFrom(minimumSize: const Size(280, 56)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 24),
                    const SizedBox(width: 12),
                    Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.secondaryColor),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ========================================================
// MAIN
// ========================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(MaterialApp(
    title: 'Gravity Swirl',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: const HomeScreen(),
  ));
}

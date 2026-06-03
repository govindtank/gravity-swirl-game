import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/game_engine.dart';
import 'game/game_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CosmicDriftApp());
}

class CosmicDriftApp extends StatelessWidget {
  const CosmicDriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmic Drift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        fontFamily: 'monospace',
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final CosmicGameState _gameState = CosmicGameState();
  int _screen = 0; // 0=home, 1=game, 2=levels
  int _startLevel = 0;
  int _unlockedLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final ul = prefs.getInt('cosmic_unlocked') ?? 0;
    final hs = prefs.getInt('cosmic_highscore') ?? 0;
    if (mounted) {
      setState(() {
        _unlockedLevel = ul;
        _gameState.maxUnlockedLevel = ul;
        _gameState.highScore = hs;
        _gameState.score = hs;
      });
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cosmic_unlocked', _unlockedLevel);
    await prefs.setInt('cosmic_highscore', _gameState.highScore);
  }

  void startLevel(int index) {
    setState(() {
      _startLevel = index;
      _screen = 1;
    });
  }

  void onLevelComplete() {
    final next = _startLevel + 1;
    if (next > _unlockedLevel && next < cosmicLevels.length) {
      _unlockedLevel = next;
      _gameState.maxUnlockedLevel = next;
    }
    _saveProgress();
    if (next < cosmicLevels.length) {
      startLevel(next);
    } else {
      setState(() => _screen = 0);
    }
  }

  void onGameOver() {
    _saveProgress();
    setState(() => _screen = 0);
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case 0:
        return _HomeScreen(
          highScore: _gameState.highScore,
          unlockedLevel: _unlockedLevel,
          onPlay: () => startLevel(0),
          onLevelSelect: () => setState(() => _screen = 2),
        );
      case 1:
        return _GameScreen(
          key: ValueKey('game_$_startLevel'),
          gameState: _gameState,
          startLevel: _startLevel,
          onLevelComplete: onLevelComplete,
          onGameOver: onGameOver,
          onQuit: () {
            _gameState.status = GameStatus.menu;
            setState(() => _screen = 0);
          },
        );
      case 2:
        return _LevelSelectScreen(
          unlockedLevel: _unlockedLevel,
          onSelect: startLevel,
          onBack: () => setState(() => _screen = 0),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ══════════════════════════════════════════════════════════════
// HOME SCREEN
// ══════════════════════════════════════════════════════════════

class _HomeScreen extends StatefulWidget {
  final int highScore;
  final int unlockedLevel;
  final VoidCallback onPlay;
  final VoidCallback onLevelSelect;

  const _HomeScreen({
    required this.highScore,
    required this.unlockedLevel,
    required this.onPlay,
    required this.onLevelSelect,
  });

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // Starfield background
          CustomPaint(
            size: size,
            painter: _StarfieldPainter(_pulse.value),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(flex: 2),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF00E5FF),
                      Color(0xFF7C4DFF),
                      Color(0xFFFF6B35),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'COSMIC',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) {
                    final opacity = 0.5 + _pulse.value * 0.5;
                    return Text(
                      'DRIFT',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w100,
                        color: Color.fromRGBO(0, 229, 255, opacity),
                        letterSpacing: 16,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'NAVIGATE THE GRAVITY FIELDS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 4,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 40),
                _NeonBtn(
                  label: '▶  PLAY',
                  color: const Color(0xFF00E5FF),
                  onTap: widget.onPlay,
                ),
                const SizedBox(height: 16),
                _NeonBtn(
                  label: '📋  LEVELS',
                  color: const Color(0xFF7C4DFF),
                  onTap: widget.onLevelSelect,
                ),
                const SizedBox(height: 24),
                if (widget.highScore > 0)
                  _StatChip(
                    icon: Icons.emoji_events,
                    label: 'Best: ${widget.highScore}',
                    color: const Color(0xFFFFD700),
                  ),
                const Spacer(),
                // How to play
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'HOW TO PLAY',
                        style: TextStyle(
                          color: const Color(0xFF00E5FF),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _howToItem('🖱️', 'Drag from ship to apply thrust'),
                      _howToItem('🌌', 'Gravity wells pull your ship'),
                      _howToItem('⭐', 'Collect all stars to unlock the portal'),
                      _howToItem('🌀', 'Reach the portal to complete the level'),
                      _howToItem('⚠️', 'Avoid black holes — they destroy your ship'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _howToItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final double phase;
  _StarfieldPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 80; i++) {
      final x = (i * 137.5) % size.width;
      final y = (i * 97.3 + sin(i + phase * 10) * 15) % size.height;
      canvas.drawCircle(Offset(x, y), 0.5 + (i % 3) * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter o) => true;
}

// ══════════════════════════════════════════════════════════════
// GAME SCREEN
// ══════════════════════════════════════════════════════════════

class _GameScreen extends StatefulWidget {
  final CosmicGameState gameState;
  final int startLevel;
  final VoidCallback onLevelComplete;
  final VoidCallback onGameOver;
  final VoidCallback onQuit;

  const _GameScreen({
    super.key,
    required this.gameState,
    required this.startLevel,
    required this.onLevelComplete,
    required this.onGameOver,
    required this.onQuit,
  });

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _lastTime = 0;
  double _animTime = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.gameState.init(MediaQuery.of(context).size, widget.startLevel);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1000000.0;
    final dt = _lastTime == 0 ? 0.016 : (now - _lastTime).clamp(0.001, 0.05);
    _lastTime = now;
    _animTime += dt;

    if (!_paused) {
      widget.gameState.update(dt);
    }

    if (mounted) {
      setState(() {});

      if (widget.gameState.status == GameStatus.levelComplete) {
        _ticker.stop();
        Future.delayed(const Duration(milliseconds: 800), widget.onLevelComplete);
      } else if (widget.gameState.status == GameStatus.gameOver) {
        _ticker.stop();
        Future.delayed(const Duration(milliseconds: 1500), widget.onGameOver);
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gs = widget.gameState;
    final def = cosmicLevels[gs.currentLevel.clamp(0, cosmicLevels.length - 1)];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // Game canvas
          GestureDetector(
            onPanStart: (d) => gs.handleDragStart(d.localPosition.dx, d.localPosition.dy),
            onPanUpdate: (d) => gs.handleDragMove(d.localPosition.dx, d.localPosition.dy),
            onPanEnd: (_) => gs.handleDragEnd(),
            onPanCancel: () => gs.handleDragEnd(),
            child: CustomPaint(
              size: size,
              painter: CosmicGamePainter(gs, _animTime),
            ),
          ),

          // UI overlay
          SafeArea(
            child: Column(
              children: [
                // Top HUD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      // Level name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: def.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: def.accentColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          'L${gs.currentLevel + 1}',
                          style: TextStyle(color: def.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Stars collected
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 12, color: Color(0xFFFFD700)),
                            const SizedBox(width: 4),
                            Text(
                              '${gs.starsCollected}/${gs.totalStarsInLevel}',
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                        ),
                        child: Text(
                          '${gs.score}',
                          style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      // Pause
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: Colors.white54, size: 20),
                        onPressed: () => setState(() => _paused = !_paused),
                      ),
                    ],
                  ),
                ),
                // Level name
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    def.name,
                    style: TextStyle(
                      color: def.accentColor.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const Spacer(),

                // Portal status at bottom
                if (!gs.portal!.active && gs.totalStarsInLevel > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.15)),
                      ),
                      child: Text(
                        'Collect all stars to open the portal',
                        style: TextStyle(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Pause overlay
          if (_paused)
            Container(
              color: const Color(0xCC0A0A1A),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('PAUSED', style: TextStyle(fontSize: 36, color: Colors.white54, letterSpacing: 4)),
                    const SizedBox(height: 24),
                    _NeonBtn(label: 'RESUME', color: const Color(0xFF00E5FF), onTap: () => setState(() => _paused = false)),
                    const SizedBox(height: 12),
                    _NeonBtn(label: 'QUIT', color: const Color(0xFFFF1744), onTap: widget.onQuit),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LEVEL SELECT SCREEN
// ══════════════════════════════════════════════════════════════

class _LevelSelectScreen extends StatelessWidget {
  final int unlockedLevel;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;

  const _LevelSelectScreen({
    required this.unlockedLevel,
    required this.onSelect,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final crossAxis = size.width > 600 ? 5 : 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: onBack),
        title: const Text('SELECT MISSION', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxis,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: cosmicLevels.length,
        itemBuilder: (_, i) {
          final def = cosmicLevels[i];
          final unlocked = i <= unlockedLevel;
          return _MissionTile(
            level: i + 1,
            name: def.name,
            color: def.accentColor,
            unlocked: unlocked,
            onTap: unlocked ? () => onSelect(i) : null,
          );
        },
      ),
    );
  }
}

class _MissionTile extends StatefulWidget {
  final int level;
  final String name;
  final Color color;
  final bool unlocked;
  final VoidCallback? onTap;

  const _MissionTile({
    required this.level,
    required this.name,
    required this.color,
    required this.unlocked,
    this.onTap,
  });

  @override
  State<_MissionTile> createState() => _MissionTileState();
}

class _MissionTileState extends State<_MissionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.unlocked ? widget.color.withOpacity(0.1) : const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.unlocked
                  ? widget.color.withOpacity(_hover ? 0.7 : 0.25)
                  : const Color(0xFF1A1A2E),
            ),
            boxShadow: _hover && widget.unlocked
                ? [BoxShadow(color: widget.color.withOpacity(0.25), blurRadius: 12, spreadRadius: 2)]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${widget.level}', style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: widget.unlocked ? widget.color : const Color(0xFF3A3A4E),
              )),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(widget.name, textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 10,
                  color: widget.unlocked ? widget.color.withOpacity(0.6) : const Color(0xFF2A2A3E),
                )),
              ),
              const SizedBox(height: 4),
              if (widget.unlocked)
                Icon(Icons.lock_open, size: 12, color: widget.color.withOpacity(0.35))
              else
                Icon(Icons.lock, size: 12, color: const Color(0xFF3A3A4E)),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════

class _NeonBtn extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NeonBtn({required this.label, required this.color, required this.onTap});

  @override
  State<_NeonBtn> createState() => _NeonBtnState();
}

class _NeonBtnState extends State<_NeonBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.color, widget.color.withOpacity(0.6)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hover
                ? [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 18, spreadRadius: 3)]
                : [],
          ),
          child: Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

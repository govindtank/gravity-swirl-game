import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// ========================================================
// 1. DATA STRUCTURES (Level Definitions - NO CHANGE)
// ========================================================

class Rect {
  final Offset start;
  final Size size;
  Rect(this.start, this.size);
  bool contains(Offset offset) {
    return offset.dx >= start.dx && offset.dx <= (start.dx + size.width) &&
           offset.dy >= start.dy && offset.dy <= (start.dy + size.height);
  }
}

class LevelDefinition {
  final int levelId;
  final List<Offset> gravityWells; 
  final List<{offset: Offset, value: int}> goalMarkersData; 
  final Color backgroundOverride; 
  final List<Rect>? repulsionZones; 

  LevelDefinition({
    required this.levelId,
    required this.gravityWells,
    required this.goalMarkersData,
    required this.backgroundOverride,
    this.repulsionZones: null,
  });
}


// ========================================================
// 2. GOAL MARKER COMPONENT - NO CHANGE NEEDED
// ========================================================
class GoalMarker extends PositionComponent {
  final int value;
  static const double collectionRadius = 30.0;

  GoalMarker({required Offset offset, required this.value})
      : super(position: Offset(offset.dx, offset.dy), size: Size(50, 50));

  @override
  Future<void> onLoad() async {
    paint = Paint()..style = PaintingStyle.fill;
  }

  void draw(Paint paint) {
     paint.color = Colors.blueAccent.withOpacity(0.9); 
     canvas.drawCircle(Offset(size.width / 2, size.height / 2), collectionRadius, paint);
  }

  bool checkCollection(PositionComponent source) {
    return (source.position - position).distance < (collectionRadius + 10);
  }
}


// ========================================================
// 3. PARTICLE SYSTEM COMPONENT - NO CHANGE NEEDED
// ========================================================
class ParticleEmitterComponent extends PositionComponent {
  ParticleEmitterComponent({required Vector2 initialPosition, required Size size})
      : super(position: Offset(initialPosition.dx, initialPosition.dy), size: size);

  final Random _random = Random();
  late final List<Particle> particles;
  static const int particleCount = 60;

  @override
  Future<void> onLoad() async {
    particles = List.generate(particleCount, (index) {
      return Particle(
          position: Offset(_random.nextDouble() * size.x * 0.8 + size.x * 0.1, _random.nextDouble() * size.y * 0.8 + size.y * 0.1),
          velocity: Vector2(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1) * 3,
          radius: 3.0 + Random().nextDouble() * 2);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (var particle in particles) {
      particle.update(dt, this.position);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Draw the overall visual field glow
    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width/2, paint);

    for (var particle in particles) {
      // Particles draw themselves now
    }
  }

  List<Particle> get activeParticles => particles;
}


// ========================================================
// 4. PHYSICS UNIT - NO CHANGE NEEDED
// ========================================================
class Particle extends PositionComponent {
  Vector2 velocity = Vector2(0, 0);
  double radius;

  Particle({required Offset offset, required this.velocity, required double radius})
      : super(position: Offset(offset.dx, offset.dy), size: Size(radius * 2, radius * 2));

  void update(double dt, Vector2 gravityWellPosition) {
    final context = gameContext as GravitySwirlGame; 
    if (context == null) return;

    // --- Force Calculation ---
    Vector2 wellForce = Vector2(0, 0);
    for (var wellPos in context.gravityWellPositions) {
        Vector2 directionToWell = wellPos - position;
        double distance = directionToWell.distance;
        if (distance > 1.0) {
            var forceMagnitude = 1.5 / (distance * distance);
            wellForce += directionToWell.normalize() * forceMagnitude;
        }
    }

    // Path Force calculation
    Vector2 pathForce = Vector2(0, 0);
    if (context.currentPathPoints.isNotEmpty) {
      final lastPoint = context.currentPathPoints.last;
      var toPathCenter = Offset(lastPoint.dx, lastPoint.dy) - position;
      pathForce += Vector2(toPathCenter.dx / 150, toPathCenter.dy / 150); 
    }

    // Repulsion Force calculation
    Vector2 repulsionForce = Vector2(0, 0);
    for (var zone in context.currentLevel?.repulsionZones ?? []) {
        if (zone.contains(Offset(position.dx!, position.dy!))) {
            double centerX = zone.start.dx + zone.size.width/2;
            double centerY = zone.start.dy + zone.size.height/2;
            Offset zoneCenter = Offset(centerX, centerY);

            var displacement = position - zoneCenter;
            double distFromCenter = displacement.distance;
            if (distFromCenter > 5) { 
                var forceMagnitude = 3.0 / (1 + (distFromCenter - 5).clamp(0, 20) * 0.05); 
                repulsionForce += displacement.normalize() * forceMagnitude;
            }
        }
    }

    // Total Force: Sum of all forces
    Vector2 totalForce = wellForce + pathForce + repulsionForce;

    // Update Position (Physics Integration)
    velocity *= (1 - 0.05); // Damping factor
    velocity += totalForce * 0.016; 
    position += velocity * 0.016; 

     // Boundary clamping for stability
    if (position.dx! < -5 || position.dx! > context.size.x + 5 || 
        position.dy! < -5 || position.dy! > context.size.y + 5) {
            position = Offset(
                position.dx!.clamp(-context.size.x / 2, context.size.x + 5), 
                position.dy!.clamp(-context.size.y / 2, context.size.y + 5)
            );
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }
}


// ========================================================
// 5. THE MAIN GAME ENGINE (Gravity Swirl) - The Brain
// NOTE: Now holds all game state and logic internally.
// ========================================================

class GravitySwirlGame extends FlameGame with Tappable {
  late ParticleEmitterComponent _particleEmitter;
  final GameState gameState = GameState();
  LevelDefinition? currentLevel;
  List<GoalMarker> activeGoalMarkers = []; 

  GravitySwirlGame() : super() {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Start the game automatically at Level 1
    loadLevel(ProceduralGenerator.generateLevelData(difficulty: 1));
  }

  // --- Level Management (Core Function) ---
  void loadLevel(LevelDefinition levelData) {
    print("\n=========================");
    print("✨ LOADING LEVEL ${levelData.levelId}! ✨");
    
    children.addAll([]); // Clear everything before starting a new level
    
    // 1. Set up environment (background, wells, goals, obstacles)
    backgroundColor = levelData.backgroundOverride;

    for (var pos in levelData.gravityWells) {
      final wellMarker = PositionComponent(size: Size(40, 40));
      wellMarker.paint = Paint()..color = Colors.redAccent;
      wellMarker.position = Offset(pos.dx, pos.dy);
      add(wellMarker);
    }

    activeGoalMarkers.clear(); 
    for (var markerData in levelData.goalMarkersData) {
        final marker = GoalMarker(offset: markerData['offset'] as Offset, value: markerData['value'] as int);
        add(marker);
        activeGoalMarkers.add(marker);
        gameState.addGoalMarker(marker); 
    }

    if (levelData.repulsionZones != null) {
        for (var rect in levelData.repulsionZones!) {
            final zoneVisual = PositionComponent(size: Size(rect.size.width, rect.size.height));
            zoneVisual.paint = Paint()..color = Colors.red.withOpacity(0.2); 
            add(zoneVisual);
        }
    }

    // Reset Emitter and State for the new level
    _particleEmitter = ParticleEmitterComponent(
      initialPosition: Offset(size.x / 2, size.y / 2),
      size: Size(size.x * 0.95, size.y * 0.95), 
    );
    add(_particleEmitter);

    // Update internal state trackers and reset score/progress
    currentLevel = levelData;
    gameState.score = 0;
}


  // --- Input Handling (Tappable Mixin) ---
  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    currentPathPoints = [Offset(info.globalPosition.dx, info.globalPosition.dy)];
  }

  @override
  void onDragUpdate(DragUpdateInfo info) {
    super.onDragUpdate(info);
    currentPathPoints.add(Offset(info.globalPosition.dx, info.globalPosition.dy));
  }
  
  @override
  void onPanEnd(DragEndInfo info) {}

  // --- Game Loop Logic (The Physics Engine & Goal Check) ---
  @override
  void update(double dt) {
    super.update(dt);
    if(!currentLevel) return; 

    List<Particle> activeParticles = _particleEmitter.activeParticles;


    for (var particle in activeParticles) {
        // Physics Update: Use the first well's position as a necessary argument filler
        particle.update(dt, gravityWellPositions[0]); 
        
        // Collision Detection
        for (var marker in activeGoalMarkers) { 
            if (!marker.isVisible && !marker.hasMaster) continue;

            if (particle.checkCollection(this)) {
                gameState.addScore(marker.value);
                print('Collected Marker! +${marker.value} points.');

                marker.removeFromParent(); // Visual removal
                activeGoalMarkers.remove(marker); 
            }
        }
    }


    // Path Management & Win Condition Check:
    if (currentPathPoints.isNotEmpty && (DateTime.now().second % 10 < 1)) {
        currentPathPoints.clear(); 
    }

    int remainingMarkers = activeGoalMarkers.length;
    if (remainingMarkers == 0) {
      _levelComplete();
    }
  }


  void _levelComplete() {
    print("\n=========================");
    print("🏆 LEVEL ${currentLevel!.levelId} COMPLETE! ✨");
    print("Final Score: ${gameState.score}");

    int nextLevelIndex = currentLevel!.levelId;
    if (nextLevelIndex < levelConfigs.length) { 
        final nextLevelData = levelConfigs[nextLevelIndex];
        loadLevel(nextLevelData); // Seamlessly transition to the next level's data
    } else {
        print("🎉 CONGRATULATIONS! YOU HAVE MASTERED THE GAME!");
    }
  }

  // --- Drawing Overlays for User Feedback ---
  @override
  void paint(PaintingContext occupiedPaint) {
    super.paint(occupiedPaint);
    if (currentPathPoints.isNotEmpty) {
        final path = Path();
        path.moveTo(currentPathPoints[0].dx, currentPathPoints[0].dy);
        for (int i = 1; i < currentPathPoints.length; i++) {
            path.lineTo(currentPathPoints[i].dx, currentPathPoints[i].dy);
        }
        occupiedPaint.canvas.drawPath(path, Paint()
          ..color = Colors.yellow.withOpacity(0.5) 
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
    }
  }
}


// ========================================================
// 6. PROCEDURAL LEVEL GENERATOR (THE CONTENT ENGINE)
// ========================================================
class ProceduralGenerator {
    static LevelDefinition generateLevelData({required int difficulty}) {
        final Random random = Random(difficulty);
        final double sizeX = 1024;
        final double sizeY = 768;

        Color bg;
        List<Offset> wells;
        int numWells;

        if (difficulty < 2) {
            bg = const Color(0xFF0A0A2A); 
            wells = [
                Offset(random.nextDouble() * sizeX * 0.4 + 50, random.nextDouble() * sizeY * 0.4 + 50),
                Offset(random.nextDouble() * sizeX * 0.3 + sizeX * 0.5, random.nextDouble() * sizeY * 0.3 + 100),
                Offset(random.nextDouble() * sizeX * 0.2 + sizeX * 0.7, random.nextDouble() * sizeY * 0.1 + 50)
            ];
            numWells = 3;

        } else if (difficulty < 4) { 
            bg = const Color(0xFF1A0A3A);
            wells = [
                Offset(random.nextDouble() * sizeX * 0.3 + 50, random.nextDouble() * sizeY * 0.4 + 50),
                Offset(random.nextDouble() * sizeX * 0.4 + sizeX * 0.4, random.nextDouble() * sizeY * 0.2 + 100),
                Offset(random.nextDouble() * sizeX * 0.3 + sizeX * 0.6, random.nextDouble() * sizeY * 0.4 + 50)
            ];
            numWells = 3;

        } else { 
            bg = const Color(0xFF1A0A1F);
            wells = [
                Offset(random.nextDouble() * sizeX * 0.2 + 50, random.nextDouble() * sizeY * 0.3 + 50),
                Offset(random.nextDouble() * sizeX * 0.4 + sizeX * 0.4, random.nextDouble() * sizeY * 0.2 + 100),
                Offset(random.nextDouble() * sizeX * 0.2 + sizeX * 0.6, random.nextDouble() * sizeY * 0.3 + 50),
                Offset(random.nextDouble() * sizeX * 0.1 + 100, random.nextDouble() * sizeY * 0.4 + 50)
            ];
            numWells = 4;
        }

        // Goal Markers
        List<{offset: Offset, value: int}> markers = [];
        int numGoals = difficulty < 3 ? 3 : (difficulty < 5 ? 4 : 6); 

        for(int i=0; i<numGoals; i++) {
            Offset target = Offset(
                random.nextDouble() * (sizeX * 0.8) + sizeX * 0.1,
                random.nextDouble() * (sizeY * 0.8) + sizeY * 0.1
            );
             markers.add({'offset': target, 'value': 5 + difficulty * 2}); 
        }

        // Repulsion Zones
        List<Rect>? zones = null;
        if (difficulty >= 2) {
             List<Rect> zoneList = [];
             int numZones = difficulty < 4 ? 1 : (difficulty < 5 ? 2 : 3);

             for(int i=0; i < numZones; i++) {
                 Offset start = Offset(
                    random.nextDouble() * (sizeX * 0.3) + random.nextFloat() * (sizeX*0.2), 
                    random.nextDouble() * (sizeY * 0.25) + random.nextFloat() * (sizeY*0.1)  
                 );
                Size s = Size(
                    random.nextDouble() * (sizeX * 0.3) + sizeX * 0.1, 
                    random.nextDouble() * (sizeY * 0.25) + sizeY * 0.05 
                 );
                zoneList.add(Rect(start, s));
             }
             zones = zoneList;
        }

        return LevelDefinition(
            levelId: difficulty,
            gravityWells: wells,
            goalMarkersData: markers,
            backgroundOverride: bg,
            repulsionZones: zones
        );
    }
}


//========================================================
// UI/UX LAYER WIDGETS (The final integration layer)
//========================================================

/// GameWidget Wrapper: Contains the entire game engine and manages state.
class GameGameWrapper extends StatefulWidget {
  const GameGameWrapper({super.key});

  @override
  State<GameGameWrapper> createState() => _GameGameWrapperState();
}

class _GameGameWrapperState extends State<GameGameWrapper> {
  final GravitySwirlGame game = GravitySwirlGame(); // Keep the instance here
  int currentLevelId = 1;
  double score = 0.0;

  @override
  void initState() {
    super.initState();
    // Initial setup: We must run the level loading logic to sync the widget state
    _loadAndDisplayLevel(1);
  }

  void _loadAndDisplayLevel(int levelId) {
    // In a real application, this would trigger data retrieval or network call.
    final LevelDefinition nextLevelData = ProceduralGenerator.generateLevelData(difficulty: levelId);
    
    setState(() {
      currentLevelId = levelId;
      score = 0.0; // Reset score on level change
      // Note: We are calling the loadLevel function directly, which modifies the internal game state.
      game.loadLevel(nextLevelData); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Flame Game must occupy all available screen space
          FlameGameWidget(game: game),
          
          // Overlay HUD (Heads-Up Display) - This sits ON TOP of the game canvas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.black54, // Semi-transparent overlay for readability
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level $currentLevelId", style: const TextStyle(fontSize: 28, color: Colors.white)),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      Text("Score: ${score.toInt()}", style: const TextStyle(fontSize: 28, color: Colors.yellowAccent)),
                      const Text("Particles: Active", style: TextStyle(color: Colors.white70)),
                    ],
                  )
                ],
              ),
            ),
          ),

           // Optional Game Over/Win Screen Overlay (Would trigger on game state change)
        ],
      ),
    );
  }
}


/// The root widget that handles navigation and overall app presentation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gravity Swirl"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Welcome to Gravity Swirl!", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () {
                // Navigate to the wrapper that contains the game logic and state.
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                  return const GameGameWrapper();
                }));
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), minimumSize: Size(300, 60)),
              child: const Text("START GAME (Start Level 1)", style: TextStyle(fontSize: 20)),
            ),
             const SizedBox(height: 40),

            OutlinedButton(
              onPressed: () {
                // Future feature: Implement Scoreboard/Settings here
              },
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), minimumSize: Size(300, 60)),
              child: const Text("HIGH SCORES / SETTINGS", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

//========================================================
// MAIN APPLICATION ENTRY POINT (THE FINAL DEPLOYMENT)
//========================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MaterialApp(home: HomeScreen())); 
}
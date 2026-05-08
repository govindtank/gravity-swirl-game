import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme_manager.dart';
import '../../engine/game_engine.dart';
import '../../models/game_objects.dart';

// ========================================================
// GAME PAINTER - Main Game Renderer
// ========================================================

class GamePainter extends CustomPainter {
  final GameState state;
  final GameTheme theme;
  final double animationTime;

  GamePainter({
    required this.state,
    required this.theme,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Apply screen shake
    if (state.shakeIntensity > 0) {
      final random = Random();
      canvas.translate(
        (random.nextDouble() - 0.5) * state.shakeIntensity,
        (random.nextDouble() - 0.5) * state.shakeIntensity,
      );
    }

    // Draw background
    _drawBackground(canvas, size);

    // Draw animated background stars
    _drawStars(canvas, size);

    // Draw repulsion zones
    _drawRepulsionZones(canvas);

    // Draw magnetic fields
    _drawMagneticFields(canvas);

    // Draw path
    _drawPath(canvas);

    // Draw gravity wells
    _drawGravityWells(canvas);

    // Draw orbiting objects
    _drawOrbitingObjects(canvas);

    // Draw pulsing objects
    _drawPulsingObjects(canvas);

    // Draw teleporters
    _drawTeleporters(canvas);

    // Draw splitters
    _drawSplitters(canvas);

    // Draw black holes
    _drawBlackHoles(canvas);

    // Draw powerups
    _drawPowerups(canvas);

    // Draw goals
    _drawGoals(canvas);

    // Draw particles with trails
    _drawParticles(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = state.backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Gradient overlay
    final gradient = ui.Gradient.radial(
      Offset(size.width / 2, size.height / 2),
      size.width,
      [
        Colors.transparent,
        theme.background.withOpacity(0.3),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = gradient,
    );
  }

  void _drawStars(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent stars
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle =
          0.3 + 0.7 * sin(animationTime * 2 + i * 0.5).abs();
      starPaint.color = Colors.white.withOpacity(twinkle * 0.5);
      canvas.drawCircle(Offset(x, y), 1 + random.nextDouble(), starPaint);
    }
  }

  void _drawRepulsionZones(Canvas canvas) {
    if (state.levelData == null) return;

    for (final zone in state.levelData!.repulsionZones) {
      final rect =
          Rect.fromLTWH(zone.position.dx, zone.position.dy, zone.width, zone.height);

      // Animated glow effect
      final glowOpacity = 0.15 + 0.05 * sin(animationTime * 3);

      // Fill
      canvas.drawRect(
        rect,
        Paint()..color = theme.hazardColor.withOpacity(glowOpacity),
      );

      // Border with pulse
      final borderOpacity = 0.4 + 0.2 * sin(animationTime * 2);
      canvas.drawRect(
        rect,
        Paint()
          ..color = theme.hazardColor.withOpacity(borderOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Warning stripes
      _drawWarningStripes(canvas, rect);
    }
  }

  void _drawWarningStripes(Canvas canvas, Rect rect) {
    canvas.save();
    canvas.clipRect(rect);

    final stripePaint = Paint()
      ..color = theme.hazardColor.withOpacity(0.1)
      ..strokeWidth = 3;

    const stripeSpacing = 15.0;
    final offset = (animationTime * 20) % stripeSpacing;

    for (double i = -rect.height; i < rect.width + rect.height; i += stripeSpacing) {
      canvas.drawLine(
        Offset(rect.left + i + offset, rect.top),
        Offset(rect.left + i + offset - rect.height, rect.bottom),
        stripePaint,
      );
    }

    canvas.restore();
  }

  void _drawMagneticFields(Canvas canvas) {
    if (state.levelData == null) return;

    for (final field in state.levelData!.magneticFields) {
      final rect =
          Rect.fromLTWH(field.position.dx, field.position.dy, field.width, field.height);

      // Field color based on direction
      const fieldColor = Color(0xFF00BFFF);

      // Fill with gradient
      canvas.drawRect(
        rect,
        Paint()..color = fieldColor.withOpacity(0.15),
      );

      // Direction arrows
      _drawFieldArrows(canvas, rect, field.direction, fieldColor);

      // Border
      canvas.drawRect(
        rect,
        Paint()
          ..color = fieldColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawFieldArrows(Canvas canvas, Rect rect, Offset direction, Color color) {
    final arrowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const spacing = 30.0;
    const arrowSize = 10.0;
    final flowOffset = (animationTime * 40) % spacing;

    for (double y = rect.top + spacing / 2; y < rect.bottom; y += spacing) {
      for (double x = rect.left + spacing / 2; x < rect.right; x += spacing) {
        final pos = Offset(x, y);
        final flowPos = pos + direction * flowOffset;

        if (rect.contains(flowPos)) {
          final endPos = flowPos + direction * arrowSize;
          canvas.drawLine(flowPos, endPos, arrowPaint);

          // Arrowhead
          final angle = atan2(direction.dy, direction.dx);
          const headSize = 4.0;
          canvas.drawLine(
            endPos,
            endPos +
                Offset(
                  cos(angle + 2.5) * headSize,
                  sin(angle + 2.5) * headSize,
                ),
            arrowPaint,
          );
          canvas.drawLine(
            endPos,
            endPos +
                Offset(
                  cos(angle - 2.5) * headSize,
                  sin(angle - 2.5) * headSize,
                ),
            arrowPaint,
          );
        }
      }
    }
  }

  void _drawPath(Canvas canvas) {
    if (state.pathPoints.length < 2) return;

    final path = Path();
    path.moveTo(state.pathPoints.first.dx, state.pathPoints.first.dy);

    for (int i = 1; i < state.pathPoints.length; i++) {
      path.lineTo(state.pathPoints[i].dx, state.pathPoints[i].dy);
    }

    // Glow effect
    canvas.drawPath(
      path,
      Paint()
        ..color = theme.accent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Core line
    canvas.drawPath(
      path,
      Paint()
        ..color = theme.accent.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawGravityWells(Canvas canvas) {
    if (state.levelData == null) return;

    for (final well in state.levelData!.gravityWells) {
      final pulseScale = 1 + 0.15 * sin(well.animationPhase);

      // Outer glow rings
      for (int i = 3; i >= 1; i--) {
        final ringRadius = well.radius * (1.5 + i * 0.3) * pulseScale;
        final ringOpacity = 0.1 / i;
        canvas.drawCircle(
          well.position,
          ringRadius,
          Paint()
            ..color = theme.hazardColor.withOpacity(ringOpacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }

      // Core glow
      canvas.drawCircle(
        well.position,
        well.radius * 1.5 * pulseScale,
        Paint()
          ..color = theme.hazardColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Core
      final gradient = ui.Gradient.radial(
        well.position,
        well.radius * pulseScale,
        [
          theme.hazardColor,
          theme.hazardColor.withOpacity(0.5),
        ],
      );
      canvas.drawCircle(
        well.position,
        well.radius * pulseScale,
        Paint()..shader = gradient,
      );

      // Inner bright spot
      canvas.drawCircle(
        well.position + const Offset(-3, -3),
        well.radius * 0.3,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    }
  }

  void _drawOrbitingObjects(Canvas canvas) {
    if (state.levelData == null) return;

    for (final obj in state.levelData!.orbitingObjects) {
      // Orbit path
      canvas.drawCircle(
        obj.center,
        obj.orbitRadius,
        Paint()
          ..color = theme.secondary.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Trail
      const trailLength = 8;
      for (int i = 0; i < trailLength; i++) {
        final trailAngle = obj.currentAngle - i * 0.15;
        final trailPos = obj.center +
            Offset(cos(trailAngle) * obj.orbitRadius, sin(trailAngle) * obj.orbitRadius);
        final opacity = (1 - i / trailLength) * 0.4;
        canvas.drawCircle(
          trailPos,
          obj.radius * (1 - i / trailLength * 0.5),
          Paint()..color = theme.secondary.withOpacity(opacity),
        );
      }

      // Glow
      canvas.drawCircle(
        obj.position,
        obj.radius * 1.8,
        Paint()
          ..color = theme.secondary.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Core
      final gradient = ui.Gradient.radial(
        obj.position,
        obj.radius,
        [
          theme.secondary,
          theme.secondary.withOpacity(0.6),
        ],
      );
      canvas.drawCircle(
        obj.position,
        obj.radius,
        Paint()..shader = gradient,
      );

      // Ring effect
      canvas.drawCircle(
        obj.position,
        obj.radius + 3,
        Paint()
          ..color = theme.secondary.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawPulsingObjects(Canvas canvas) {
    if (state.levelData == null) return;

    for (final obj in state.levelData!.pulsingObjects) {
      final pulseScale = 0.7 + 0.3 * sin(obj.animationPhase);
      final strengthNorm =
          (obj.currentStrength - obj.baseStrength + obj.pulseAmplitude) /
              (obj.pulseAmplitude * 2);

      // Outer rings
      for (int i = 3; i >= 1; i--) {
        final ringRadius = obj.radius * (1.3 + i * 0.2) * pulseScale;
        canvas.drawCircle(
          obj.position,
          ringRadius,
          Paint()
            ..color = theme.primary.withOpacity(0.1 * strengthNorm)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Glow
      canvas.drawCircle(
        obj.position,
        obj.radius * 1.5 * pulseScale,
        Paint()
          ..color = theme.primary.withOpacity(0.4 * strengthNorm)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Core
      final gradient = ui.Gradient.radial(
        obj.position,
        obj.radius * pulseScale,
        [
          Color.lerp(theme.primary, Colors.white, 0.3 * strengthNorm)!,
          theme.primary,
        ],
      );
      canvas.drawCircle(
        obj.position,
        obj.radius * pulseScale,
        Paint()..shader = gradient,
      );
    }
  }

  void _drawTeleporters(Canvas canvas) {
    if (state.levelData == null) return;

    for (final teleporter in state.levelData!.teleporters) {
      final rotation = teleporter.animationPhase;
      final isReady = teleporter.canTeleport();

      // Portal color
      final portalColor =
          isReady ? const Color(0xFF9333EA) : const Color(0xFF6B21A8);

      // Swirl effect
      for (int i = 0; i < 3; i++) {
        final swirlAngle = rotation + i * (2 * pi / 3);
        final swirlRadius = teleporter.radius * (0.6 + 0.2 * sin(rotation * 2 + i));

        canvas.drawArc(
          Rect.fromCircle(center: teleporter.position, radius: swirlRadius),
          swirlAngle,
          pi / 2,
          false,
          Paint()
            ..color = portalColor.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }

      // Outer glow
      canvas.drawCircle(
        teleporter.position,
        teleporter.radius * 1.3,
        Paint()
          ..color = portalColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Core
      final gradient = ui.Gradient.radial(
        teleporter.position,
        teleporter.radius,
        [
          Colors.black,
          portalColor,
          portalColor.withOpacity(0.3),
        ],
        [0.0, 0.6, 1.0],
      );
      canvas.drawCircle(
        teleporter.position,
        teleporter.radius,
        Paint()..shader = gradient,
      );

      // Inner event horizon
      canvas.drawCircle(
        teleporter.position,
        teleporter.radius * 0.4,
        Paint()..color = Colors.black,
      );

      // Link indicator
      if (teleporter.linkedTeleporter != null && isReady) {
        _drawTeleporterLink(canvas, teleporter.position, teleporter.linkedTeleporter!.position);
      }
    }
  }

  void _drawTeleporterLink(Canvas canvas, Offset from, Offset to) {
    const dashLength = 10.0;
    const gapLength = 8.0;
    final direction = to - from;
    final distance = direction.distance;
    final unitDir = direction / distance;

    final offset = (animationTime * 30) % (dashLength + gapLength);

    final linkPaint = Paint()
      ..color = const Color(0xFF9333EA).withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double pos = offset;
    while (pos < distance) {
      final start = from + unitDir * pos;
      final end = from + unitDir * min(pos + dashLength, distance);
      canvas.drawLine(start, end, linkPaint);
      pos += dashLength + gapLength;
    }
  }

  void _drawSplitters(Canvas canvas) {
    if (state.levelData == null) return;

    for (final splitter in state.levelData!.splitters) {
      final isReady = splitter.canSplit();
      final crystalColor =
          isReady ? const Color(0xFF22C55E) : const Color(0xFF166534);

      // Crystal shape
      final path = Path();
      const sides = 6;
      for (int i = 0; i < sides; i++) {
        final angle = splitter.animationPhase + i * (2 * pi / sides);
        final radius = splitter.radius * (0.9 + 0.1 * (i % 2));
        final x = splitter.position.dx + cos(angle) * radius;
        final y = splitter.position.dy + sin(angle) * radius;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      // Glow
      canvas.drawPath(
        path,
        Paint()
          ..color = crystalColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Fill
      canvas.drawPath(
        path,
        Paint()..color = crystalColor,
      );

      // Highlight
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Split count indicator
      if (splitter.splitCount > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${splitter.maxSplits - splitter.splitCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          splitter.position - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  void _drawBlackHoles(Canvas canvas) {
    if (state.levelData == null) return;

    for (final hole in state.levelData!.blackHoles) {
      // Accretion disk
      for (int i = 5; i >= 1; i--) {
        final diskRadius = hole.radius * (0.8 + i * 0.2);
        final rotation = hole.animationPhase * (1 + i * 0.1);

        canvas.drawArc(
          Rect.fromCircle(center: hole.position, radius: diskRadius),
          rotation,
          pi * 1.5,
          false,
          Paint()
            ..color = Color.lerp(
              const Color(0xFFFF6B6B),
              const Color(0xFFFFD93D),
              i / 5,
            )!
                .withOpacity(0.3 / i)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }

      // Distortion effect
      final gradient = ui.Gradient.radial(
        hole.position,
        hole.radius,
        [
          Colors.black,
          const Color(0xFF1A0A1F),
          Colors.transparent,
        ],
        [0.0, 0.7, 1.0],
      );
      canvas.drawCircle(
        hole.position,
        hole.radius,
        Paint()..shader = gradient,
      );

      // Event horizon
      canvas.drawCircle(
        hole.position,
        hole.eventHorizonRadius,
        Paint()..color = Colors.black,
      );

      // Singularity glow
      canvas.drawCircle(
        hole.position,
        3,
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  void _drawPowerups(Canvas canvas) {
    for (final powerup in state.powerups) {
      if (powerup.collected) continue;

      final color = Powerup.getColor(powerup.type);
      final bobOffset = sin(powerup.animationPhase) * 5;

      final pos = powerup.position + Offset(0, bobOffset);

      // Outer glow
      canvas.drawCircle(
        pos,
        30,
        Paint()
          ..color = color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Rotating ring
      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: 25),
        powerup.animationPhase,
        pi,
        false,
        Paint()
          ..color = color.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Core
      final gradient = ui.Gradient.radial(
        pos,
        20,
        [
          Colors.white,
          color,
        ],
      );
      canvas.drawCircle(
        pos,
        18,
        Paint()..shader = gradient,
      );

      // Icon
      _drawPowerupIcon(canvas, pos, powerup.type, color);
    }
  }

  void _drawPowerupIcon(Canvas canvas, Offset pos, PowerupType type, Color color) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case PowerupType.shield:
        // Shield shape
        final path = Path();
        path.moveTo(pos.dx, pos.dy - 8);
        path.lineTo(pos.dx + 8, pos.dy - 4);
        path.lineTo(pos.dx + 8, pos.dy + 4);
        path.lineTo(pos.dx, pos.dy + 10);
        path.lineTo(pos.dx - 8, pos.dy + 4);
        path.lineTo(pos.dx - 8, pos.dy - 4);
        path.close();
        canvas.drawPath(path, iconPaint);
        break;

      case PowerupType.multiplier:
        // 2x
        final textPainter = TextPainter(
          text: const TextSpan(
            text: '2x',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
        break;

      case PowerupType.slowMotion:
        // Clock
        canvas.drawCircle(pos, 7, iconPaint);
        canvas.drawLine(pos, pos + const Offset(0, -5), iconPaint);
        canvas.drawLine(pos, pos + const Offset(4, 0), iconPaint);
        break;

      case PowerupType.magnet:
        // Magnet U shape
        final path = Path();
        path.moveTo(pos.dx - 6, pos.dy - 6);
        path.lineTo(pos.dx - 6, pos.dy + 4);
        path.quadraticBezierTo(pos.dx - 6, pos.dy + 8, pos.dx, pos.dy + 8);
        path.quadraticBezierTo(pos.dx + 6, pos.dy + 8, pos.dx + 6, pos.dy + 4);
        path.lineTo(pos.dx + 6, pos.dy - 6);
        canvas.drawPath(path, iconPaint);
        break;

      case PowerupType.particleBurst:
        // Explosion
        for (int i = 0; i < 6; i++) {
          final angle = i * pi / 3;
          canvas.drawLine(
            pos,
            pos + Offset(cos(angle) * 7, sin(angle) * 7),
            iconPaint,
          );
        }
        break;
    }
  }

  void _drawGoals(Canvas canvas) {
    for (final goal in state.goals) {
      if (goal.collected) continue;

      final pulseScale = 1 + 0.1 * sin(goal.pulsePhase);

      // Outer glow
      canvas.drawCircle(
        goal.position,
        35 * pulseScale,
        Paint()
          ..color = theme.goalColor.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );

      // Middle ring
      canvas.drawCircle(
        goal.position,
        30 * pulseScale,
        Paint()
          ..color = theme.goalColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Core
      final gradient = ui.Gradient.radial(
        goal.position,
        25 * pulseScale,
        [
          theme.goalColor,
          theme.goalColor.withOpacity(0.6),
        ],
      );
      canvas.drawCircle(
        goal.position,
        25 * pulseScale,
        Paint()..shader = gradient,
      );

      // Star sparkle effect
      final starAngle = animationTime * 2;
      for (int i = 0; i < 4; i++) {
        final angle = starAngle + i * pi / 2;
        final length = 8 + 3 * sin(animationTime * 4 + i);
        canvas.drawLine(
          goal.position,
          goal.position + Offset(cos(angle) * length, sin(angle) * length),
          Paint()
            ..color = Colors.white.withOpacity(0.6)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      }

      // Center bright spot
      canvas.drawCircle(
        goal.position,
        8,
        Paint()..color = Colors.white.withOpacity(0.5),
      );
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final particle in state.particles) {
      // Draw trail
      if (particle.trail.length > 1) {
        for (int i = 0; i < particle.trail.length - 1; i++) {
          final opacity = (i / particle.trail.length) * GameConstants.trailOpacity;
          final width = 1 + (i / particle.trail.length) * particle.radius;
          canvas.drawLine(
            particle.trail[i],
            particle.trail[i + 1],
            Paint()
              ..color = theme.particleColor.withOpacity(opacity)
              ..strokeWidth = width
              ..strokeCap = StrokeCap.round,
          );
        }
      }

      // Shield effect
      if (particle.isShielded) {
        canvas.drawCircle(
          particle.position,
          particle.radius + 4,
          Paint()
            ..color = const Color(0xFF64FFDA).withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Particle glow
      canvas.drawCircle(
        particle.position,
        particle.radius * 2,
        Paint()
          ..color = theme.particleColor.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Particle core
      canvas.drawCircle(
        particle.position,
        particle.radius,
        Paint()..color = theme.particleColor.withOpacity(0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

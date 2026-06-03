import 'dart:math';
import 'package:flutter/material.dart';
import 'game_engine.dart';

class CosmicGamePainter extends CustomPainter {
  final CosmicGameState state;
  final double animTime;

  CosmicGamePainter(this.state, this.animTime);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawAmbientParticles(canvas);
    _drawGravityWells(canvas);
    _drawBlackHoles(canvas);
    _drawStars(canvas);
    _drawPortal(canvas);
    _drawShip(canvas);
    _drawShipTrail(canvas);
    _drawEffectParticles(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final def = state.currentLevel < cosmicLevels.length
        ? cosmicLevels[state.currentLevel]
        : cosmicLevels[0];

    // Dark gradient background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.3),
        radius: 1.5,
        colors: [
          def.accentColor.withOpacity(0.06),
          def.bgColor,
          const Color(0xFF050510),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Subtle starfield
    final starPaint = Paint()..color = Colors.white.withOpacity(0.15);
    for (int i = 0; i < 60; i++) {
      final px = (i * 137.5 + animTime * 2) % size.width;
      final py = (i * 97.3 + sin(i + animTime * 0.5) * 20) % size.height;
      final sr = 0.5 + (i % 3) * 0.5;
      canvas.drawCircle(Offset(px, py), sr, starPaint);
    }
  }

  void _drawAmbientParticles(Canvas canvas) {
    for (final p in state.particles) {
      final alpha = (1.0 - p.progress) * 0.3;
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * (1.0 - p.progress * 0.5),
        Paint()..color = Colors.white.withOpacity(alpha),
      );
    }
  }

  void _drawGravityWells(Canvas canvas) {
    for (final well in state.wells) {
      final pos = well.position;

      // Outer glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            well.glowColor.withOpacity(0.3),
            well.glowColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: well.visualRadius * 2.5));

      canvas.drawCircle(pos, well.visualRadius * 2.5, glowPaint);

      // Influence ring
      final ringPaint = Paint()
        ..color = well.glowColor.withOpacity(0.1 + sin(animTime * 0.5) * 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(pos, well.visualRadius * 2.0, ringPaint);

      // Body with gradient
      final bodyPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            well.glowColor.withOpacity(0.9),
            well.color,
            well.color.withOpacity(0.3),
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: well.visualRadius));

      canvas.drawCircle(pos, well.visualRadius, bodyPaint);

      // Core
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            well.glowColor.withOpacity(0.5),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: well.visualRadius * 0.4));

      canvas.drawCircle(pos, well.visualRadius * 0.4, corePaint);
    }
  }

  void _drawBlackHoles(Canvas canvas) {
    for (final hole in state.blackHoles) {
      final pos = hole.position;

      // Outer purple glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF9C27B0).withOpacity(0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: hole.radius * 3));
      canvas.drawCircle(pos, hole.radius * 3, glowPaint);

      // Event horizon - dark center
      final horizonPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1A0A2E).withOpacity(0.9),
            const Color(0xFF4A148C).withOpacity(0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: hole.radius));
      canvas.drawCircle(pos, hole.radius, horizonPaint);

      // Accretion disk ring
      final diskPaint = Paint()
        ..shader = SweepGradient(
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.4),
            const Color(0xFF9C27B0).withOpacity(0.4),
            const Color(0xFFFF4081).withOpacity(0.4),
            const Color(0xFFFF6B35).withOpacity(0.4),
          ],
          startAngle: animTime * 0.5,
          endAngle: animTime * 0.5 + 2 * pi,
        ).createShader(Rect.fromCircle(center: pos, radius: hole.radius * 1.5));

      final diskPath = Path()
        ..addOval(Rect.fromCircle(center: pos, radius: hole.radius * 1.3))
        ..addOval(Rect.fromCircle(center: pos, radius: hole.radius * 0.8));
      canvas.drawPath(diskPath, diskPaint..style = PaintingStyle.stroke..strokeWidth = 2);

      // Warning label
      final tp = TextPainter(
        text: TextSpan(
          text: '⚠',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFFFF1744).withOpacity(0.6 + sin(animTime * 2) * 0.3),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  void _drawStars(Canvas canvas) {
    for (final star in state.stars) {
      if (star.collected) {
        // Collect sparkle animation
        final elapsed = animTime - star.animTime;
        if (elapsed < 0.5) {
          final fade = 1.0 - elapsed / 0.5;
          canvas.drawCircle(
            star.position,
            15 * (1 + elapsed * 2),
            Paint()..color = const Color(0xFFFFD700).withOpacity(fade * 0.5),
          );
        }
        continue;
      }

      final pos = star.position;
      final pulse = 1.0 + sin(animTime * 2 + star.position.dx * 0.1) * 0.15;
      final sparkle = sin(animTime * 3 + star.position.dy * 0.1);

      // Glow
      canvas.drawCircle(
        pos,
        12 * pulse,
        Paint()..color = const Color(0xFFFFD700).withOpacity(0.15),
      );

      // Star body - diamond shape
      final size = 6 * pulse;
      final starPath = Path();
      starPath.moveTo(pos.dx, pos.dy - size);
      starPath.lineTo(pos.dx + size * 0.5, pos.dy);
      starPath.lineTo(pos.dx, pos.dy + size);
      starPath.lineTo(pos.dx - size * 0.5, pos.dy);
      starPath.close();

      canvas.drawPath(
        starPath,
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFFFFF176),
              const Color(0xFFFFD700),
              const Color(0xFFFF8F00),
            ],
          ).createShader(Rect.fromCenter(center: pos, width: size, height: size * 2)),
      );

      // Sparkle cross
      if (sparkle > 0.5) {
        final crossPaint = Paint()
          ..color = Colors.white.withOpacity((sparkle - 0.5) * 0.8)
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(pos.dx - size * 1.5, pos.dy),
          Offset(pos.dx + size * 1.5, pos.dy),
          crossPaint,
        );
        canvas.drawLine(
          Offset(pos.dx, pos.dy - size * 1.5),
          Offset(pos.dx, pos.dy + size * 1.5),
          crossPaint,
        );
      }
    }
  }

  void _drawPortal(Canvas canvas) {
    if (state.portal == null) return;
    final portal = state.portal!;
    final pos = portal.position;
    final r = portal.radius;

    // Background glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 4));
    canvas.drawCircle(pos, r * 4, glowPaint);

    // Spiral effect
    final spiralPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.6),
          const Color(0xFF7C4DFF).withOpacity(0.6),
          const Color(0xFF00E5FF).withOpacity(0.6),
        ],
        startAngle: animTime * 1.5,
        endAngle: animTime * 1.5 + 2 * pi,
      ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, spiralPaint);

    // Inner portal white
    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          const Color(0xFF00BCD4).withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 0.6));
    canvas.drawCircle(pos, r * 0.6, innerPaint);

    if (portal.active) {
      // Active pulse ring
      final pulseR = r * (1.2 + sin(animTime * 3) * 0.15);
      canvas.drawCircle(
        pos,
        pulseR,
        Paint()
          ..color = const Color(0xFF76FF03).withOpacity(0.3 + sin(animTime * 3) * 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // "GO" text
      final tp = TextPainter(
        text: TextSpan(
          text: 'EXIT',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    } else if (state.starsCollected < state.totalStarsInLevel) {
      // Locked indicator
      final tp = TextPainter(
        text: TextSpan(
          text: '${state.starsCollected}/${state.totalStarsInLevel}',
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  void _drawShipTrail(Canvas canvas) {
    if (!state.ship.alive || state.ship.trail.length < 2) return;

    final trail = state.ship.trail;
    for (int i = 1; i < trail.length; i++) {
      final t = i / trail.length;
      final alpha = t * 0.4;

      // Thrust glow effect
      final width = 2 + t * 3;
      final trailColor = Color.lerp(
        const Color(0xFF00E5FF),
        const Color(0xFF7C4DFF),
        1 - t,
      )!.withOpacity(alpha);

      canvas.drawCircle(trail[i], width * 1.5, Paint()..color = trailColor.withOpacity(alpha * 0.3));
      canvas.drawCircle(trail[i], width, Paint()..color = trailColor);
    }
  }

  void _drawShip(Canvas canvas) {
    if (!state.ship.alive) return;
    final pos = state.ship.position;
    final velocity = state.ship.velocity;
    final speed = velocity.distance;

    // Ship glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: 25));
    canvas.drawCircle(pos, 25, glowPaint);

    // Ship body
    final r = 7 + speed / state.maxSpeed * 2;
    final shipPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFFB2EBF2),
          Color(0xFF00BCD4),
          Color(0xFF006064),
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r));

    canvas.drawCircle(pos, r, shipPaint);

    // Direction indicator (if moving)
    if (speed > 10) {
      final angle = atan2(velocity.dy, velocity.dx);
      final tipX = pos.dx + cos(angle) * r * 0.3;
      final tipY = pos.dy + sin(angle) * r * 0.3;
      canvas.drawCircle(
        Offset(tipX, tipY),
        r * 0.4,
        Paint()..color = Colors.white.withOpacity(0.6),
      );
    }

    // Thrust indicator when dragging
    if (state.dragging) {
      final thrustDir = atan2(
        (state.touchY ?? pos.dy) - pos.dy,
        (state.touchX ?? pos.dx) - pos.dx,
      );
      for (int i = 0; i < 3; i++) {
        final offset = (i - 1) * 4;
        final perpAngle = thrustDir + pi / 2;
        final baseX = pos.dx + cos(perpAngle) * offset - cos(thrustDir) * r;
        final baseY = pos.dy + sin(perpAngle) * offset - sin(thrustDir) * r;
        final len = 15 + sin(animTime * 8 + i) * 5;
        canvas.drawLine(
          Offset(baseX, baseY),
          Offset(
            baseX - cos(thrustDir) * len,
            baseY - sin(thrustDir) * len,
          ),
          Paint()
            ..color = const Color(0xFFFF6B35).withOpacity(0.6 + sin(animTime * 6 + i) * 0.2)
            ..strokeWidth = 2.5 - i * 0.5,
        );
      }
    }
  }

  void _drawEffectParticles(Canvas canvas) {
    for (final p in state.particles) {
      if (p.lifetime < 0.01) continue; // Skip ambient particles drawn above
      final alpha = (1.0 - p.progress);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * (0.5 + 0.5 * (1.0 - p.progress)),
        Paint()..color = p.color.withOpacity(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CosmicGamePainter oldDelegate) => true;
}

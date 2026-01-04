import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Confetti celebration animation overlay
///
/// Features:
/// - Particle-based confetti system
/// - Physics-based falling animation
/// - Multiple colors and shapes
/// - Performance optimized
class ConfettiAnimationWidget extends StatefulWidget {
  final bool isPlaying;

  const ConfettiAnimationWidget({super.key, required this.isPlaying});

  @override
  State<ConfettiAnimationWidget> createState() =>
      _ConfettiAnimationWidgetState();
}

class _ConfettiAnimationWidgetState extends State<ConfettiAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.isPlaying) {
      _initializeParticles();
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _initializeParticles();
      _animationController.forward(from: 0);
    }
  }

  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(
        ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.1,
          velocityX: (_random.nextDouble() - 0.5) * 0.5,
          velocityY: _random.nextDouble() * 0.5 + 0.5,
          color: _getRandomColor(),
          size: _random.nextDouble() * 8 + 4,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFF7B68EE),
      const Color(0xFFE67E22),
      const Color(0xFF5CB85C),
      const Color(0xFFF0AD4E),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _animationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      particle.y += particle.velocityY * progress * 0.02;
      particle.x += particle.velocityX * progress * 0.02;
      particle.rotation += particle.rotationSpeed;

      // Skip if particle is out of bounds
      if (particle.y > 1.2) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      final center = Offset(particle.x * size.width, particle.y * size.height);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation);

      // Draw confetti piece (rectangle)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 1.5,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

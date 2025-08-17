import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/game_strings.dart';
import '../core/vibration_service.dart';
import 'home_screen.dart';

/// Victory screen shown when player completes the game
class VictoryScreen extends StatefulWidget {
  final int finalScore;
  final int finalCombo;

  const VictoryScreen({
    super.key,
    required this.finalScore,
    required this.finalCombo,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _scoreController;
  late AnimationController _particleController;
  late Animation<double> _titleAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _particleAnimation;

  bool _showContent = false;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Initialize vibration for victory
    VibrationService.patternVibration();

    // Initialize animations
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.bounceOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Start animations immediately
    _startAnimations();

    // Create victory particles
    _createParticles();
  }

  void _startAnimations() {
    // Show content immediately
    setState(() => _showContent = true);

    // Start title animation
    _titleController.forward();

    // Start score animation after title
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) _scoreController.forward();
    });

    // Start particle animation after score
    Timer(const Duration(milliseconds: 1600), () {
      if (mounted) _particleController.forward();
    });
  }

  void _createParticles() {
    final random = Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(
        _Particle(
          x: random.nextDouble() * 400,
          y: random.nextDouble() * 800,
          vx: (random.nextDouble() - 0.5) * 200,
          vy: (random.nextDouble() - 0.5) * 200,
          color: [
            const Color(0xFF00D4FF), // Flutter blue
            const Color(0xFFB3E5FC), // Light blue
            const Color(0xFF81D4FA), // Lighter blue
            const Color(0xFF4FC3F7), // Material blue
            const Color(0xFF29B6F6), // Blue accent
            Colors.white,
            const Color(0xFFE1F5FE), // Very light blue
          ][random.nextInt(7)],
          size: random.nextDouble() * 8 + 4,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scoreController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Animated background
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A237E), // Deep Blue
                    Color(0xFF0D47A1), // Material Blue
                    Color(0xFF0277BD), // Light Blue
                    Color(0xFF01579B), // Dark Blue
                  ],
                ),
              ),
            ),

            // Geometric pattern overlay
            Positioned.fill(
              child: CustomPaint(painter: _FlutterPatternPainter()),
            ),

            // Victory particles
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    _particles,
                    _particleAnimation.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Main content - Optimized for smooth animations
            if (_showContent)
              SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Victory title
                      Center(
                        child: AnimatedBuilder(
                          animation: _titleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _titleAnimation.value.clamp(0.0, 2.0),
                              child: Transform.rotate(
                                angle: (1 - _titleAnimation.value) * 0.3,
                                child: Column(
                                  children: [
                                    // Flutter logo icon
                                    const Icon(
                                      Icons.flutter_dash,
                                      size: 64,
                                      color: Color(0xFF00D4FF), // Flutter blue
                                      shadows: [
                                        Shadow(
                                          color: Color(0xFF00D4FF),
                                          blurRadius: 15,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Victory text
                                    Text(
                                      GameStrings.victoryTitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(
                                          0xFF00D4FF,
                                        ), // Flutter blue
                                        letterSpacing: 2.0,
                                        shadows: [
                                          const Shadow(
                                            color: Colors.white,
                                            blurRadius: 8,
                                            offset: Offset(0, 0),
                                          ),
                                          const Shadow(
                                            color: Color(0xFF00D4FF),
                                            blurRadius: 20,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Victory message
                      Center(
                        child: AnimatedBuilder(
                          animation: _titleAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _titleAnimation.value.clamp(0.0, 1.0),
                              child: Text(
                                GameStrings.victoryMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Final score
                      Center(
                        child: AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scoreAnimation.value.clamp(0.0, 1.5),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00D4FF,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00D4FF,
                                    ).withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00D4FF,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      GameStrings.victoryFinalScoreLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${widget.finalScore}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF00D4FF),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    if (widget.finalCombo > 0) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        '${GameStrings.victoryMaxComboLabel}: ${widget.finalCombo}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFB3E5FC),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Action buttons
                      Center(
                        child: AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _scoreAnimation.value.clamp(0.0, 1.0),
                              child: SizedBox(
                                width: 220,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    VibrationService.lightVibration();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00D4FF),
                                    foregroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: const Color(
                                      0xFF00D4FF,
                                    ).withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    GameStrings.victoryBackToMenuButton,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Particle class for victory effects
class _Particle {
  double x, y, vx, vy;
  Color color;
  double size;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;

    // Bounce off edges
    if (x <= 0 || x >= 400) vx = -vx;
    if (y <= 0 || y >= 800) vy = -vy;
  }
}

/// Custom painter for victory particles
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(0.016); // 60 FPS

      final paint = Paint()
        ..color = particle.color.withValues(alpha: animationValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * animationValue,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Geometric pattern painter
class _FlutterPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Draw subtle Flutter-style geometric patterns
    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 40.0) % size.height;

      // Draw small circles in a grid pattern
      canvas.drawCircle(Offset(x, y), 8.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

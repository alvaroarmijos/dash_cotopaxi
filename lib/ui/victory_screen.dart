import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/game_strings.dart';
import '../core/score_service.dart';
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
  late Animation<double> _titleAnimation;
  late Animation<double> _scoreAnimation;

  bool _showContent = false;
  bool _isNewRecord = false;
  bool _isNewComboRecord = false;
  int _bestScore = 0;
  int _bestCombo = 0;

  @override
  void initState() {
    super.initState();

    // Initialize vibration for victory
    VibrationService.patternVibration();

    // Save score and check for new records
    _saveScoreAndCheckRecords();

    // Initialize animations
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.bounceOut),
    );

    // Start animations immediately
    _startAnimations();
  }

  /// Save the current score and check if it's a new record
  Future<void> _saveScoreAndCheckRecords() async {
    try {
      // Save the score
      final hasNewRecord = await ScoreService.instance.saveScore(
        widget.finalScore,
        widget.finalCombo,
      );

      // Check if this is a new best score or combo
      final isNewBestScore = await ScoreService.instance.isNewBestScore(
        widget.finalScore,
      );
      final isNewBestCombo = await ScoreService.instance.isNewBestCombo(
        widget.finalCombo,
      );

      // Get current best scores for display
      final bestScore = await ScoreService.instance.getBestScore();
      final bestCombo = await ScoreService.instance.getBestCombo();

      setState(() {
        _isNewRecord = isNewBestScore;
        _isNewComboRecord = isNewBestCombo;
        _bestScore = bestScore;
        _bestCombo = bestCombo;
      });

      // Special vibration for new records
      if (hasNewRecord) {
        VibrationService.patternVibration();
      }
    } catch (e) {
      // Handle error silently
      debugPrint('Error saving score: $e');
    }
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  /// Widget to display a best record item
  Widget _bestRecordItem(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB3E5FC),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
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

            // Main content - Optimized for smooth animations
            if (_showContent)
              SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
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
                                        color: Color(
                                          0xFF00D4FF,
                                        ), // Flutter blue
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
                                child: Column(
                                  children: [
                                    if (_isNewRecord || _isNewComboRecord) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.withValues(
                                              alpha: 0.5,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.emoji_events,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _isNewRecord && _isNewComboRecord
                                                  ? 'New Records!'
                                                  : _isNewRecord
                                                  ? GameStrings.newRecordMessage
                                                  : GameStrings
                                                        .newComboRecordMessage,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
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
                                  padding: const EdgeInsets.all(12),
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${widget.finalScore}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF00D4FF),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          if (_isNewRecord) ...[
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 32,
                                            ),
                                          ],
                                        ],
                                      ),

                                      // Show best scores
                                      if (_bestScore > 0 || _bestCombo > 0) ...[
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                GameStrings.bestRecordsLabel,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  _bestRecordItem(
                                                    GameStrings
                                                        .bestScoreRecordLabel,
                                                    _bestScore,
                                                  ),
                                                  _bestRecordItem(
                                                    GameStrings
                                                        .bestComboRecordLabel,
                                                    _bestCombo,
                                                  ),
                                                ],
                                              ),
                                            ],
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

                        const SizedBox(height: 18),

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
              ),
          ],
        ),
      ),
    );
  }
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

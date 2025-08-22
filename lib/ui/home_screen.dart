import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/game_strings.dart';
import '../core/score_service.dart';
import 'game_screen.dart';

/// Home screen with game title and play button
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int lastScore = 0;
  int bestScore = 0;
  int bestCombo = 0;
  int gamesPlayed = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// Load statistics from persistent storage
  Future<void> _loadStats() async {
    try {
      final stats = await ScoreService.instance.getAllStats();
      setState(() {
        lastScore = stats['lastScore'] ?? 0;
        bestScore = stats['bestScore'] ?? 0;
        bestCombo = stats['bestCombo'] ?? 0;
        gamesPlayed = stats['gamesPlayed'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      // If there's an error, just set loading to false
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          // Only Game Button B and Game Button Start can start the game
          if (event.logicalKey.keyLabel == 'Game Button B' ||
              event.logicalKey.keyLabel == 'Game Button Start') {
            _startGame(context);
          }
        }
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Animated background
              AnimatedContainer(
                duration: const Duration(seconds: 3),
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

              // Flutter logo pattern overlay
              Positioned.fill(
                child: CustomPaint(painter: _FlutterPatternPainter()),
              ),

              // Main content
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Flutter logo icon
                          const Icon(
                            Icons.flutter_dash,
                            size: 75,
                            color: Color(0xFF00D4FF), // Flutter blue
                            shadows: [
                              Shadow(
                                color: Color(0xFF00D4FF),
                                blurRadius: 20,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // App title
                          Text(
                            GameStrings.appTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00D4FF), // Flutter blue
                              letterSpacing: 2.0,
                              shadows: [
                                const Shadow(
                                  color: Colors.white,
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                ),
                                const Shadow(
                                  color: Color(0xFF00D4FF),
                                  blurRadius: 25,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),

                          // App description
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              GameStrings.appDescription,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFB3E5FC), // Light blue
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Play button
                          SizedBox(
                            width: 260,
                            child: ElevatedButton(
                              onPressed: () => _startGame(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D4FF),
                                foregroundColor: Colors.white,
                                elevation: 12,
                                shadowColor: const Color(
                                  0xFF00D4FF,
                                ).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: Text(
                                GameStrings.playButton,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Stats section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00D4FF,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
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
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF00D4FF),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _stat(
                                            GameStrings.lastScoreLabel,
                                            lastScore,
                                          ),
                                          if (bestCombo > 0)
                                            _stat(
                                              GameStrings.bestComboRecordLabel,
                                              bestCombo,
                                            ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _stat(
                                            GameStrings.bestScoreLabel,
                                            bestScore,
                                          ),

                                          if (gamesPlayed > 0)
                                            _stat(
                                              GameStrings.gamesPlayedLabel,
                                              gamesPlayed,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Start the game when Start key is pressed
  void _startGame(BuildContext context) async {
    final score = await Navigator.of(
      context,
    ).push<int>(MaterialPageRoute(builder: (_) => const GameScreen()));
    if (score != null) {
      // Reload stats after game to show updated values
      await _loadStats();
    }
  }

  Widget _stat(String label, int value) => Column(
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: const Color(0xFFB3E5FC), // Light blue
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        '$value',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF00D4FF), // Flutter blue
        ),
      ),
    ],
  );
}

/// Geometric pattern painter
class _FlutterPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Draw subtle Flutter-style geometric patterns
    for (int i = 0; i < 25; i++) {
      final x = (i * 60.0) % size.width;
      final y = (i * 50.0) % size.height;

      // Draw small circles in a grid pattern
      canvas.drawCircle(Offset(x, y), 10.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

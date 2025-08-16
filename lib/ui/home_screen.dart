import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/game_strings.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    GameStrings.appTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    GameStrings.appDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 240,
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        final score = await Navigator.of(context).push<int>(
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                        if (score != null) {
                          setState(() {
                            lastScore = score;
                            bestScore = max(bestScore, score);
                          });
                        }
                      },
                      child: const Text(GameStrings.playButton),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stat(GameStrings.lastScoreLabel, lastScore),
                      const SizedBox(width: 24),
                      _stat(GameStrings.bestScoreLabel, bestScore),
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

  Widget _stat(String label, int value) => Column(
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('$value', style: const TextStyle(fontSize: 20)),
    ],
  );
}

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/game_strings.dart';
import '../game/cotopaxi_game.dart';

/// Game screen that contains the Flame game
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _game = CotopaxiGame();

  @override
  void initState() {
    super.initState();
    _game.onGameOver = (result) {
      Navigator.of(context).pop(result.score);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'Countdown': (_, __) => const Center(
            child: Text(
              GameStrings.countdownMessage,
              style: TextStyle(fontSize: 48, color: Colors.white),
            ),
          ),
          'GameOver': (context, Game game) => Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(GameStrings.backButton),
            ),
          ),
        },
      ),
    );
  }
}

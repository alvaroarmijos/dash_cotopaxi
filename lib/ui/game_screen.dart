import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    // Enable fullscreen mode when game starts
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _game.onGameOver = (result) {
      Navigator.of(context).pop(result.score);
    };
  }

  @override
  void dispose() {
    // Restore normal UI mode when leaving the game
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          autofocus: true,
          onKey: (RawKeyEvent event) {
            String? keyName;

            if (event.logicalKey.keyLabel == 'Game Button B') {
              keyName = 'gameButtonB';
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              keyName = 'arrowUp';
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              keyName = 'arrowLeft';
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              keyName = 'arrowRight';
            }

            if (keyName != null) {
              if (event is RawKeyDownEvent) {
                _game.handleKeyDown(keyName);
              } else if (event is RawKeyUpEvent) {
                _game.handleKeyUp(keyName);
              }
            }
          },
          child: GameWidget(
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
        ),
      ),
    );
  }
}

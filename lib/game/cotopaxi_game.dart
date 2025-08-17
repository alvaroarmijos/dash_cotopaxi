import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/services.dart';

import '../core/game_config.dart';
import '../core/game_strings.dart';
import '../core/game_types.dart';
import '../core/game_utils.dart';
import '../core/vibration_service.dart';
import 'components.dart';
import 'player.dart';

/// Main game class that extends FlameGame
class CotopaxiGame extends FlameGame
    with
        HasCollisionDetection,
        TapDetector,
        DoubleTapDetector,
        PanDetector,
        HasGameReference {
  // Game components
  late Player player;
  late Ground ground;
  late Hud hud;
  late SpawnManager spawner;
  late ParallaxComponent parallax;

  // Game state
  PlayState state = PlayState.idle;
  double elapsed = 0;
  int score = 0;
  int lives = 3;
  int combo = 0;

  // Movement state tracking
  bool isMovingLeft = false;
  bool isMovingRight = false;

  // Callbacks
  GameOverCallback? onGameOver;
  Function(int score, int combo)? onVictory;

  @override
  Color backgroundColor() => const Color(0xFFB3E5FC); // sky

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize vibration service
    await VibrationService.initialize();

    // Preload all images that will be used
    await images.loadAll([
      'sprites/dash_jump.png',
      'sprites/llama.png',
      'sprites/roca.png',
      'sprites/charco.png',
      'sprites/cacao.png',
      'sprites/rosa.png',
      'parallax/bg_0_sky.png',
      'parallax/bg_1_clouds.png',
      'parallax/bg_2_cotopaxi.png',
      'parallax/bg_3_fields.png',
    ]);

    // Load Parallax background with seamless tiling
    parallax = await ParallaxComponent.load(
      [
        ParallaxImageData("parallax/bg_0_sky.png"),
        ParallaxImageData("parallax/bg_1_clouds.png"),
        ParallaxImageData("parallax/bg_2_cotopaxi.png"),
        ParallaxImageData("parallax/bg_3_fields.png"),
      ],
      baseVelocity: Vector2(30, 0),
      velocityMultiplierDelta: Vector2(1.1, 0),
    );

    add(parallax);

    // Add ground
    ground = Ground(height: GameConfig.groundHeight);
    add(ground);

    // Add player
    player = Player()
      ..position = Vector2(
        120,
        size.y - ground.height - GameConfig.playerHeight,
      );
    add(player);

    // Add HUD
    hud = Hud(game: this);
    add(hud);

    // Add spawn manager
    spawner = SpawnManager(onSpawn: (component) => add(component));
    add(spawner);

    startCountdown();
  }

  void startCountdown() async {
    state = PlayState.countdown;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = PlayState.running;
    hud.setMessage(GameStrings.gameStartMessage);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state != PlayState.running) return;

    elapsed += dt;
    hud.timeLeft = max(0, GameConfig.gameDuration - elapsed);

    // Movement is now handled directly in the key down/up events
    // No need to continuously call movement methods

    // Progressive difficulty
    spawner.interval = GameUtils.calculateSpawnInterval(elapsed);
    spawner.update(dt);

    // Check for victory (survive 60 seconds)
    if (hud.timeLeft <= 0 && lives > 0) {
      state = PlayState.victory;
      onVictory?.call(score, combo);
      return;
    }

    // Check for game over
    if (lives <= 0) {
      state = PlayState.gameOver;
      onGameOver?.call(
        GameResult(score: score, lives: lives, timeSurvived: elapsed),
      );
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (state != PlayState.running) return;
    player.jump();
  }

  @override
  void onDoubleTap() {
    if (state != PlayState.running) return;
    player.jump(stronger: true);
  }

  @override
  void onPanStart(DragStartInfo info) {
    // Sliding functionality removed
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Sliding functionality removed
  }

  @override
  void onPanEnd(DragEndInfo info) {
    // Sliding functionality removed
  }

  void addScore(int points) {
    final multiplier = GameUtils.calculateComboMultiplier(combo);
    score += points * multiplier;
    combo = (combo + 1).clamp(0, GameConfig.maxCombo);
    hud.score = score;
    hud.combo = combo;

    // Special vibration pattern for combo milestones
    if (combo > 0 && combo % GameConfig.comboThreshold == 0) {
      VibrationService.patternVibration();
    } else {
      // Light vibration for collecting items
      VibrationService.lightVibration();
    }
  }

  void hit() {
    lives = max(0, lives - 1);
    combo = 0;
    hud.lives = lives;

    // Trigger collision vibration
    VibrationService.collisionVibration();

    // Stronger vibration if game over
    if (lives <= 0) {
      VibrationService.strongVibration();
    }
  }

  /// Handle keyboard input - ONLY for specific Android gaming console keys
  void handleKeyPress(LogicalKeyboardKey key, bool isShiftPressed) {
    if (state != PlayState.running) return;
    if (!GameConfig.enableKeyboardControls) return;

    // === ONLY THESE TWO KEYS WORK ===
    // Arrow Up (detected as Arrow Up)
    if (key == LogicalKeyboardKey.arrowUp) {
      player.jump();
      return;
    }

    // Game Button B - need to find the exact LogicalKeyboardKey
    // Common mappings for Game Button B:
    if (key.keyLabel == 'Game Button B' ||
        key.debugName == 'Game Button B' ||
        key.keyId == 0x1000001c || // Common Android gamepad B button
        key.keyId == 0x1000001d || // Alternative B button mapping
        key == LogicalKeyboardKey.escape || // Sometimes mapped to escape
        key == LogicalKeyboardKey.backspace) {
      // Sometimes mapped to backspace
      player.jump();
      return;
    }
  }

  /// Handle specific keys detected by physical key name (key down)
  void handleKeyDown(String keyName) {
    if (state != PlayState.running) return;
    if (!GameConfig.enableKeyboardControls) return;

    switch (keyName) {
      case 'gameButtonB':
      case 'arrowUp':
        player.jump();
        break;
      case 'arrowLeft':
        isMovingLeft = true;
        player.startMoveLeft();
        break;
      case 'arrowRight':
        isMovingRight = true;
        player.startMoveRight();
        break;
    }
  }

  /// Handle key release events
  void handleKeyUp(String keyName) {
    switch (keyName) {
      case 'arrowLeft':
        isMovingLeft = false;
        player.stopMovement();
        break;
      case 'arrowRight':
        isMovingRight = false;
        player.stopMovement();
        break;
    }
  }
}

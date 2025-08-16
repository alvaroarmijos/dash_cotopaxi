import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';

import '../core/game_config.dart';
import '../core/game_strings.dart';
import '../core/game_types.dart';
import '../core/game_utils.dart';
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

  // Callbacks
  GameOverCallback? onGameOver;

  @override
  Color backgroundColor() => const Color(0xFFB3E5FC); // sky

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Preload all images that will be used
    await images.loadAll([
      'sprites/dash_run.png',
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

    // Progressive difficulty
    spawner.interval = GameUtils.calculateSpawnInterval(elapsed);
    spawner.update(dt);

    if (hud.timeLeft <= 0 || lives <= 0) {
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
  }

  void hit() {
    lives = max(0, lives - 1);
    combo = 0;
    hud.lives = lives;
  }
}

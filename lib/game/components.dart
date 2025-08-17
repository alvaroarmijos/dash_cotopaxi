import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../core/game_config.dart';
import '../core/game_strings.dart';
import '../core/game_types.dart';
import '../core/game_utils.dart';
import 'cotopaxi_game.dart';

/// Ground component for the game
class Ground extends PositionComponent with HasGameReference<CotopaxiGame> {
  @override
  final double height;

  Ground({required this.height});

  @override
  void render(Canvas canvas) {
    final r = Rect.fromLTWH(0, y, game.size.x, height);
    canvas.drawRect(r, Paint()..color = const Color(0xFF7CB342));
  }

  @override
  Future<void> onLoad() async {
    position = Vector2(0, game.size.y - height);
    size = Vector2(game.size.x, height);
  }
}

/// HUD (Heads Up Display) component
class Hud extends PositionComponent with HasGameReference<CotopaxiGame> {
  int score = 0;
  int lives = 3;
  int combo = 0;
  double timeLeft = 60;
  String? _message;
  bool _showControlsHint = true;
  double _controlsHintTimer = 0;

  Hud({required CotopaxiGame game}) {
    this.game = game;
  }

  void setMessage(String? m) => _message = m;

  @override
  void update(double dt) {
    super.update(dt);

    // Hide controls hint after 5 seconds of gameplay
    if (_showControlsHint && game.state == PlayState.running) {
      _controlsHintTimer += dt;
      if (_controlsHintTimer > 5.0) {
        _showControlsHint = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    tp(
      String text,
      double x,
      double y,
      double size, {
      FontWeight weight = FontWeight.w700,
      Color color = Colors.black,
    }) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: size, fontWeight: weight, color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(x, y));
    }

    tp(
      '${GameStrings.timeLabel} ${timeLeft.toStringAsFixed(0)}',
      GameConfig.hudPadding,
      GameConfig.hudPadding,
      GameConfig.scoreFontSize,
    );
    tp(
      '${GameStrings.scoreLabel} $score',
      game.size.x / 2 - 40,
      GameConfig.hudPadding,
      GameConfig.scoreFontSize,
    );
    tp(
      '${GameStrings.livesLabel} $lives',
      game.size.x - 80,
      GameConfig.hudPadding,
      GameConfig.scoreFontSize,
    );

    if (combo >= GameConfig.comboThreshold) {
      tp(
        '${GameStrings.comboPrefix}${GameUtils.calculateComboMultiplier(combo)}',
        game.size.x / 2 - 50,
        GameConfig.hudPadding * 3,
        GameConfig.comboFontSize,
        color: Colors.deepOrange,
        weight: FontWeight.w800,
      );
    }

    if (_message != null) {
      tp(
        _message!,
        game.size.x / 2 - 40,
        game.size.y / 2 - 10,
        GameConfig.messageFontSize,
        color: Colors.black54,
      );
    }

    // Show physical controls hint for Android gaming consoles
    if (_showControlsHint && GameConfig.enableKeyboardControls) {
      const controlsY = 80.0;

      tp(
        GameStrings.physicalControlsSupported,
        GameConfig.hudPadding,
        controlsY,
        14,
        color: Colors.blue.shade700,
        weight: FontWeight.w600,
      );

      tp(
        GameStrings.normalJumpControls,
        GameConfig.hudPadding,
        controlsY + 20,
        12,
        color: Colors.black87,
      );

      tp(
        GameStrings.highJumpControls,
        GameConfig.hudPadding,
        controlsY + 35,
        12,
        color: Colors.black87,
      );

      tp(
        GameStrings.alternativeControls,
        GameConfig.hudPadding,
        controlsY + 50,
        11,
        color: Colors.grey.shade600,
      );
    }
  }
}

/// Spawn manager for obstacles and collectibles
class SpawnManager extends Component with HasGameReference<CotopaxiGame> {
  final SpawnCallback onSpawn;
  final _rng = Random();
  double t = 0;
  double interval = GameConfig.spawnInterval;

  SpawnManager({required this.onSpawn});

  @override
  void update(double dt) {
    t += dt;
    if (t >= interval) {
      t = 0;

      // Dynamic obstacle probability based on game time
      final elapsedTime = game.elapsed;
      const baseObstacleProbability = 0.4; // Start with lower obstacle rate
      const maxObstacleProbability = 0.75; // Maximum obstacle rate
      final difficultyProgress = (elapsedTime / 60.0).clamp(0.0, 1.0);
      final obstacleProbability =
          baseObstacleProbability +
          (difficultyProgress *
              (maxObstacleProbability - baseObstacleProbability));

      final r = _rng.nextDouble();
      if (r < obstacleProbability) {
        onSpawn(Obstacle.random(game));
      } else {
        onSpawn(Collectible.random(game));
      }
    }
  }
}

/// Obstacle component (llamas, rocas, charcos)
class Obstacle extends SpriteComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  double speed = GameConfig.obstacleSpeed;

  static final _rng = Random();

  static Obstacle llama(CotopaxiGame game) {
    return _fromImagePath(game, 'sprites/llama.png', sizePx: Vector2(96, 72));
  }

  static Obstacle roca(CotopaxiGame game) {
    return _fromImagePath(game, 'sprites/roca.png', sizePx: Vector2(56, 40));
  }

  static Obstacle charco(CotopaxiGame game) {
    return _fromImagePath(game, 'sprites/charco.png', sizePx: Vector2(72, 24));
  }

  static Obstacle random(CotopaxiGame game) {
    final r = _rng.nextDouble();
    if (r < 0.34) return llama(game);
    if (r < 0.67) return roca(game);
    return charco(game);
  }

  static Obstacle _fromImagePath(
    CotopaxiGame game,
    String path, {
    required Vector2 sizePx,
  }) {
    final o = Obstacle()..size = sizePx;
    o.sprite = Sprite(game.images.fromCache(path));
    o.position = Vector2(
      game.size.x + 10,
      game.size.y - game.ground.height - o.height - 6,
    );
    o.speed = GameUtils.calculateObstacleSpeed(game.elapsed);
    o.add(
      RectangleHitbox()
        ..collisionType = CollisionType.passive
        ..renderShape = GameConfig.showHitBoxes,
    );
    return o;
  }

  @override
  void update(double dt) {
    x -= speed * dt;
    if (x < -width - 20) removeFromParent();
    super.update(dt);
  }
}

/// Collectible component (cacao, rosas)
class Collectible extends SpriteComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  double speed = GameConfig.obstacleSpeed;

  static Collectible cacao(CotopaxiGame game) =>
      _spawn(game, 'sprites/cacao.png');

  static Collectible rosa(CotopaxiGame game) =>
      _spawn(game, 'sprites/rosa.png');

  static Collectible random(CotopaxiGame game) {
    return Random().nextBool() ? cacao(game) : rosa(game);
  }

  static Collectible _spawn(CotopaxiGame game, String path) {
    final c = Collectible()
      ..sprite = Sprite(game.images.fromCache(path))
      ..size = Vector2(36, 36)
      ..position = Vector2(
        game.size.x + 10,
        game.size.y - game.ground.height - 120 - Random().nextInt(60),
      )
      ..speed = GameUtils.calculateObstacleSpeed(game.elapsed);
    c.add(
      RectangleHitbox()
        ..collisionType = CollisionType.passive
        ..renderShape = GameConfig.showHitBoxes,
    );
    return c;
  }

  @override
  void update(double dt) {
    x -= speed * dt;
    if (x < -width - 20) removeFromParent();
    super.update(dt);
  }
}

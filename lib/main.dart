import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DashCotopaxiApp());
}

class DashCotopaxiApp extends StatelessWidget {
  const DashCotopaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: const Color(0xFF1B5E20),
      useMaterial3: true,
      textTheme: GoogleFonts.nunitoTextTheme(),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
    );
  }
}

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
                    'Dash por el Cotopaxi',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Endless runner de 60s — esquiva llamas/rocas y recoge cacao/rosas.',
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
                      child: const Text('Jugar (60s)'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stat('Último', lastScore),
                      const SizedBox(width: 24),
                      _stat('Mejor', bestScore),
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
    _game.onGameOver = (score) {
      Navigator.of(context).pop(score);
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
              '3... 2... 1...',
              style: TextStyle(fontSize: 48, color: Colors.white),
            ),
          ),
          'GameOver': (context, Game game) => Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Volver'),
            ),
          ),
        },
      ),
    );
  }
}

enum PlayState { idle, countdown, running, gameOver }

class CotopaxiGame extends FlameGame
    with
        HasCollisionDetection,
        TapDetector,
        DoubleTapDetector,
        PanDetector,
        HasGameReference {
  late Player player;
  late Ground ground;
  late Hud hud;
  late SpawnManager spawner;
  late ParallaxComponent parallax;

  final double gravity = 1600; // px/s^2
  final double runDuration = 60; // seconds
  double elapsed = 0;
  int score = 0;
  int lives = 3;
  int combo = 0;
  PlayState state = PlayState.idle;

  void Function(int score)? onGameOver;

  // Gesture variables removed - sliding functionality disabled

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
      repeat: ImageRepeat.repeatX,
      filterQuality: FilterQuality.none,
    );

    add(parallax);

    ground = Ground(height: 120);
    add(ground);

    player = Player()..position = Vector2(120, size.y - ground.height - 96);
    add(player);

    hud = Hud(game: this);
    add(hud);

    spawner = SpawnManager(onSpawn: (component) => add(component));
    add(spawner);

    startCountdown();
  }

  void startCountdown() async {
    state = PlayState.countdown;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = PlayState.running;
    hud.setMessage('¡Vamos!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state != PlayState.running) return;

    elapsed += dt;
    hud.timeLeft = max(0, runDuration - elapsed);

    // Progressive difficulty
    spawner.interval = (1.2 - (elapsed ~/ 10) * 0.15).clamp(0.55, 1.2);
    spawner.update(dt);

    if (hud.timeLeft <= 0 || lives <= 0) {
      state = PlayState.gameOver;
      onGameOver?.call(score);
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

  void addScore(int s) {
    score += s * (1 + (combo ~/ 5)).clamp(1, 5);
    combo = (combo + 1).clamp(0, 99);
    hud.score = score;
    hud.combo = combo;
  }

  void hit() {
    lives = max(0, lives - 1);
    combo = 0;
    hud.lives = lives;
  }
}

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

class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  final Vector2 velocity = Vector2.zero();
  bool isOnGround = true;

  late SpriteAnimationData _jumpData;

  @override
  Future<void> onLoad() async {
    final imgRun = game.images.fromCache('sprites/dash_run.png');
    final imgJump = game.images.fromCache('sprites/dash_jump.png');

    // size of each frame
    final frameW = imgRun.width / 6;
    final frameH = imgRun.height.toDouble();

    final jumpW = imgJump.width / 4;
    final jumpH = imgJump.height.toDouble();
    // slideW and slideH removed - sliding functionality disabled

    final sheet = SpriteSheet(image: imgRun, srcSize: Vector2(frameW, frameH));

    // Recorre filas y columnas para sacar los 8 frames
    final frames = <Sprite>[
      sheet.getSprite(0, 1),
      sheet.getSprite(0, 1),
      sheet.getSprite(0, 2),
      sheet.getSprite(0, 3),
      sheet.getSprite(0, 4),
      sheet.getSprite(0, 5),
    ];
    _jumpData = SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.10,
      textureSize: Vector2(jumpW, jumpH),
      loop: false,
    );

    // assign animation
    animation = SpriteAnimation.spriteList(frames, stepTime: 0.4);

    size = Vector2(96, 96);
    anchor = Anchor.center;

    // Add hitbox for collisions
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    velocity.y += game.gravity * dt;
    position += velocity * dt;

    // Check if on ground
    final groundY = game.size.y - game.ground.height - height / 2;
    if (y >= groundY) {
      y = groundY;
      velocity.y = 0;
      isOnGround = true;
    } else {
      isOnGround = false;
    }
  }

  void jump({bool stronger = false}) {
    if (isOnGround) {
      velocity.y = stronger ? -720 : -620;
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('sprites/dash_jump.png'),
        _jumpData,
      );
    }
  }

  // slide method removed - sliding functionality disabled

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Obstacle) {
      game.hit();
      // Temporary invulnerability effect
      opacity = 0.5;
      Future.delayed(const Duration(milliseconds: 1000), () {
        opacity = 1.0;
      });
    } else if (other is Collectible) {
      other.removeFromParent();
      game.addScore(10);
    }
  }
}

class Hud extends PositionComponent with HasGameReference<CotopaxiGame> {
  int score = 0;
  int lives = 3;
  int combo = 0;
  double timeLeft = 60;
  String? _message;

  Hud({required CotopaxiGame game}) {
    this.game = game;
  }

  void setMessage(String? m) => _message = m;

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

    tp('⏱ ${timeLeft.toStringAsFixed(0)}', 16, 16, 24);
    tp('⭐ $score', game.size.x / 2 - 40, 16, 24);
    tp('❤ $lives', game.size.x - 80, 16, 24);
    if (combo >= 5) {
      tp(
        'Combo x${1 + (combo ~/ 5)}',
        game.size.x / 2 - 50,
        48,
        16,
        color: Colors.deepOrange,
        weight: FontWeight.w800,
      );
    }
    if (_message != null) {
      tp(
        _message!,
        game.size.x / 2 - 40,
        game.size.y / 2 - 10,
        18,
        color: Colors.black54,
      );
    }
  }
}

class SpawnManager extends Component with HasGameReference<CotopaxiGame> {
  final void Function(Component) onSpawn;
  final _rng = Random();
  double t = 0;
  double interval = 1.2;

  SpawnManager({required this.onSpawn});

  @override
  void update(double dt) {
    t += dt;
    if (t >= interval) {
      t = 0;
      final r = _rng.nextDouble();
      if (r < 0.65) {
        onSpawn(Obstacle.random(game));
      } else {
        onSpawn(Collectible.random(game));
      }
    }
  }
}

class Obstacle extends SpriteComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  double speed = 360;

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
    o.speed = 320 + (game.elapsed * 8);
    o.add(RectangleHitbox()..collisionType = CollisionType.passive);
    return o;
  }

  @override
  void update(double dt) {
    x -= speed * dt;
    if (x < -width - 20) removeFromParent();
    super.update(dt);
  }
}

class Collectible extends SpriteComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  double speed = 360;

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
      ..speed = 320 + (game.elapsed * 8);
    c.add(RectangleHitbox()..collisionType = CollisionType.passive);
    return c;
  }

  @override
  void update(double dt) {
    x -= speed * dt;
    if (x < -width - 20) removeFromParent();
    super.update(dt);
  }
}

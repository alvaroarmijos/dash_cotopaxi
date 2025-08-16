import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/game_config.dart';
import 'components.dart';
import 'cotopaxi_game.dart';

/// Player character (Dash) component
class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  final Vector2 velocity = Vector2.zero();
  bool isOnGround = true;

  late SpriteAnimationData _jumpData;

  @override
  Future<void> onLoad() async {
    final imgRun = game.images.fromCache('sprites/dash_run.png');
    final imgJump = game.images.fromCache('sprites/dash_jump.png');

    // Calculate frame size by columns
    // define real columns and rows of the sheet
    const cols = 6; // 6 frames in a single row
    const rows = 1; // Only 1 row

    // size of each frame
    final frameW = imgRun.width / cols;
    final frameH = imgRun.height / rows;

    final jumpW = imgJump.width / 4;
    final jumpH = imgJump.height.toDouble();

    _jumpData = SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.10,
      textureSize: Vector2(jumpW, jumpH),
      loop: false,
    );

    // Use SpriteAnimation.fromFrameData for more efficient sprite sheet handling
    // This automatically extracts frames from the sheet
    animation = SpriteAnimation.fromFrameData(
      imgRun,
      SpriteAnimationData.sequenced(
        amount: 6, // 6 frames
        stepTime: 0.08,
        textureSize: Vector2(frameW, frameH),
        loop: true,
      ),
    );

    size = Vector2(GameConfig.playerWidth, GameConfig.playerHeight);
    anchor = Anchor.center;

    // Add hitbox for collisions (configurable visibility)
    add(
      RectangleHitbox()
        ..collisionType = CollisionType.active
        ..renderShape = GameConfig.showHitBoxes,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    velocity.y += GameConfig.gravity * dt;
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
      velocity.y = stronger ? -GameConfig.highJumpForce : -GameConfig.jumpForce;
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('sprites/dash_jump.png'),
        _jumpData,
      );
    }
  }

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
      game.addScore(GameConfig.itemScore);
    }
  }
}

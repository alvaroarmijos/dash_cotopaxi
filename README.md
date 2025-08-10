# 🏔️ Dash por el Cotopaxi

An endless runner game developed in Flutter + Flame where you control Dash running through Cotopaxi, avoiding obstacles and collecting cacao and roses.

## 🎮 Game Features

- **Genre**: Endless runner with time limit (60 seconds)
- **Objective**: Maximize score by avoiding obstacles and collecting items
- **Controls**: 
  - Single tap: Normal jump
  - Double tap: High jump
  - Swipe down: Slide
- **Mechanics**:
  - Life system (3 hearts)
  - Combo multiplier (x1 to x5)
  - Progressive difficulty every 10 seconds
  - Scoring for collected items and survival time

## 🚀 Installation and Execution

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- macOS (for native compilation)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dash_cotopaxi
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the game**
   ```bash
   # For development
   flutter run -d macos
   
   # For release build
   flutter build macos --release
   ```

## 🏗️ Project Architecture

```
lib/
├── main.dart                 # Entry point and main game logic
├── core/                     # Configurations and utilities (future)
├── game/                     # Game logic (future)
├── ui/                       # User interfaces (future)
└── assets/                   # Game resources
    ├── images/
    │   ├── sprites/          # Characters and objects
    │   ├── parallax/         # Layered backgrounds
    │   └── ui/               # Interface elements
    ├── sfx/                  # Sound effects (future)
    └── fonts/                # Typographies (future)
```

## 🎯 Main Components

### CotopaxiGame
- Main game class that extends `FlameGame`
- Manages game state (idle, countdown, running, gameOver)
- Coordinates all game systems

### Player (Dash)
- Main character controlled by the user
- Physics system with gravity and collisions
- Animations for running, jumping and sliding
- Collision detection with obstacles and collectibles

### SpawnManager
- Randomly generates obstacles and collectibles
- Progressive difficulty based on elapsed time
- Spawn frequency control

### Obstacles & Collectibles
- **Obstacles**: Llamas, rocks and puddles (lose lives)
- **Collectibles**: Cacao and roses (increase score)
- Automatic movement from right to left

### HUD (Heads Up Display)
- Remaining time
- Current score
- Remaining lives
- Combo multiplier

## 🎨 Game Assets

### Sprites
- `dash_run.png`: Running animation (8 frames)
- `dash_jump.png`: Jump animation (4 frames)
- `dash_slide.png`: Slide animation (4 frames)
- `llama.png`, `roca.png`, `charco.png`: Obstacles
- `cacao.png`, `rosa.png`: Collectibles

### Parallax Backgrounds
- `bg_0_sky.png`: Base sky
- `bg_1_clouds.png`: Clouds (layer 1)
- `bg_2_cotopaxi.png`: Cotopaxi mountain (layer 2)
- `bg_3_fields.png`: Fields and prairies (layer 3)

## 🎮 How to Play

1. **Start**: Press "Play (60s)" on the main screen
2. **Countdown**: Wait for the 3, 2, 1 countdown...
3. **Gameplay**: 
   - Tap to jump over obstacles
   - Double tap for high jump
   - Swipe down to avoid llamas
   - Collect cacao and roses for points
4. **Objective**: Survive 60 seconds with the highest possible score

## 🔧 Customization

### Difficulty
- Base speed: 300 px/s
- Increase: +15 px/s every 10 seconds
- Spawn frequency: 1.2s → 0.55s

### Scoring
- Cacao/Rose: +10 points
- Survival time: +5 points/second
- Combo multiplier: x1 to x5

## 🐛 Troubleshooting

### Common issues
1. **"No issues found"**: Game compiles correctly
2. **Assets not found**: Verify that paths in `pubspec.yaml` are correct
3. **Collisions not working**: Make sure `HasCollisionDetection` is active

### Debug
```bash
# Static analysis
flutter analyze

# Build cleanup
flutter clean
flutter pub get

# Debug build
flutter build macos --debug
```

## 🚧 Upcoming Improvements

- [ ] Audio system with `flame_audio`
- [ ] Local leaderboard with `shared_preferences`
- [ ] Particle effects
- [ ] More obstacle types
- [ ] Power-ups and special abilities
- [ ] Local multiplayer mode
- [ ] Game Center integration

## 📱 Supported Platforms

- ✅ macOS (primary)
- 🔄 iOS (in development)
- 🔄 Android (in development)
- 🔄 Web (future)

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is under the MIT License. See `LICENSE` for more details.

## 🙏 Acknowledgments

- **Flame Engine**: Game engine for Flutter
- **Flutter Team**: Cross-platform UI framework
- **Flutter Community**: For support and resources
- **Cotopaxi**: Inspiration for the game theme

---

**Enjoy running through Cotopaxi! 🏃‍♂️🏔️**

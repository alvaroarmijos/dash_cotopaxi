import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle score persistence using SharedPreferences
/// Implemented as a singleton for better performance
class ScoreService {
  static const String _bestScoreKey = 'best_score';
  static const String _bestComboKey = 'best_combo';
  static const String _lastScoreKey = 'last_score';
  static const String _lastComboKey = 'last_combo';
  static const String _gamesPlayedKey = 'games_played';

  // Singleton instance
  static ScoreService? _instance;
  static ScoreService get instance => _instance ??= ScoreService._internal();

  // Private constructor
  ScoreService._internal();

  // SharedPreferences instance - initialized once
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize the service (call this once at app startup)
  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Get the best score from SharedPreferences
  Future<int> getBestScore() async {
    await _ensureInitialized();
    return _prefs!.getInt(_bestScoreKey) ?? 0;
  }

  /// Get the best combo from SharedPreferences
  Future<int> getBestCombo() async {
    await _ensureInitialized();
    return _prefs!.getInt(_bestComboKey) ?? 0;
  }

  /// Get the last score from SharedPreferences
  Future<int> getLastScore() async {
    await _ensureInitialized();
    return _prefs!.getInt(_lastScoreKey) ?? 0;
  }

  /// Get the last combo from SharedPreferences
  Future<int> getLastCombo() async {
    await _ensureInitialized();
    return _prefs!.getInt(_lastComboKey) ?? 0;
  }

  /// Get the total number of games played
  Future<int> getGamesPlayed() async {
    await _ensureInitialized();
    return _prefs!.getInt(_gamesPlayedKey) ?? 0;
  }

  /// Save a new score and combo, updating best scores if necessary
  Future<bool> saveScore(int score, int combo) async {
    await _ensureInitialized();

    // Always save last score and combo
    await _prefs!.setInt(_lastScoreKey, score);
    await _prefs!.setInt(_lastComboKey, combo);

    // Increment games played
    final gamesPlayed = _prefs!.getInt(_gamesPlayedKey) ?? 0;
    await _prefs!.setInt(_gamesPlayedKey, gamesPlayed + 1);

    // Check if this is a new best score
    final currentBestScore = _prefs!.getInt(_bestScoreKey) ?? 0;
    final currentBestCombo = _prefs!.getInt(_bestComboKey) ?? 0;

    bool isNewBestScore = false;
    bool isNewBestCombo = false;

    if (score > currentBestScore) {
      await _prefs!.setInt(_bestScoreKey, score);
      isNewBestScore = true;
    }

    if (combo > currentBestCombo) {
      await _prefs!.setInt(_bestComboKey, combo);
      isNewBestCombo = true;
    }

    return isNewBestScore || isNewBestCombo;
  }

  /// Save only the last score and combo (without updating best scores)
  Future<void> saveLastScore(int score, int combo) async {
    await _ensureInitialized();

    // Save last score and combo
    await _prefs!.setInt(_lastScoreKey, score);
    await _prefs!.setInt(_lastComboKey, combo);

    // Check if this is a new best score
    final currentBestScore = _prefs!.getInt(_bestScoreKey) ?? 0;
    final currentBestCombo = _prefs!.getInt(_bestComboKey) ?? 0;

    if (score > currentBestScore) {
      await _prefs!.setInt(_bestScoreKey, score);
    }

    if (combo > currentBestCombo) {
      await _prefs!.setInt(_bestComboKey, combo);
    }
  }

  /// Check if a score is a new best score
  Future<bool> isNewBestScore(int score) async {
    final bestScore = await getBestScore();
    return score > bestScore;
  }

  /// Check if a combo is a new best combo
  Future<bool> isNewBestCombo(int combo) async {
    final bestCombo = await getBestCombo();
    return combo > bestCombo;
  }

  /// Reset all scores (useful for testing or reset functionality)
  Future<void> resetAllScores() async {
    await _ensureInitialized();
    await _prefs!.remove(_bestScoreKey);
    await _prefs!.remove(_bestComboKey);
    await _prefs!.remove(_lastScoreKey);
    await _prefs!.remove(_lastComboKey);
    await _prefs!.remove(_gamesPlayedKey);
  }

  /// Get all score statistics
  Future<Map<String, int>> getAllStats() async {
    return {
      'bestScore': await getBestScore(),
      'bestCombo': await getBestCombo(),
      'lastScore': await getLastScore(),
      'lastCombo': await getLastCombo(),
      'gamesPlayed': await getGamesPlayed(),
    };
  }
}

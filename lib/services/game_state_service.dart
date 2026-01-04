import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// GameStateService - Manages game state persistence using SharedPreferences
///
/// Handles:
/// - Player progress (current level, gems, XP)
/// - Selected program
/// - Level completion status with stars/gems
/// - Power-up inventory
/// - Settings persistence
class GameStateService {
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyTotalGems = 'total_gems';
  static const String _keyTotalXP = 'total_xp';
  static const String _keyCurrentProgram = 'current_program';
  static const String _keyHasSavedProgress = 'has_saved_progress';
  static const String _keyLevelProgress = 'level_progress';
  static const String _keyPowerUps = 'power_ups';
  static const String _keyCharacterAvatar = 'character_avatar';
  static const String _keyPlayerName = 'player_name';
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySoundEffectsVolume = 'sound_effects_volume';
  static const String _keyHintsAvailable = 'hints_available';

  // Default values for fresh install
  static const int defaultLevel = 1;
  static const int defaultGems = 50;
  static const int defaultXP = 0;
  static const int defaultHints = 3;
  static const String defaultProgram = '';
  static const String defaultAvatar =
      "https://api.dicebear.com/7.x/avataaars/png?seed=Felix&backgroundColor=b6e3f4";

  SharedPreferences? _prefs;

  // Singleton pattern
  static final GameStateService _instance = GameStateService._internal();
  factory GameStateService() => _instance;
  GameStateService._internal();

  /// Initialize the service - must be called before using
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if service is initialized
  bool get isInitialized => _prefs != null;

  // ============ GETTERS ============

  /// Get current player level
  int get currentLevel => _prefs?.getInt(_keyCurrentLevel) ?? defaultLevel;

  /// Get total gems collected
  int get totalGems => _prefs?.getInt(_keyTotalGems) ?? defaultGems;

  /// Get total XP earned
  int get totalXP => _prefs?.getInt(_keyTotalXP) ?? defaultXP;

  /// Get currently selected program ID
  String get currentProgram =>
      _prefs?.getString(_keyCurrentProgram) ?? defaultProgram;

  /// Check if player has saved progress
  bool get hasSavedProgress => _prefs?.getBool(_keyHasSavedProgress) ?? false;

  /// Get hints available
  int get hintsAvailable => _prefs?.getInt(_keyHintsAvailable) ?? defaultHints;

  /// Get character avatar URL
  String get characterAvatar =>
      _prefs?.getString(_keyCharacterAvatar) ?? defaultAvatar;

  /// Get player name
  String get playerName => _prefs?.getString(_keyPlayerName) ?? 'Player';

  /// Get music volume (0.0 - 1.0)
  double get musicVolume => _prefs?.getDouble(_keyMusicVolume) ?? 0.7;

  /// Get sound effects volume (0.0 - 1.0)
  double get soundEffectsVolume =>
      _prefs?.getDouble(_keySoundEffectsVolume) ?? 0.8;

  /// Get level progress for a specific program
  /// Returns Map: { levelId: { 'completed': bool, 'stars': int, 'gems': int } }
  Map<String, dynamic> getLevelProgress(String programId) {
    final progressJson = _prefs?.getString('${_keyLevelProgress}_$programId');
    if (progressJson == null) return {};
    try {
      return jsonDecode(progressJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Get power-ups inventory
  /// Returns Map: { 'extra_time': int, 'eliminate': int, 'hint': int }
  Map<String, int> get powerUps {
    final powerUpsJson = _prefs?.getString(_keyPowerUps);
    if (powerUpsJson == null) {
      return {'extra_time': 2, 'eliminate': 1, 'hint': 3};
    }
    try {
      final decoded = jsonDecode(powerUpsJson) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {'extra_time': 2, 'eliminate': 1, 'hint': 3};
    }
  }

  /// Check if a specific level is unlocked for a program
  bool isLevelUnlocked(String programId, int levelId) {
    // Level 1 is always unlocked
    if (levelId == 1) return true;

    // Check if previous level is completed
    final progress = getLevelProgress(programId);
    final previousLevelKey = (levelId - 1).toString();
    final previousLevel = progress[previousLevelKey] as Map<String, dynamic>?;

    return previousLevel?['completed'] == true;
  }

  /// Check if a specific level is completed
  bool isLevelCompleted(String programId, int levelId) {
    final progress = getLevelProgress(programId);
    final levelData = progress[levelId.toString()] as Map<String, dynamic>?;
    return levelData?['completed'] == true;
  }

  /// Get stars earned for a specific level
  int getLevelStars(String programId, int levelId) {
    final progress = getLevelProgress(programId);
    final levelData = progress[levelId.toString()] as Map<String, dynamic>?;
    return (levelData?['stars'] as int?) ?? 0;
  }

  /// Get gems collected for a specific level
  int getLevelGems(String programId, int levelId) {
    final progress = getLevelProgress(programId);
    final levelData = progress[levelId.toString()] as Map<String, dynamic>?;
    return (levelData?['gems'] as int?) ?? 0;
  }

  // ============ SETTERS ============

  /// Set current player level
  Future<void> setCurrentLevel(int level) async {
    await _prefs?.setInt(_keyCurrentLevel, level);
  }

  /// Set total gems
  Future<void> setTotalGems(int gems) async {
    await _prefs?.setInt(_keyTotalGems, gems);
  }

  /// Add gems to total
  Future<void> addGems(int gems) async {
    await setTotalGems(totalGems + gems);
  }

  /// Set total XP
  Future<void> setTotalXP(int xp) async {
    await _prefs?.setInt(_keyTotalXP, xp);
  }

  /// Add XP to total
  Future<void> addXP(int xp) async {
    await setTotalXP(totalXP + xp);
  }

  /// Set current program
  Future<void> setCurrentProgram(String programId) async {
    await _prefs?.setString(_keyCurrentProgram, programId);
    await _prefs?.setBool(_keyHasSavedProgress, true);
  }

  /// Set hints available
  Future<void> setHintsAvailable(int hints) async {
    await _prefs?.setInt(_keyHintsAvailable, hints);
  }

  /// Use a hint (decrements count)
  Future<void> useHint() async {
    if (hintsAvailable > 0) {
      await setHintsAvailable(hintsAvailable - 1);
    }
  }

  /// Set character avatar URL
  Future<void> setCharacterAvatar(String avatarUrl) async {
    await _prefs?.setString(_keyCharacterAvatar, avatarUrl);
  }

  /// Set player name
  Future<void> setPlayerName(String name) async {
    await _prefs?.setString(_keyPlayerName, name);
  }

  /// Set music volume
  Future<void> setMusicVolume(double volume) async {
    await _prefs?.setDouble(_keyMusicVolume, volume.clamp(0.0, 1.0));
  }

  /// Set sound effects volume
  Future<void> setSoundEffectsVolume(double volume) async {
    await _prefs?.setDouble(_keySoundEffectsVolume, volume.clamp(0.0, 1.0));
  }

  /// Set power-ups inventory
  Future<void> setPowerUps(Map<String, int> powerUpsMap) async {
    await _prefs?.setString(_keyPowerUps, jsonEncode(powerUpsMap));
  }

  /// Use a power-up (decrements count)
  Future<bool> usePowerUp(String powerUpType) async {
    final currentPowerUps = powerUps;
    final count = currentPowerUps[powerUpType] ?? 0;
    if (count > 0) {
      currentPowerUps[powerUpType] = count - 1;
      await setPowerUps(currentPowerUps);
      return true;
    }
    return false;
  }

  /// Add power-up
  Future<void> addPowerUp(String powerUpType, int count) async {
    final currentPowerUps = powerUps;
    currentPowerUps[powerUpType] = (currentPowerUps[powerUpType] ?? 0) + count;
    await setPowerUps(currentPowerUps);
  }

  // ============ LEVEL COMPLETION ============

  /// Complete a level with results
  ///
  /// [programId] - The program ID (e.g., 'bsit')
  /// [levelId] - The level number (1-18)
  /// [stars] - Stars earned (1-3)
  /// [gems] - Gems collected
  /// [xp] - XP earned
  Future<void> completeLevelWithResults({
    required String programId,
    required int levelId,
    required int stars,
    required int gems,
    required int xp,
  }) async {
    // Get current progress
    final progress = getLevelProgress(programId);

    // Update level data (keep best score if already completed)
    final existingData = progress[levelId.toString()] as Map<String, dynamic>?;
    final existingStars = (existingData?['stars'] as int?) ?? 0;
    final existingGems = (existingData?['gems'] as int?) ?? 0;

    progress[levelId.toString()] = {
      'completed': true,
      'stars': stars > existingStars ? stars : existingStars,
      'gems': gems > existingGems ? gems : existingGems,
    };

    // Save progress
    await _prefs?.setString(
      '${_keyLevelProgress}_$programId',
      jsonEncode(progress),
    );

    // Update totals (only add new gems/xp if this is first completion or better)
    if (existingData == null || existingData['completed'] != true) {
      await addGems(gems);
      await addXP(xp);
    } else {
      // Add only the difference if improved
      if (gems > existingGems) {
        await addGems(gems - existingGems);
      }
    }

    // Update current level if this is the highest completed
    final highestLevel = _calculateHighestCompletedLevel(programId);
    if (highestLevel >= currentLevel) {
      await setCurrentLevel(highestLevel + 1);
    }

    // Mark as having saved progress
    await _prefs?.setBool(_keyHasSavedProgress, true);

    // Check for achievements immediately
    await checkAndUnlockAchievements(programId);
  }

  /// Calculate the highest completed level for a program
  int _calculateHighestCompletedLevel(String programId) {
    final progress = getLevelProgress(programId);
    int highest = 0;

    for (int i = 1; i <= 18; i++) {
      final levelData = progress[i.toString()] as Map<String, dynamic>?;
      if (levelData?['completed'] == true) {
        highest = i;
      } else {
        break; // Stop at first uncompleted level
      }
    }

    return highest;
  }

  /// Get count of completed levels for a program
  int getCompletedLevelsCount(String programId) {
    final progress = getLevelProgress(programId);
    int count = 0;

    progress.forEach((key, value) {
      if (value is Map && value['completed'] == true) {
        count++;
      }
    });

    return count;
  }

  /// Get total stars earned for a program
  int getTotalStars(String programId) {
    final progress = getLevelProgress(programId);
    int total = 0;

    progress.forEach((key, value) {
      if (value is Map && value['stars'] != null) {
        total += (value['stars'] as int);
      }
    });

    return total;
  }

  /// Get number of cleared zones for a program (0-3)
  /// Zone 1: Levels 1-6 completed
  /// Zone 2: Levels 7-12 completed
  /// Zone 3: Levels 13-18 completed
  int getClearedZonesCount(String programId) {
    final progress = getLevelProgress(programId);
    int clearedZones = 0;

    // Check Zone 1 (Levels 1-6)
    bool zone1Cleared = true;
    for (int i = 1; i <= 6; i++) {
      if (progress[i.toString()] == null ||
          progress[i.toString()]['completed'] != true) {
        zone1Cleared = false;
        break;
      }
    }
    if (zone1Cleared)
      clearedZones++;
    else
      return 0; // If Zone 1 not cleared, return 0 (zones must be cleared in order)

    // Check Zone 2 (Levels 7-12)
    bool zone2Cleared = true;
    for (int i = 7; i <= 12; i++) {
      if (progress[i.toString()] == null ||
          progress[i.toString()]['completed'] != true) {
        zone2Cleared = false;
        break;
      }
    }
    if (zone2Cleared)
      clearedZones++;
    else
      return 1;

    // Check Zone 3 (Levels 13-18)
    bool zone3Cleared = true;
    for (int i = 13; i <= 18; i++) {
      if (progress[i.toString()] == null ||
          progress[i.toString()]['completed'] != true) {
        zone3Cleared = false;
        break;
      }
    }
    if (zone3Cleared) clearedZones++;

    return clearedZones;
  }

  /// Check and unlock achievements for a program based on cleared zones
  Future<void> checkAndUnlockAchievements(String programId) async {
    final clearedZones = getClearedZonesCount(programId);

    // Define achievement IDs for each program's zones
    // Logic:
    // Program ID -> [Zone 1 ID, Zone 2 ID, Zone 3 ID]
    // These IDs should effectively map to a database of achievements.
    // For this implementation, we will generate IDs deterministically or use a map.

    // Example ID generation: hash(programId) + zoneIndex?
    // Or simplified:
    // BSIT: 101, 102, 103
    // BSBA: 201, 202, 203
    // etc.

    final programPrefixes = {
      'bsit': 100,
      'bsba': 200,
      'bsed': 300,
      'beed': 400,
      'bsa': 500,
      'bshm': 600,
      'bscs': 700,
      'bscpe': 800,
      'ahm': 900,
    };

    final prefix = programPrefixes[programId.toLowerCase()] ?? 1000;

    if (clearedZones >= 1) await unlockAchievement(prefix + 1);
    if (clearedZones >= 2) await unlockAchievement(prefix + 2);
    if (clearedZones >= 3) await unlockAchievement(prefix + 3);
  }

  /// Unlock a special achievement by title
  /// Mapped to fixed IDs:
  /// Perfect Scholar: 88881
  /// Speed Demon: 88882
  /// Star Collector: 88883
  Future<void> unlockSpecialAchievement(String type) async {
    int id;
    switch (type) {
      case 'Perfect Scholar':
        id = 88881;
        break;
      case 'Speed Demon':
        id = 88882;
        break;
      case 'Star Collector':
        id = 88883;
        break;
      default:
        return;
    }
    await unlockAchievement(id);
  }

  // ============ ECONOMY ============

  static const String _keyOwnedItems = 'owned_items';

  /// Get set of owned item IDs
  Set<String> get ownedItems {
    final itemsList = _prefs?.getStringList(_keyOwnedItems);
    return itemsList?.toSet() ?? {'default_outfit', 'default_hair'};
  }

  /// Check if an item is owned
  bool isItemOwned(String itemId) {
    return ownedItems.contains(itemId);
  }

  /// Purchase an item
  /// Returns true if successful, false if not enough gems
  Future<bool> purchaseItem(String itemId, int cost) async {
    if (isItemOwned(itemId)) return true;

    if (totalGems >= cost) {
      await setTotalGems(totalGems - cost);

      final currentItems = ownedItems;
      currentItems.add(itemId);
      await _prefs?.setStringList(_keyOwnedItems, currentItems.toList());
      return true;
    }
    return false;
  }

  // ============ ACHIEVEMENTS ============

  static const String _keyUnlockedAchievements = 'unlocked_achievements';

  /// Get set of unlocked achievement IDs
  Set<int> get unlockedAchievementIds {
    final ids = _prefs?.getStringList(_keyUnlockedAchievements);
    return ids?.map((id) => int.parse(id)).toSet() ?? {};
  }

  /// Check if achievement is unlocked
  bool isAchievementUnlocked(int id) {
    return unlockedAchievementIds.contains(id);
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(int id) async {
    if (!isAchievementUnlocked(id)) {
      final currentIds = unlockedAchievementIds;
      currentIds.add(id);
      await _prefs?.setStringList(
        _keyUnlockedAchievements,
        currentIds.map((e) => e.toString()).toList(),
      );
    }
  }

  // ============ RESET ============

  /// Reset all progress (for new game)
  Future<void> resetAllProgress() async {
    await _prefs?.setInt(_keyCurrentLevel, defaultLevel);
    await _prefs?.setInt(_keyTotalGems, defaultGems);
    await _prefs?.setInt(_keyTotalXP, defaultXP);
    await _prefs?.setInt(_keyHintsAvailable, defaultHints);
    await _prefs?.setBool(_keyHasSavedProgress, false);
    await _prefs?.remove(_keyCurrentProgram);
    await _prefs?.remove(_keyPowerUps);
    await _prefs?.remove(_keyPlayerName);
    await _prefs?.remove(_keyCharacterAvatar);
    await _prefs?.remove(_keyOwnedItems);
    await _prefs?.remove(_keyUnlockedAchievements);

    // Clear all program progress
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith(_keyLevelProgress)) {
        await _prefs?.remove(key);
      }
    }
  }

  /// Reset progress for a specific program
  Future<void> resetProgramProgress(String programId) async {
    await _prefs?.remove('${_keyLevelProgress}_$programId');
  }
}

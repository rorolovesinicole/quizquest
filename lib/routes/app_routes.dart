import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/program_selection_screen/program_selection_screen.dart';
import '../presentation/game_world_map_screen/game_world_map_screen.dart';
import '../presentation/level_complete_screen/level_complete_screen.dart';
import '../presentation/quiz_gameplay_screen/quiz_gameplay_screen.dart';
import '../presentation/pause_menu_screen/pause_menu_screen.dart';
import '../presentation/main_menu_screen/main_menu_screen.dart';
import '../presentation/achievement_gallery/achievement_gallery.dart';
import '../presentation/progress_analytics/progress_analytics.dart';
import '../presentation/character_customization/character_customization.dart';
import '../presentation/program_certificate/program_certificate.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String programSelection = '/program-selection-screen';
  static const String gameWorldMap = '/game-world-map-screen';
  static const String levelComplete = '/level-complete-screen';
  static const String quizGameplay = '/quiz-gameplay-screen';
  static const String pauseMenu = '/pause-menu-screen';
  static const String mainMenu = '/main-menu-screen';
  static const String achievementGallery = '/achievement-gallery';
  static const String progressAnalytics = '/progress-analytics';
  static const String characterCustomization = '/character-customization';
  static const String programCertificate = '/program-certificate';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    programSelection: (context) => const ProgramSelectionScreen(),
    gameWorldMap: (context) => const GameWorldMapScreen(),
    levelComplete: (context) => const LevelCompleteScreen(),
    quizGameplay: (context) => const QuizGameplayScreen(),
    pauseMenu: (context) => const PauseMenuScreen(),
    mainMenu: (context) => const MainMenuScreen(),
    achievementGallery: (context) => const AchievementGallery(),
    progressAnalytics: (context) => const ProgressAnalytics(),
    characterCustomization: (context) => const CharacterCustomization(),
    programCertificate: (context) => const ProgramCertificate(),
  };
}

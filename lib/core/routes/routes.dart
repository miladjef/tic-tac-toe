import 'package:flutter/material.dart';
import 'package:tic_tac_toe/screens/auth/auth_options_screen.dart';
import 'package:tic_tac_toe/screens/auth/email_login_screen.dart';
import 'package:tic_tac_toe/screens/auth/email_signup_screen.dart';
import 'package:tic_tac_toe/screens/game/connection_screen.dart';
import 'package:tic_tac_toe/screens/game/maze_screen.dart';
import 'package:tic_tac_toe/screens/history/history_screen.dart';
import 'package:tic_tac_toe/screens/home/home_screen.dart';
import 'package:tic_tac_toe/screens/leaderboard/leaderboard_screen.dart';
import 'package:tic_tac_toe/screens/more_games/game_webview_screen.dart';
import 'package:tic_tac_toe/screens/more_games/more_games_screen.dart';
import 'package:tic_tac_toe/screens/settings/how_to_play_screen.dart';
import 'package:tic_tac_toe/screens/settings/legal_info_screen.dart';
import 'package:tic_tac_toe/screens/settings/settings_screen.dart';
import 'package:tic_tac_toe/screens/shop/shop_screen.dart';
import 'package:tic_tac_toe/screens/skins/skins_screen.dart';
import 'package:tic_tac_toe/screens/splash_screen.dart';

abstract class AppRoutes {
  static const String splashScreen = '/';
  static const String authOptionsScreen = '/auth-options';
  static const String emailLoginScreen = '/email-login';
  static const String emailSignupScreen = '/email-signup';
  static const String connectionScreen = '/multiplayer-connection';
  static const String mazeScreen = '/game-maze';
  static const String homeScreen = '/home';
  static const String skinsScreen = '/skins';
  static const String settingsScreen = '/settings';
  static const String historyScreen = '/history';
  static const String leaderboardScreen = '/leaderboard';
  static const String shopScreen = '/shop';
  static const String moreGamesScreen = '/more-games';
  static const String gameWebViewScreen = '/game-webview';
  static const String legalInfoScreen = '/legal-info';
  static const String howToPlayScreen = '/how-to-play';

  static Route onGeneratedRoutes(RouteSettings settings) {
    if (settings.name == splashScreen) {
      return SplashScreen.route(settings);
    }
    if (settings.name == authOptionsScreen) {
      return AuthOptionsScreen.route(settings);
    }
    if (settings.name == emailLoginScreen) {
      return EmailLoginScreen.route(settings);
    }
    if (settings.name == emailSignupScreen) {
      return EmailSignupScreen.route(settings);
    }
    if (settings.name == homeScreen) {
      return HomeScreen.route(settings);
    }
    if (settings.name == connectionScreen) {
      return ConnectionScreen.route(settings);
    }
    if (settings.name == mazeScreen) {
      return MazeScreen.route(settings);
    }
    if (settings.name == skinsScreen) {
      return SkinsScreen.route(settings);
    }
    if (settings.name == settingsScreen) {
      return SettingsScreen.route(settings);
    }
    if (settings.name == historyScreen) {
      return HistoryScreen.route(settings);
    }
    if (settings.name == leaderboardScreen) {
      return LeaderboardScreen.route(settings);
    }
    if (settings.name == shopScreen) {
      return ShopScreen.route(settings);
    }
    if (settings.name == moreGamesScreen) {
      return MoreGamesScreen.route(settings);
    }
    if (settings.name == gameWebViewScreen) {
      return GameWebViewScreen.route(settings);
    }
    if (settings.name == legalInfoScreen) {
      return LegalInfoScreen.route(settings);
    }
    if (settings.name == howToPlayScreen) {
      return HowToPlayScreen.route(settings);
    }
    assert(false, 'No route defined for ${settings.name}');
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../pages/library/library_page.dart';
import '../pages/player/player_page.dart';
import '../pages/settings/privacy_policy_page.dart';
import '../pages/settings/settings_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String library = '/';
  static const String player = '/player';
  static const String settings = '/settings';
  static const String privacy = '/settings/privacy';

  static Route<void> onGenerateRoute(RouteSettings routeSettings) {
    final page = switch (routeSettings.name) {
      library => const LibraryPage(),
      player => const PlayerPage(),
      settings => const SettingsPage(),
      privacy => const PrivacyPolicyPage(),
      _ => const LibraryPage(),
    };

    return MaterialPageRoute<void>(
      builder: (_) => page,
      settings: routeSettings,
    );
  }
}

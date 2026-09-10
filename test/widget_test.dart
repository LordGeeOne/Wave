import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:wave/app/app_routes.dart';
import 'package:wave/pages/player/player_page.dart';
import 'package:wave/theme/app_theme.dart';
import 'package:wave/widgets/app_icon_button.dart';

void main() {
  testWidgets('uses the bundled dark Manrope theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Text('Wave')),
      ),
    );

    final context = tester.element(find.text('Wave'));
    final theme = Theme.of(context);

    expect(theme.brightness, Brightness.dark);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Manrope');
  });

  testWidgets('settings opens the privacy policy as a page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        initialRoute: AppRoutes.settings,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(find.text('Your library stays yours.'), findsOneWidget);
  });

  testWidgets('icon controls keep an accessible touch target', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: AppIconButton(
            icon: LucideIcons.play,
            label: 'Play',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppIconButton)), const Size(56, 56));
    expect(find.bySemanticsLabel('Play'), findsOneWidget);
  });

  testWidgets('player fits a narrow short screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const PlayerPage()),
    );

    expect(find.text('Now playing'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

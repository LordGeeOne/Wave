import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_routes.dart';
import '../widgets/app_grain_overlay.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WAVE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.library,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [child ?? const SizedBox.shrink(), const AppGrainOverlay()],
        );
      },
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppGrainOverlay extends StatelessWidget {
  const AppGrainOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(painter: _AppGrainPainter(), child: SizedBox.expand()),
    );
  }
}

class _AppGrainPainter extends CustomPainter {
  const _AppGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final area = size.width * size.height;
    final dotCount = math.max(520, (area / 1800).round());
    final seed = math.max(
      1,
      size.width.round() * 37 + size.height.round() * 13,
    );
    final random = math.Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var index = 0; index < dotCount; index++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.25 + random.nextDouble() * 0.85;
      final isLight = random.nextBool();
      paint.color = isLight
          ? AppColors.highlight.withValues(
              alpha: 0.06 + random.nextDouble() * 0.02,
            )
          : AppColors.shadow.withValues(
              alpha: 0.05 + random.nextDouble() * 0.02,
            );
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AppGrainPainter oldDelegate) => false;
}

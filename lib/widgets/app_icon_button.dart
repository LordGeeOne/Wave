import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

enum AppIconButtonStyle { flat, raised, active, primary }

class AppIconButton extends StatefulWidget {
  const AppIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
    this.style = AppIconButtonStyle.raised,
    this.iconSize = 22,
    this.recessedInner = false,
    this.size = 56,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final AppIconButtonStyle style;
  final double iconSize;
  final bool recessedInner;
  final double size;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final isActive =
        widget.style == AppIconButtonStyle.active ||
        widget.style == AppIconButtonStyle.primary;
    if (isActive) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AppIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasActive =
        oldWidget.style == AppIconButtonStyle.active ||
        oldWidget.style == AppIconButtonStyle.primary;
    final isActive =
        widget.style == AppIconButtonStyle.active ||
        widget.style == AppIconButtonStyle.primary;
    if (isActive && !wasActive) {
      _glowController.repeat(reverse: true);
    } else if (!isActive && wasActive) {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.style == AppIconButtonStyle.primary;
    final isActive = widget.style == AppIconButtonStyle.active;
    final isRaised = widget.style != AppIconButtonStyle.flat;
    final reverseInnerLight =
        ((isPrimary || isActive) && !widget.recessedInner) ||
        (_isPressed && isPrimary);
    final outerColor = isRaised ? AppColors.surface : AppColors.canvas;
    final List<BoxShadow> outerShadows = isRaised
        ? _isPressed
              ? AppShadows.rubberButtonPressed
              : AppShadows.rubberButton
        : const <BoxShadow>[];

    final baseIconColor = widget.onPressed == null
        ? AppColors.textMuted
        : isPrimary || isActive
        ? AppColors.accent
        : AppColors.textSecondary;

    final iconColor = (isPrimary || isActive)
        ? Color.lerp(
            baseIconColor,
            baseIconColor.withValues(alpha: 0.5),
            _glowController.value,
          )!
        : baseIconColor;

    return Semantics(
      button: true,
      label: widget.label,
      enabled: widget.onPressed != null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        width: widget.size,
        height: widget.size,
        transform: Matrix4.translationValues(
          _isPressed && isRaised ? 2 : 0,
          _isPressed && isRaised ? 2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: _isPressed && isRaised ? AppColors.surfacePressed : outerColor,
          shape: BoxShape.circle,
          boxShadow: outerShadows,
        ),
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: widget.onPressed == null
                ? null
                : (value) => setState(() => _isPressed = value),
            customBorder: const CircleBorder(),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: CustomPaint(
              painter: _InnerNeomorphicCirclePainter(
                reverseLight: reverseInnerLight,
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InnerNeomorphicCirclePainter extends CustomPainter {
  const _InnerNeomorphicCirclePainter({required this.reverseLight});

  final bool reverseLight;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final circle = Path()..addOval(bounds);
    final begin = reverseLight ? Alignment.topLeft : Alignment.bottomRight;
    final end = reverseLight ? Alignment.bottomRight : Alignment.topLeft;

    final darkest = Color.lerp(AppColors.canvas, AppColors.recessed, 0.18)!;
    final mid = Color.lerp(AppColors.canvas, AppColors.highlight, 0.16)!;

    canvas.save();
    canvas.clipPath(circle);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: [darkest, mid, AppColors.highlight.withValues(alpha: 0.6)],
          stops: const [0, 0.52, 1],
        ).createShader(bounds),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InnerNeomorphicCirclePainter oldDelegate) {
    return reverseLight != oldDelegate.reverseLight;
  }
}

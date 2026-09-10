import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_spacing.dart';
import 'app_icon_button.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    super.key,
    this.onBack,
    this.backLabel,
    this.actions = const [],
  });

  final String title;
  final VoidCallback? onBack;
  final String? backLabel;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            AppIconButton(
              icon: LucideIcons.arrowLeft,
              label: backLabel ?? 'Back',
              style: AppIconButtonStyle.raised,
              onPressed: onBack,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          for (var index = 0; index < actions.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.xs),
            actions[index],
          ],
        ],
      ),
    );
  }
}

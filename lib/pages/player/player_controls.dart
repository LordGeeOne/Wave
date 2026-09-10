import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/playback_manager.dart';
import '../../widgets/app_icon_button.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({required this.playback, super.key});

  final PlaybackManager playback;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 296,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppIconButton(
              icon: LucideIcons.skipBack,
              label: 'Previous track',
              style: AppIconButtonStyle.raised,
              iconSize: 26,
              size: 64,
              onPressed: playback.skipPrevious,
            ),
            SizedBox.square(
              dimension: 80,
              child: FittedBox(
                child: AppIconButton(
                  icon: playback.isPlaying
                      ? LucideIcons.pause
                      : LucideIcons.play,
                  label: playback.isPlaying ? 'Pause' : 'Play',
                  style: AppIconButtonStyle.primary,
                  iconSize: 32,
                  size: 80,
                  onPressed: playback.togglePlayPause,
                ),
              ),
            ),
            AppIconButton(
              icon: LucideIcons.skipForward,
              label: 'Next track',
              style: AppIconButtonStyle.raised,
              iconSize: 26,
              size: 64,
              onPressed: playback.skipNext,
            ),
          ],
        ),
      ),
    );
  }
}

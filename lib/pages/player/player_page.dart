import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/playback_manager.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_icon_button.dart';
import 'player_controls.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final _playback = PlaybackManager.instance;

  @override
  void initState() {
    super.initState();
    _playback.addListener(_refresh);
  }

  @override
  void dispose() {
    _playback.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _playback.duration.inMilliseconds > 0
        ? _playback.position.inMilliseconds / _playback.duration.inMilliseconds
        : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: AppIconButton(
                  icon: LucideIcons.arrowLeft,
                  label: 'Back to library',
                  style: AppIconButtonStyle.raised,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = math.min(constraints.maxWidth, 520.0);
                  final artworkSize = math.min(contentWidth - 64, 280.0);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          children: [
                            Container(
                              width: artworkSize,
                              height: artworkSize,
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.raised,
                              ),
                              child: const Center(
                                child: Icon(
                                  LucideIcons.disc3,
                                  size: 88,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppIconButton(
                                  icon: LucideIcons.shuffle,
                                  label: _playback.shuffle
                                      ? 'Disable shuffle'
                                      : 'Enable shuffle',
                                  style: _playback.shuffle
                                      ? AppIconButtonStyle.active
                                      : AppIconButtonStyle.raised,
                                  onPressed: _playback.toggleShuffle,
                                ),
                                AppIconButton(
                                  icon:
                                      _playback.repeatMode == WaveRepeatMode.one
                                      ? LucideIcons.repeat1
                                      : LucideIcons.repeat,
                                  label: switch (_playback.repeatMode) {
                                    WaveRepeatMode.off =>
                                      'Enable playlist repeat',
                                    WaveRepeatMode.playlist =>
                                      'Repeat current track',
                                    WaveRepeatMode.one => 'Disable repeat',
                                  },
                                  style:
                                      _playback.repeatMode == WaveRepeatMode.off
                                      ? AppIconButtonStyle.raised
                                      : AppIconButtonStyle.active,
                                  onPressed: _playback.toggleRepeat,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              _playback.currentTitle ?? 'Nothing playing',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _playback.currentArtist ?? 'Choose a track',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Slider(
                              value: progress.clamp(0, 1),
                              onChanged: _playback.duration == Duration.zero
                                  ? null
                                  : (value) => _playback.seekTo(
                                      Duration(
                                        milliseconds:
                                            (value *
                                                    _playback
                                                        .duration
                                                        .inMilliseconds)
                                                .round(),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_playback.position),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    _formatDuration(_playback.duration),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PlayerControls(playback: _playback),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

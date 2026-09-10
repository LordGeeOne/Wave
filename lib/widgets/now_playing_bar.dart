import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/playback_manager.dart';
import '../screens/player_screen.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({super.key});

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> {
  final _pm = PlaybackManager.instance;
  double? _top;
  double? _left;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _pm.addListener(_onPlaybackChanged);
  }

  @override
  void dispose() {
    _pm.removeListener(_onPlaybackChanged);
    super.dispose();
  }

  void _onPlaybackChanged() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_pm.hasTrack) {
      return const Positioned(top: 0, left: 0, child: SizedBox.shrink());
    }

    final screenSize = MediaQuery.of(context).size;

    // Default position: bottom of screen
    _top ??= screenSize.height - 290;
    _left ??= 0;

    final progress = _pm.duration.inMilliseconds > 0
        ? _pm.position.inMilliseconds / _pm.duration.inMilliseconds
        : 0.0;

    final barContent = Container(
      width: screenSize.width - 24, // full width minus horizontal margin
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _dragging ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                _pm.stop();
                setState(() {
                  _top = null;
                  _left = null;
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textDim,
                ),
              ),
            ),
          ),
          // Album art + Song info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pm.currentTitle ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _pm.currentArtist ?? 'Unknown Artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar with fixed-width time labels
          Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  _formatDuration(_pm.position),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: AppColors.textDim,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.cardBorder,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (v) {
                      final newPos = Duration(
                        milliseconds: (v * _pm.duration.inMilliseconds).round(),
                      );
                      _pm.seekTo(newPos);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  _formatDuration(_pm.duration),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: AppColors.textDim,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                icon: Icons.shuffle_rounded,
                size: 20,
                onTap: _pm.toggleShuffle,
                active: _pm.shuffle,
              ),
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                size: 26,
                onTap: _pm.skipPrevious,
              ),
              _ControlButton(
                icon: _pm.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 32,
                onTap: _pm.togglePlayPause,
                highlighted: true,
              ),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                size: 26,
                onTap: _pm.skipNext,
              ),
              _ControlButton(
                icon: _pm.repeatMode == WaveRepeatMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                size: 20,
                onTap: _pm.toggleRepeat,
                active: _pm.repeatMode != WaveRepeatMode.off,
              ),
            ],
          ),
        ],
      ),
    );

    return Positioned(
      top: _top!,
      left: _left! + 12, // 12px margin
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PlayerScreen()));
        },
        onLongPressStart: (_) => setState(() => _dragging = true),
        onLongPressMoveUpdate: (details) {
          setState(() {
            _top = _top! + details.localOffsetFromOrigin.dy - (_lastDy ?? 0);
            _left = _left! + details.localOffsetFromOrigin.dx - (_lastDx ?? 0);
            _lastDy = details.localOffsetFromOrigin.dy;
            _lastDx = details.localOffsetFromOrigin.dx;
          });
        },
        onLongPressEnd: (_) => setState(() {
          _dragging = false;
          _lastDy = null;
          _lastDx = null;
        }),
        child: Material(color: Colors.transparent, child: barContent),
      ),
    );
  }

  double? _lastDy;
  double? _lastDx;
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
    this.highlighted = false,
    this.active = false,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool highlighted;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: highlighted
            ? const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          size: size,
          color: highlighted
              ? AppColors.textPrimary
              : active
              ? AppColors.primary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/playback_manager.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _pm = PlaybackManager.instance;
  bool _showVolume = false;
  double _dragVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _pm.addListener(_update);
  }

  @override
  void dispose() {
    _pm.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _pm.duration.inMilliseconds > 0
        ? _pm.position.inMilliseconds / _pm.duration.inMilliseconds
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'NOW PLAYING',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDim,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Album art / hidden volume slider
              GestureDetector(
                onVerticalDragStart: (_) {
                  setState(() {
                    _showVolume = true;
                    _dragVolume = _pm.volume;
                  });
                },
                onVerticalDragUpdate: (details) {
                  setState(() {
                    // Swipe up = louder, swipe down = quieter
                    _dragVolume = (_dragVolume - details.delta.dy / 260).clamp(
                      0.0,
                      1.0,
                    );
                    _pm.setVolume(_dragVolume);
                  });
                },
                onVerticalDragEnd: (_) {
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) setState(() => _showVolume = false);
                  });
                },
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Music note icon
                      Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          color: AppColors.primary.withValues(alpha: 0.4),
                          size: 80,
                        ),
                      ),
                      // Volume overlay (only visible when swiping)
                      if (_showVolume)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _dragVolume == 0
                                      ? Icons.volume_off_rounded
                                      : _dragVolume < 0.5
                                      ? Icons.volume_down_rounded
                                      : Icons.volume_up_rounded,
                                  color: AppColors.textPrimary,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                // Volume bar
                                Container(
                                  width: 4,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBorder,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: _dragVolume,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(_dragVolume * 100).round()}%',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Song title
              Text(
                _pm.currentTitle ?? 'Unknown',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              // Artist
              Text(
                _pm.currentArtist ?? 'Unknown Artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppColors.textDim,
                ),
              ),
              const SizedBox(height: 32),
              // Progress slider
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.cardBorder,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) {
                    _pm.seekTo(
                      Duration(
                        milliseconds: (v * _pm.duration.inMilliseconds).round(),
                      ),
                    );
                  },
                ),
              ),
              // Time labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fmt(_pm.position),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppColors.textDim,
                      ),
                    ),
                    Text(
                      _fmt(_pm.duration),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn(
                    icon: Icons.shuffle_rounded,
                    size: 24,
                    onTap: _pm.toggleShuffle,
                    active: _pm.shuffle,
                  ),
                  _btn(
                    icon: Icons.skip_previous_rounded,
                    size: 36,
                    onTap: _pm.skipPrevious,
                  ),
                  // Play / Pause (large)
                  GestureDetector(
                    onTap: _pm.togglePlayPause,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _pm.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _btn(
                    icon: Icons.skip_next_rounded,
                    size: 36,
                    onTap: _pm.skipNext,
                  ),
                  _btn(
                    icon: _pm.repeatMode == WaveRepeatMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    size: 24,
                    onTap: _pm.toggleRepeat,
                    active: _pm.repeatMode != WaveRepeatMode.off,
                  ),
                ],
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: size,
        color: active ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

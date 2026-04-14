import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_colors.dart';
import 'screens/settings/settings_screen.dart';
import 'services/playback_manager.dart';
import 'widgets/now_playing_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PlaybackManager.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomePage(),
    );
  }
}

/// Simple model for a discovered audio file.
class AudioFile {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String path;
  final String uri;

  AudioFile({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.path,
    required this.uri,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _channel = MethodChannel('com.example.wave/audio');

  List<AudioFile> _songs = [];
  bool _loading = true;
  bool _permissionDenied = false;
  int _scanCount = 0;
  bool _scanDone = false;
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoad();
    PlaybackManager.instance.addListener(_onPlaybackChanged);
  }

  @override
  void dispose() {
    PlaybackManager.instance.removeListener(_onPlaybackChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onPlaybackChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _requestPermissionAndLoad() async {
    bool granted = false;

    // Android 13+ uses READ_MEDIA_AUDIO, older uses READ_EXTERNAL_STORAGE
    if (await Permission.audio.request().isGranted) {
      granted = true;
    } else if (await Permission.storage.request().isGranted) {
      granted = true;
    }

    if (granted) {
      await _loadSongs();
    } else {
      setState(() {
        _permissionDenied = true;
        _loading = false;
      });
    }
  }

  Future<void> _loadSongs() async {
    setState(() {
      _scanCount = 0;
      _scanDone = false;
    });

    try {
      final List<dynamic> result = await _channel.invokeMethod('getAudioFiles');
      final songs = result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return AudioFile(
          id: (map['id'] as num).toInt(),
          title:
              map['title'] as String? ??
              map['displayName'] as String? ??
              'Unknown',
          artist: map['artist'] as String? ?? 'Unknown Artist',
          album: map['album'] as String? ?? 'Unknown Album',
          duration: (map['duration'] as num?)?.toInt() ?? 0,
          path: map['path'] as String? ?? '',
          uri: map['uri'] as String? ?? '',
        );
      }).toList();

      setState(() {
        _scanCount = songs.length;
        _scanDone = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _songs = songs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _scanDone = true;
        _scanCount = 0;
        _loading = false;
      });
    }
  }

  String _formatDuration(int millis) {
    if (millis == 0) return '--:--';
    final duration = Duration(milliseconds: millis);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: AppColors.textDim,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text(
                'Wave',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, size: 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _JumpingDots(),
            const SizedBox(height: 20),
            Text(
              _scanDone ? 'Found $_scanCount songs' : 'Scanning for music...',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _scanDone
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            if (!_scanDone && _scanCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$_scanCount found so far',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppColors.textDim,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_off_rounded,
                size: 80,
                color: AppColors.textDim,
              ),
              const SizedBox(height: 16),
              Text(
                'Storage permission required',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Grant permission to scan for music',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppColors.textDim,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _loading = true;
                    _permissionDenied = false;
                  });
                  _requestPermissionAndLoad();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Grant Permission',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note_rounded,
              size: 80,
              color: AppColors.textDim,
            ),
            const SizedBox(height: 16),
            Text(
              'No music found',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No audio files on this device',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.textDim,
              ),
            ),
          ],
        ),
      );
    }

    final filteredSongs = _searchQuery.isEmpty
        ? _songs
        : _songs.where((s) {
            final q = _searchQuery.toLowerCase();
            return s.title.toLowerCase().contains(q) ||
                s.artist.toLowerCase().contains(q) ||
                s.album.toLowerCase().contains(q);
          }).toList();

    if (filteredSongs.isEmpty) {
      return Center(
        child: Text(
          'No results for "$_searchQuery"',
          style: GoogleFonts.montserrat(fontSize: 15, color: AppColors.textDim),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: filteredSongs.length,
          itemBuilder: (context, index) {
            final song = filteredSongs[index];
            return _SongTile(
              title: song.title,
              artist: song.artist,
              duration: _formatDuration(song.duration),
              isPlaying:
                  PlaybackManager.instance.currentPath == song.path &&
                  PlaybackManager.instance.isPlaying,
              onTap: () {
                final queueSongs = filteredSongs
                    .map(
                      (s) => {
                        'title': s.title,
                        'artist': s.artist,
                        'path': s.path,
                      },
                    )
                    .toList();
                PlaybackManager.instance.playFromQueue(
                  songs: queueSongs,
                  index: index,
                );
              },
            );
          },
        ),
        const NowPlayingBar(),
      ],
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({
    required this.title,
    required this.artist,
    required this.duration,
    this.isPlaying = false,
    this.onTap,
  });

  final String title;
  final String artist;
  final String duration;
  final bool isPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isPlaying
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPlaying ? Icons.equalizer_rounded : Icons.music_note_rounded,
                color: isPlaying ? AppColors.primary : AppColors.textDim,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              duration,
              style: const TextStyle(fontSize: 12, color: AppColors.textDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _JumpingDots extends StatefulWidget {
  const _JumpingDots();

  @override
  State<_JumpingDots> createState() => _JumpingDotsState();
}

class _JumpingDotsState extends State<_JumpingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(
        begin: 0,
        end: -12,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        _controllers[i].forward().then((_) {
          if (mounted) _controllers[i].reverse();
        });
      }
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, _animations[i].value),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

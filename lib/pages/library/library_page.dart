import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_routes.dart';
import '../../models/audio_file.dart';
import '../../services/playback_manager.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/page_header.dart';
import 'library_states.dart';
import 'song_tile.dart';

enum LibraryStatus { loading, ready, permissionDenied, failed }

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  static const _channel = MethodChannel('com.example.wave/audio');

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<AudioFile> _songs = const [];
  LibraryStatus _status = LibraryStatus.loading;
  String _searchQuery = '';
  bool _showSearch = false;
  bool _showHeader = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _requestPermissionAndLoad();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    final shouldShow = delta <= 0;

    if (shouldShow != _showHeader) {
      setState(() => _showHeader = shouldShow);
    }
    _lastScrollOffset = offset;
  }

  Future<void> _requestPermissionAndLoad() async {
    if (mounted) {
      setState(() => _status = LibraryStatus.loading);
    }

    final audioGranted = await Permission.audio.request().isGranted;
    final storageGranted =
        audioGranted || await Permission.storage.request().isGranted;
    if (!mounted) return;

    if (!storageGranted) {
      setState(() => _status = LibraryStatus.permissionDenied);
      return;
    }

    await _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getAudioFiles',
      );
      final songs = (result ?? const [])
          .map(
            (item) => AudioFile.fromPlatformMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _songs = songs;
        _status = LibraryStatus.ready;
      });
    } on PlatformException catch (error) {
      debugPrint('Audio scan failed: ${error.message}');
      if (mounted) {
        setState(() => _status = LibraryStatus.failed);
      }
    } on MissingPluginException catch (error) {
      debugPrint('Audio scanning is unavailable: $error');
      if (mounted) {
        setState(() => _status = LibraryStatus.failed);
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  List<AudioFile> get _filteredSongs {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _songs;
    return _songs
        .where(
          (song) =>
              song.title.toLowerCase().contains(query) ||
              song.artist.toLowerCase().contains(query) ||
              song.album.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: _showHeader ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showHeader ? null : 0,
                child: PageHeader(
                  title: 'WAVE',
                  actions: [
                    AppIconButton(
                      icon: _showSearch ? LucideIcons.x : LucideIcons.search,
                      label: _showSearch ? 'Close search' : 'Search library',
                      style: AppIconButtonStyle.raised,
                      onPressed: _toggleSearch,
                    ),
                    AppIconButton(
                      icon: LucideIcons.settings,
                      label: 'Open settings',
                      style: AppIconButtonStyle.raised,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _showSearch
                  ? Padding(
                      key: const ValueKey('search'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: 'Search songs, artists, or albums',
                          filled: false,
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.outline),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      LibraryStatus.loading => const LibraryLoadingState(),
      LibraryStatus.permissionDenied => LibraryMessageState(
        icon: LucideIcons.folderX,
        title: 'Music access is required',
        message: 'Allow access so WAVE can find audio stored on this device.',
        actionLabel: 'Grant access',
        onAction: _requestPermissionAndLoad,
      ),
      LibraryStatus.failed => LibraryMessageState(
        icon: LucideIcons.circleAlert,
        title: 'Library scan failed',
        message: 'WAVE could not read the audio library. Try scanning again.',
        actionLabel: 'Scan again',
        onAction: _loadSongs,
      ),
      LibraryStatus.ready => _buildReadyContent(),
    };
  }

  Widget _buildReadyContent() {
    if (_songs.isEmpty) {
      return const LibraryMessageState(
        icon: LucideIcons.listMusic,
        title: 'No music found',
        message: 'Add audio files to this device, then scan again.',
      );
    }

    final filteredSongs = _filteredSongs;
    if (filteredSongs.isEmpty) {
      return LibraryMessageState(
        icon: LucideIcons.searchX,
        title: 'No matches',
        message: 'Nothing in your library matches “$_searchQuery”.',
      );
    }

    return AnimatedBuilder(
      animation: PlaybackManager.instance,
      builder: (context, _) {
        final playback = PlaybackManager.instance;
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          itemCount: filteredSongs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxs,
                  AppSpacing.sm,
                  AppSpacing.xxs,
                  AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your library',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Music stored on this device',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${filteredSongs.length} tracks',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              );
            }

            final songIndex = index - 1;
            final song = filteredSongs[songIndex];
            return SongTile(
              song: song,
              isActive: playback.currentPath == song.path,
              isPlaying:
                  playback.currentPath == song.path && playback.isPlaying,
              onTap: () {
                unawaited(
                  playback.playFromQueue(
                    songs: filteredSongs
                        .map((item) => item.toQueueItem())
                        .toList(growable: false),
                    index: songIndex,
                  ),
                );
                Navigator.pushNamed(context, AppRoutes.player);
              },
            );
          },
        );
      },
    );
  }
}

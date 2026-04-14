import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum WaveRepeatMode { off, playlist, one }

class PlaybackManager extends ChangeNotifier {
  PlaybackManager._();
  static final PlaybackManager instance = PlaybackManager._();

  final AudioPlayer _player = AudioPlayer();

  String? _currentTitle;
  String? _currentArtist;
  String? _currentPath;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  List<Map<String, dynamic>> _queue = [];
  int _currentIndex = -1;
  bool _shuffle = false;
  WaveRepeatMode _repeatMode = WaveRepeatMode.off;
  double _volume = 1.0;

  String? get currentTitle => _currentTitle;
  String? get currentArtist => _currentArtist;
  String? get currentPath => _currentPath;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get hasTrack => _currentPath != null;
  List<Map<String, dynamic>> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get shuffle => _shuffle;
  WaveRepeatMode get repeatMode => _repeatMode;
  double get volume => _volume;

  /// Call once at app start.
  void init() {
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (_repeatMode == WaveRepeatMode.one) {
          _player.seek(Duration.zero);
          _player.play();
        } else if (_repeatMode == WaveRepeatMode.playlist) {
          skipNext();
        } else {
          // RepeatMode.off — stop at end of queue
          if (_currentIndex < _queue.length - 1) {
            skipNext();
          }
        }
      }
      notifyListeners();
    });
  }

  /// Set the full queue and start playing at [index].
  Future<void> playFromQueue({
    required List<Map<String, dynamic>> songs,
    required int index,
  }) async {
    _queue = songs;
    _currentIndex = index;
    await _playCurrent();
  }

  /// Play a single song (sets a queue of one).
  Future<void> play({
    required String title,
    required String artist,
    required String path,
  }) async {
    _queue = [
      {'title': title, 'artist': artist, 'path': path},
    ];
    _currentIndex = 0;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;

    final song = _queue[_currentIndex];
    _currentTitle = song['title'] as String?;
    _currentArtist = song['artist'] as String?;
    _currentPath = song['path'] as String?;
    notifyListeners();

    try {
      await _player.setFilePath(_currentPath!);
      await _player.play();
    } catch (e) {
      debugPrint('Playback error: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    if (_shuffle) {
      _currentIndex =
          (List.generate(_queue.length, (i) => i)
                ..remove(_currentIndex)
                ..shuffle())
              .first;
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    await _playCurrent();
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    // If more than 3 seconds in, restart current song
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await _playCurrent();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case WaveRepeatMode.off:
        _repeatMode = WaveRepeatMode.playlist;
        break;
      case WaveRepeatMode.playlist:
        _repeatMode = WaveRepeatMode.one;
        break;
      case WaveRepeatMode.one:
        _repeatMode = WaveRepeatMode.off;
        break;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentTitle = null;
    _currentArtist = null;
    _currentPath = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isPlaying = false;
    _queue = [];
    _currentIndex = -1;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

class AudioFile {
  const AudioFile({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.path,
    required this.uri,
  });

  factory AudioFile.fromPlatformMap(Map<String, dynamic> map) {
    return AudioFile(
      id: (map['id'] as num).toInt(),
      title:
          map['title'] as String? ?? map['displayName'] as String? ?? 'Unknown',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? 'Unknown Album',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      path: map['path'] as String? ?? '',
      uri: map['uri'] as String? ?? '',
    );
  }

  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String path;
  final String uri;

  Map<String, dynamic> toQueueItem() {
    return {'title': title, 'artist': artist, 'path': path};
  }
}

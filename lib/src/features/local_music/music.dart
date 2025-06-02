import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

import '../../../main.dart';

class MusicScreen extends StatefulWidget {
  static const String routeName = '/music';

  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  AudioPlayer audioPlayer = AudioPlayer();

  Future<bool> requestPermissions() async {
    // final storage = await Permission.storage.request();
    //
    //
    // final mediaLibrary = await Permission.mediaLibrary.request();
    final status = await _audioQuery.checkAndRequest();

    print('status permission: ${status}');
    if (!status) {
      // Show rationale or retry
      return false;
    }
    return true;
  }

  Future<List<SongModel>> fetchSongs() async {
    // Ensure permissions are granted first
    if (!await requestPermissions()) return [];

    // Query all songs, sorted by display name
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.DISPLAY_NAME,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL, // external storage
    );

    audioHandler.addQueueItems(
      songs.map((song) {
        return MediaItem(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist,
          extras: {
            'uri': song.uri,
          },
        );
      }).toList(),
    );

    return songs;
  }

  late Future<List<SongModel>> _songsFuture;

  @override
  void initState() {
    super.initState();
    /// init audio service

    _songsFuture = fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _songsFuture = fetchSongs();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              PlayerStateWidget(),
              const SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder<List<SongModel>>(
                  future: _songsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final songs = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return ListTile(
                          leading: QueryArtworkWidget(
                            // album art
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(Icons.music_note),
                          ),
                          title: Text(song.title),
                          subtitle: Text(song.artist ?? "Unknown Artist"),
                          onTap: () {
                            /// play this song from the list of queue
                            /// using the audio service
                            audioHandler.playMediaItem(
                              MediaItem(
                                id: song.id.toString(),
                                title: song.title,
                                artist: song.artist,
                                displayTitle: song.title,
                                displaySubtitle: song.artist,
                                extras: {
                                  'uri': song.uri,
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerStateWidget extends StatelessWidget {

  const PlayerStateWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show media item title
          StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;
              return Text(mediaItem?.title ?? '');
            },
          ),
          // Play/pause/stop buttons.
          StreamBuilder<bool>(
            stream: audioHandler.playbackState
                .map((state) => state.playing)
                .distinct(),
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _button(Icons.skip_previous, audioHandler.skipToPrevious),
                  if (playing)
                    _button(Icons.pause, audioHandler.pause)
                  else
                    _button(Icons.play_arrow, audioHandler.play),
                  _button(Icons.stop, audioHandler.stop),
                  _button(Icons.skip_next, audioHandler.skipToNext),
                ],
              );
            },
          ),
          // A seek bar.
          StreamBuilder<MediaState>(
            stream: _mediaStateStream,
            builder: (context, snapshot) {
              final mediaState = snapshot.data;
              return SeekBar(
                duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                position: mediaState?.position ?? Duration.zero,
                onChangeEnd: (newPosition) {
                  audioHandler.seek(newPosition);
                },
              );
            },
          ),
          // Display the processing state.
          StreamBuilder<AudioProcessingState>(
            stream: audioHandler.playbackState
                .map((state) => state.processingState)
                .distinct(),
            builder: (context, snapshot) {
              final processingState =
                  snapshot.data ?? AudioProcessingState.idle;
              return Text(
                // ignore: deprecated_member_use
                  "Processing state: ${describeEnum(processingState)}");
            },
          ),
        ],
      ),
    );
  }

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler.mediaItem,
          AudioService.position,
              (mediaItem, position) => MediaState(mediaItem, position));

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
    icon: Icon(iconData),
    iconSize: 64.0,
    onPressed: onPressed,
  );
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    // Broadcast playback state changes
    _player.playerStateStream.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
        playing: state.playing,
        processingState: state.processingState.toAudioProcessingState(),
        bufferedPosition: _player.bufferedPosition,
        updatePosition: _player.position,
      ));
    });

    // Broadcast current media item
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.length > index) {
        mediaItem.add(queue.value[index]);
      }
    });
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await _player.setUrl(mediaItem.extras!['uri']);
    play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}

extension on ProcessingState {
  AudioProcessingState toAudioProcessingState() {
    switch (this) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AudioProcessingState.loading;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {},
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: value,
            onChanged: (value) {
              if (!_dragging) {
                _dragging = true;
              }
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragging = false;
            },
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                  .firstMatch("$_remaining")
                  ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {}
}

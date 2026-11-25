
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PhraseAudioPlayer extends StatefulWidget {
  const PhraseAudioPlayer({
    super.key,
    required this.audioUrl,
    this.compact = false,
  });

  final String? audioUrl;
  final bool compact;

  @override
  State<PhraseAudioPlayer> createState() =>
      _PhraseAudioPlayerState();
}

class _PhraseAudioPlayerState extends State<PhraseAudioPlayer> {
  late final AudioPlayer _player;

  bool _isLoading = false;
  String? _error;

  static const Color primary = Color(0xFFB04491);
  static const Color textColor = Color(0xFF765E70);

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void didUpdateWidget(covariant PhraseAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.audioUrl != widget.audioUrl) {
      _player.stop();
      _error = null;
      _isLoading = false;
    }
  }

  Future<void> _togglePlayback() async {
    final url = widget.audioUrl;

    if (url == null || url.isEmpty) return;

    if (_player.playing) {
      await _player.pause();
      return;
    }

    setState(() {
      _error = null;
    });

    try {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }

      // Load the Contentful recording when necessary.
      if (_player.audioSource == null) {
        final uri = Uri.tryParse(url);

        if (uri == null ||
            uri.scheme != 'https' ||
            uri.host.isEmpty) {
          throw const FormatException(
            'Invalid audio recording URL.',
          );
        }

        setState(() {
          _isLoading = true;
        });

        await _player.setAudioSource(
          AudioSource.uri(uri),
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });
      }

      await _player.play();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Unable to play recording. Check your connection.';
      });

      debugPrint('Phrase audio playback error: $error');
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.volume_off_outlined,
          color: textColor,
        ),
        title: Text('Local-speaker recording'),
        subtitle: Text('Recording pending.'),
      );
    }

    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, playerSnapshot) {
        final playerState = playerSnapshot.data;
        final isPlaying = playerState?.playing ?? false;

        final isBuffering =
            _isLoading ||
            playerState?.processingState ==
                ProcessingState.loading ||
            playerState?.processingState ==
                ProcessingState.buffering;

        final isCompleted =
            playerState?.processingState ==
                ProcessingState.completed;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton.filled(
                  onPressed: isBuffering
                      ? null
                      : _togglePlayback,
                  style: IconButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: isBuffering
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause
                              : isCompleted
                                  ? Icons.replay
                                  : Icons.play_arrow,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Real local-speaker audio',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        isBuffering
                            ? 'Loading recording...'
                            : isPlaying
                                ? 'Playing recording...'
                                : 'Tap to listen',
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ??
                    Duration.zero;

                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position =
                        positionSnapshot.data ?? Duration.zero;

                    final maxMilliseconds =
                        duration.inMilliseconds.toDouble();

                    final currentMilliseconds = maxMilliseconds <= 0
                        ? 0.0
                        : position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, maxMilliseconds);

                    return Column(
                      children: [
                        Slider(
                          activeColor: primary,
                          inactiveColor: Colors.black12,
                          min: 0,
                          max: maxMilliseconds > 0
                              ? maxMilliseconds
                              : 1,
                          value: currentMilliseconds,
                          onChanged: maxMilliseconds <= 0
                              ? null
                              : (value) {
                                  _player.seek(
                                    Duration(
                                      milliseconds: value.round(),
                                    ),
                                  );
                                },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }
}
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PhraseAudioButton extends StatefulWidget {
  const PhraseAudioButton({
    super.key,
    required this.audioUrl,
    this.compact = false,
  });

  final String? audioUrl;
  final bool compact;

  @override
  State<PhraseAudioButton> createState() => _PhraseAudioButtonState();
}

class _PhraseAudioButtonState extends State<PhraseAudioButton> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant PhraseAudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _player.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _hasError = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    final url = widget.audioUrl;
    if (url == null || url.isEmpty) return;

    if (_isPlaying) {
      await _player.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await _player.play(UrlSource(url));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.audioUrl != null && widget.audioUrl!.isNotEmpty;
    final icon = _isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            _hasError
                ? Icons.replay
                : _isPlaying
                ? Icons.stop
                : Icons.volume_up_outlined,
            size: widget.compact ? 18 : 20,
          );

    if (widget.compact) {
      return IconButton(
        onPressed: available ? _togglePlayback : null,
        icon: icon,
        color: const Color(0xFFB04491),
        tooltip: available
            ? (_isPlaying ? 'Stop recording' : 'Play recording')
            : 'Recording pending',
      );
    }

    return TextButton.icon(
      onPressed: available ? _togglePlayback : null,
      icon: icon,
      label: Text(
        !available
            ? 'Recording pending'
            : _hasError
            ? 'Could not play recording'
            : _isPlaying
            ? 'Stop recording'
            : 'Play recording',
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFB04491),
        disabledForegroundColor: const Color(0xFF765E70),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

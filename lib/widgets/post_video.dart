import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostVideo extends StatefulWidget {
  const PostVideo({super.key, required this.url});

  final String url;

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initialization = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(child: Text('No se pudo cargar el video.')),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final ratio = _controller.value.aspectRatio;
      return Column(
        children: [
          AspectRatio(
            aspectRatio: ratio > 0 ? ratio : 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                VideoPlayer(_controller),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => IconButton.filledTonal(
                    onPressed: _togglePlayback,
                    iconSize: 38,
                    tooltip: value.isPlaying
                        ? 'Pausar video'
                        : 'Reproducir video',
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      );
    },
  );
}

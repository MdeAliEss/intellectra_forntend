import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Stack(
                    children: [
                      // The video fills the container.
                      Positioned.fill(
                        child: VideoPlayer(_controller),
                      ),
                      // Video progress indicator positioned at the bottom with padding.
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 20,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                        ),
                      ),
                      // Floating button positioned above the progress indicator.
                      Align(
                        alignment: Alignment.center,
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertical Video Player',
      home: VideoListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VideoListPage extends StatefulWidget {
  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  // Replace these URLs with valid direct video URLs.
  final List<String> videoUrls = [
    'https://www.example.com/video1.mp4',
    'https://www.example.com/video2.mp4',
    'https://www.example.com/video3.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return VideoPlayerWidget(
            videoUrl: videoUrls[index],
            isActive: index == currentPage,
          );
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isActive; // Indicates whether this video is currently in view.

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.isActive = false,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true; // State to control visibility of action buttons

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        // Auto-play if this widget is active on load.
        if (widget.isActive) {
          _controller.play();
        }
      });

    // Listen to video updates to trigger UI refreshes.
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the active state changes, play or pause accordingly.
    if (widget.isActive && !_controller.value.isPlaying) {
      _controller.play();
    } else if (!widget.isActive && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo() {
    _controller.play();
    setState(() {
      _showControls = false; // Hide controls when playing
    });
  }

  void _stopVideo() {
    _controller.pause();
    setState(() {
      _showControls = true; // Show controls when paused
    });
  }

  void _seekForward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition + Duration(seconds: 10);

    if (_isInitialized) {
      if (newPosition < _controller.value.duration) {
        _controller.seekTo(newPosition);
      } else {
        _controller.seekTo(
          _controller.value.duration,
        ); // Seek to the end if it exceeds
      }
    }
  }

  void _seekBackward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - Duration(seconds: 10);

    if (_isInitialized) {
      if (newPosition > Duration.zero) {
        _controller.seekTo(newPosition);
      } else {
        _controller.seekTo(Duration.zero); // Seek to the start if it goes below
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _showControls = true; // Show controls on hover
          });
        },
        onExit: (_) {
          if (_controller.value.isPlaying) {
            setState(() {
              _showControls =
                  false; // Hide controls when not hovering and playing
            });
          }
        },
        child: Stack(
          children: [
            if (_isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              const Center(child: CircularProgressIndicator()),
            if (_showControls) // Show controls only if _showControls is true
              Positioned(
                bottom: 100, // Adjust this value to move the buttons higher
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the buttons
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10, color: Colors.white),
                      onPressed: _seekBackward,
                    ),
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _stopVideo();
                          } else {
                            _playVideo();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.forward_10, color: Colors.white),
                      onPressed: _seekForward,
                    ),
                  ],
                ),
              ),
            // Progress Indicator
            Positioned(
              bottom: 0, // Keep the timeline at the bottom
              left: 0,
              right: 0,
              child: VideoProgressIndicator(_controller, allowScrubbing: true),
            ),
          ],
        ),
      ),
    );
  }
}

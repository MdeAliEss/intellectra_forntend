import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async'; // Import Timer

class VideoListPage extends StatefulWidget {
  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<String> videoUrls = [
    'https://www.example.com/video1.mp4', // Replace with actual URLs for testing
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
  final bool isActive;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.isActive = false,
  });

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _showControls = false; // State for controls visibility
  Timer? _hideControlsTimer; // Timer for auto-hiding controls

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller
        .initialize()
        .then((_) {
          setState(() {});
        })
        .catchError((error) {
          print("Video Initialization Error: $error");
          setState(() {});
        });

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  void _seekForward() {
    if (_controller.value.isInitialized) {
      final currentPosition = _controller.value.position;
      final newPosition = currentPosition + const Duration(seconds: 10);
      // Ensure seeking doesn't go beyond video duration
      if (newPosition < _controller.value.duration) {
        _controller.seekTo(newPosition);
      } else {
        _controller.seekTo(
          _controller.value.duration,
        ); // Seek to end if overshoot
      }
    }
  }

  void _seekBackward() {
    if (_controller.value.isInitialized) {
      final currentPosition = _controller.value.position;
      final newPosition = currentPosition - const Duration(seconds: 10);
      // Ensure seeking doesn't go before zero
      if (newPosition > Duration.zero) {
        _controller.seekTo(newPosition);
      } else {
        _controller.seekTo(Duration.zero); // Seek to beginning if overshoot
      }
    }
  }

  // Method to toggle controls and manage auto-hide
  void _toggleControls() {
    if (!_controller.value.isInitialized)
      return; // Don't show controls if not initialized

    setState(() {
      _showControls = true;
    });

    // Cancel any existing timer
    _hideControlsTimer?.cancel();

    // Start a new timer to hide controls after 3 seconds
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !_controller.value.hasError) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: GestureDetector(
                  // Add GestureDetector here
                  onTap: _toggleControls, // Call toggle method on tap
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      // Use AnimatedOpacity for controls
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: AbsorbPointer(
                          absorbing:
                              !_showControls, // Prevent interaction when hidden
                          child: _buildControlsOverlay(),
                        ),
                      ),
                      // Also wrap progress indicator with AnimatedOpacity
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: AbsorbPointer(
                          absorbing: !_showControls,
                          child: Padding(
                            // Add some padding to lift it above bottom edge
                            padding: const EdgeInsets.only(
                              bottom: 8.0,
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Colors.red,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError ||
                (_controller.value.isInitialized &&
                    _controller.value.hasError)) {
              // If there was an error during initialization or playback
              return AspectRatio(
                aspectRatio: 16 / 9, // Default aspect ratio for error display
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Could not load video',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        // Optionally show more detailed error: snapshot.error.toString()
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // Otherwise, display a loading indicator centered
              return AspectRatio(
                aspectRatio: 16 / 9, // Maintain aspect ratio during loading
                child: Container(
                  color: Colors.black, // Background color while loading
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  // Helper method for controls overlay
  Widget _buildControlsOverlay() {
    return Stack(
      children: <Widget>[
        // Optional: Add a subtle gradient or background for controls
        Container(
          // Example gradient for better visibility
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.0),
                Colors.black.withOpacity(0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Center Row for main controls (Play/Pause, Seek)
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Seek Backward Button
              IconButton(
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: _seekBackward,
              ),
              // Play/Pause Button (Animated)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 50),
                reverseDuration: const Duration(milliseconds: 200),
                child: IconButton(
                  key: ValueKey<bool>(
                    _controller.value.isPlaying,
                  ), // Key for animation
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 70.0,
                    semanticLabel:
                        _controller.value.isPlaying ? 'Pause' : 'Play',
                  ),
                  onPressed: () {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  },
                ),
              ),
              // Seek Forward Button
              IconButton(
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: _seekForward,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel(); // Cancel timer on dispose
    _initializeVideoPlayerFuture.then((_) => _controller.dispose());
    super.dispose();
  }
}

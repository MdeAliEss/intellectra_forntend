import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  bool _isInitialized = false;
  bool _showControls = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    print("Initializing video player for ${widget.videoUrl}");
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        print("Video player initialized for ${widget.videoUrl}");
        setState(() {
          _isInitialized = true;
        });
        if (widget.isActive) {
          print("Widget is active, playing video for ${widget.videoUrl}");
          _controller.play();
        }
      }).catchError((error) {
        setState(() {
          _hasError = true;
          _errorMessage = error.toString();
          print('Video Error for ${widget.videoUrl}: $_errorMessage');
        });
      });

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      print("Video URL changed from ${oldWidget.videoUrl} to ${widget.videoUrl}");
      _disposeVideoPlayer();
      _isInitialized = false;
      _hasError = false;
      _initializeVideoPlayer();
    }
    if (_isInitialized && !_hasError) {
      if (widget.isActive && !_controller.value.isPlaying) {
        print("Widget became active, playing video for ${widget.videoUrl}");
        _controller.play();
      } else if (!widget.isActive && _controller.value.isPlaying) {
        print("Widget became inactive, pausing video for ${widget.videoUrl}");
        _controller.pause();
      }
    }
  }

  void _disposeVideoPlayer() {
    print("Disposing video player for ${widget.videoUrl}");
    _controller.dispose();
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  void _playVideo() {
    print("Play video requested for ${widget.videoUrl}");
    _controller.play();
    setState(() {
      _showControls = false;
    });
  }

  void _stopVideo() {
    print("Stop video requested for ${widget.videoUrl}");
    _controller.pause();
    setState(() {
      _showControls = true;
    });
  }

  void _seekForward() {
    if (_isInitialized) {
      final currentPosition = _controller.value.position;
      final newPosition = currentPosition + Duration(seconds: 10);

      print("Before forward seek, isPlaying: ${_controller.value.isPlaying}, position: $currentPosition");
      _controller.play();
      print("After pause (forward), isPlaying: ${_controller.value.isPlaying}, position: ${_controller.value.position}");

      if (newPosition < _controller.value.duration) {
        _controller.seekTo(newPosition);
        print("After forward seek, isPlaying: ${_controller.value.isPlaying}, new position: $newPosition");
      } else {
        _controller.seekTo(
          _controller.value.duration,
        );
        print("After forward seek (end), isPlaying: ${_controller.value.isPlaying}, new position: ${_controller.value.duration}");
      }
    }
  }

  void _seekBackward() {
    if (_isInitialized) {
      final currentPosition = _controller.value.position;
      final newPosition = currentPosition - Duration(seconds: 10);

      print("Before backward seek, isPlaying: ${_controller.value.isPlaying}, position: $currentPosition");
      _controller.play();
      print("After pause (backward), isPlaying: ${_controller.value.isPlaying}, position: ${_controller.value.position}");

      if (newPosition > Duration.zero) {
        _controller.seekTo(newPosition);
        print("After backward seek, isPlaying: ${_controller.value.isPlaying}, new position: $newPosition");
      } else {
        _controller.seekTo(Duration.zero);
        print("After backward seek (start), isPlaying: ${_controller.value.isPlaying}, new position: Duration.zero");
      }
    }
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 60),
          SizedBox(height: 16),
          Text(
            'Failed to load video',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Please check the URL and try again',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _initializeVideoPlayer();
              });
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: _hasError ? _buildErrorDisplay() : _buildVideoPlayer(),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        if (!_isInitialized) return;
        setState(() {
          _showControls = !_showControls;
        });
        if (_showControls) {
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted && _showControls && _controller.value.isPlaying) {
              setState(() { _showControls = false; });
            }
          });
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AbsorbPointer(
                absorbing: !_showControls,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.replay_10, color: Colors.white, size: 30),
                            onPressed: _seekBackward,
                            tooltip: 'Rewind 10 seconds',
                          ),
                          IconButton(
                            icon: Icon(
                              _isInitialized && _controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 50,
                            ),
                            onPressed: !_isInitialized ? null : () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _stopVideo();
                                } else {
                                  _playVideo();
                                }
                              });
                            },
                            tooltip: _isInitialized && _controller.value.isPlaying ? 'Pause' : 'Play',
                          ),
                          IconButton(
                            icon: Icon(Icons.forward_10, color: Colors.white, size: 30),
                            onPressed: _seekForward,
                            tooltip: 'Forward 10 seconds',
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.redAccent,
                            bufferedColor: Colors.grey.shade400,
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
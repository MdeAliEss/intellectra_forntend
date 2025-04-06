import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  final bool isActive;

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
  bool _showControls = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize()
          .then((_) {
            setState(() {
              _isInitialized = true;
            });
            if (widget.isActive) {
              _controller.play();
            }
          })
          .catchError((error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.toString();
              print('Video Error: $_errorMessage');
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
      _controller.dispose();
      _isInitialized = false;
      _hasError = false;
      _initializeVideoPlayer();
    }
    if (_isInitialized && !_hasError) {
      if (widget.isActive && !_controller.value.isPlaying) {
        _controller.play();
      } else if (!widget.isActive && _controller.value.isPlaying) {
        _controller.pause();
      }
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
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _showControls = true;
        });
      },
      onExit: (_) {
        if (_controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      },
      child: Stack(
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
          if (_showControls)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(_controller, allowScrubbing: true),
          ),
        ],
      ),
    );
  }
}

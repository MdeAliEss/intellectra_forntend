// lib/screens/course_detail/widgets/video_player_widget.dart
import 'package:flutter/material.dart';
import 'package:intellectra/views/course/models/course_models.dart';
import 'video_player_screen.dart';

// ignore: must_be_immutable
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;
  final Function onVideoPlay; // Callback for video play
  final Function onVideoStop; // Callback for video stop

  VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.onVideoPlay,
    required this.onVideoStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            color: Colors.black,
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_circle_filled, size: 32, color: Colors.white),
            onPressed: () {
              onVideoPlay(); // Call the play callback
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
                ),
              ).then((_) {
                onVideoStop(); // Call the stop callback when returning
              });
            },
          ),
        ],
      ),
    );
  }
}

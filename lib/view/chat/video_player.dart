import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer(
      {super.key,
      required this.videoUrl,
      required this.senderName,
      required this.timeStamp});

  final String videoUrl;
  final String senderName;
  final String timeStamp;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late CachedVideoPlayerPlusController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Initialize the CachedVideoPlayerPlusController
    _controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.videoUrl),
      invalidateCacheIfOlderThan: const Duration(days: 69),
    )..initialize().then((_) {
        _controller.play();
        setState(() {
          _isPlaying = true;
        });
      });

    // Add listener for video position updates
    _controller.addListener(() {
      if (mounted) {
        setState(() {}); // Update UI as video position changes
      }
    });
  }

  @override
  void dispose() {
    _controller
        .removeListener(() {}); // Remove listener to prevent memory leaks
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CachedVideoPlayerPlus(_controller),
                  )
                : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
          ),
          Column(
            children: [
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.senderName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget.timeStamp,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Spacer(),
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProgressBar(),
                    _buildControls(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      // If the duration has hours, return in HH:MM:SS format
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // Otherwise, return in MM:SS format
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildProgressBar() {
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    if (duration.inSeconds == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            formatDuration(_controller.value.position),
            style: const TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Slider(
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble(),
              onChanged: (value) {
                final seekTo = Duration(seconds: value.toInt());
                _controller.seekTo(seekTo);
              },
              activeColor: primaryColor,
              inactiveColor: Colors.grey,
            ),
          ),
          Text(
            formatDuration(_controller.value.duration),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black38,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.replay_10,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _controller.seekTo(
                _controller.value.position - const Duration(seconds: 10),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                if (_isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
                _isPlaying = !_isPlaying;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.forward_10,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _controller.seekTo(
                _controller.value.position + const Duration(seconds: 10),
              );
            },
          ),
        ],
      ),
    );
  }
}

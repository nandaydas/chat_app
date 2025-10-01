import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:chat_app/constants/colors.dart'; // Assuming primaryColor is defined here
import 'package:flutter/material.dart';

// Define a default color if primaryColor isn't available for the snippet to compile
// In a real app, ensure chat_app/constants/colors.dart exists and defines primaryColor
const Color primaryColor = Color(0xFF075E54); // Example WhatsApp green

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    super.key,
    required this.videoUrl,
    required this.senderName,
    required this.timeStamp,
  });

  final String videoUrl;
  final String senderName;
  final String timeStamp;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late CachedVideoPlayerPlusController _controller;
  bool _isPlaying = false;
  bool _controlsVisible = true; // State to manage control visibility
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Initialize the CachedVideoPlayerPlusController
    _controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.videoUrl),
      // Using a reasonable cache invalidation duration
      invalidateCacheIfOlderThan: const Duration(days: 30),
    )
      ..initialize().then((_) {
        // Autoplay on load
        _controller.play();
        setState(() {
          _isPlaying = true;
          // Hide controls after a short delay upon successful initialization and play
          _startControlsTimer();
        });
      })
      ..setLooping(false); // Typically a chat video shouldn't loop

    // Add listener for video position updates and control visibility
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = _controller.value.position;
          // When the video ends, show controls and set isPlaying to false
          if (_controller.value.position >= _controller.value.duration && _controller.value.duration != Duration.zero) {
            _isPlaying = false;
            _controlsVisible = true;
          }
        });
      }
    });
  }

  // Timer to auto-hide controls
  void _startControlsTimer() {
    if (_controlsVisible && _isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _controlsVisible = false;
          });
        }
      });
    }
  }

  // Toggle controls visibility on tap
  void _toggleControlsVisibility() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });

    // If controls were shown, start the timer to hide them again
    if (_controlsVisible && _isPlaying) {
      _startControlsTimer();
    }
  }

  @override
  void dispose() {
    // Remove all listeners and dispose
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // 1. VIDEO VIEWPORT
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CachedVideoPlayerPlus(_controller),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),

          // 2. TAP AREA to toggle controls
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControlsVisibility,
              child: const SizedBox.expand(),
            ),
          ),

          // 3. TOP OVERLAY (Sender Info)
          AnimatedOpacity(
            opacity: _controlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildTopOverlay(),
            ),
          ),

          // 4. BOTTOM OVERLAY (Progress Bar and Controls)
          AnimatedOpacity(
            opacity: _controlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomOverlay(),
            ),
          ),

          // 5. CENTER PLAY/PAUSE Button (large, transient)
          AnimatedOpacity(
            opacity: _controlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                onPressed: () {
                  // Toggle play/pause and keep controls visible for a bit
                  _handlePlayPause();
                  _startControlsTimer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to toggle play/pause state
  void _handlePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        // If video ended, rewind to start before playing
        if (_currentPosition >= _controller.value.duration) {
          _controller.seekTo(Duration.zero);
        }
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
            icon: const Icon(Icons.arrow_back, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.senderName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                widget.timeStamp,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
      padding: const EdgeInsets.only(top: 30), // Increased top padding for gradient effect
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(),
          _buildPlaybackControls(),
        ],
      ),
    );
  }


  Widget _buildProgressBar() {
    final duration = _controller.value.duration;

    if (!duration.inSeconds.isFinite || duration.inSeconds == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              formatDuration(_currentPosition),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 15.0),
              ),
              child: Slider(
                value: _currentPosition.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                max: duration.inSeconds.toDouble(),
                onChanged: (value) {
                  // Keep track of the scrubbing position
                  setState(() {
                    _currentPosition = Duration(seconds: value.toInt());
                  });
                },
                onChangeEnd: (value) {
                  // Seek only when the drag ends
                  final seekTo = Duration(seconds: value.toInt());
                  _controller.seekTo(seekTo);
                  // Ensure controls stay visible after seeking
                  _controlsVisible = true;
                  _startControlsTimer();
                },
                activeColor: primaryColor, // Use the chat app's primary color
                inactiveColor: Colors.white54,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              formatDuration(duration),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlIcon(
            icon: Icons.replay_10,
            onPressed: () {
              _controller.seekTo(
                _currentPosition - const Duration(seconds: 10),
              );
              _startControlsTimer();
            },
          ),
          const SizedBox(width: 40),
          _buildControlIcon(
            icon: _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 60, // Larger size for the main control
            onPressed: () {
              _handlePlayPause();
              _startControlsTimer();
            },
          ),
          const SizedBox(width: 40),
          _buildControlIcon(
            icon: Icons.forward_10,
            onPressed: () {
              _controller.seekTo(
                _currentPosition + const Duration(seconds: 10),
              );
              _startControlsTimer();
            },
          ),
        ],
      ),
    );
  }

  // Reusable control icon for consistent styling
  Widget _buildControlIcon({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 38,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.white,
        size: size,
      ),
      onPressed: onPressed,
    );
  }

  // --- UTILITY ---
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

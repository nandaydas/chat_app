import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({
    super.key,
    required this.imageUrl,
    required this.senderName,
    required this.timeStamp,
  });

  final String imageUrl;
  final String senderName;
  final String timeStamp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Use a PreferredSizeWidget AppBar to manage the top overlay
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10), // Slightly taller than default
        child: _buildTopOverlay(context),
      ),
      body: Stack(
        children: [
          // 1. Zoomable/Pannable Image View (Core Content)
          Center(
            child: Hero(
              tag: imageUrl,
              child: _buildInteractiveImage(),
            ),
          ),
          
          // 2. Bottom Fade to hide the content beneath the navigation/status bar area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black38],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopOverlay(BuildContext context) {
    return AppBar(
      // Transparent background with a subtle top-down gradient for text readability
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent], // Dark to transparent fade
          ),
        ),
      ),
      // Leading widget (Back button)
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 28,
        ),
      ),
      // Title widget (Sender Info)
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            senderName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          Text(
            timeStamp,
            style: const TextStyle(
                color: Colors.white70, // Slightly dimmer for secondary info
                fontSize: 13,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  Widget _buildInteractiveImage() {
    return InteractiveViewer(
      panEnabled: true, // Allows panning when zoomed
      minScale: 1.0,
      maxScale: 4.0, // Allow up to 4x zoom
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain, // Ensure the entire image fits initially
        // Placeholder and Error Widgets for better UX
        placeholder: (context, url) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 10),
              Text(
                'Loading image...',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

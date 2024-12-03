import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer(
      {super.key,
      required this.imageUrl,
      required this.senderName,
      required this.timeStamp});

  final String imageUrl;
  final String senderName;
  final String timeStamp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Hero(
              tag: imageUrl,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      senderName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      timeStamp,
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
        ],
      ),
    );
  }
}

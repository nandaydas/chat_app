import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../constants/colors.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class VoiceMessageWidget extends StatelessWidget {
  final Map message;
  final int mkey;

  VoiceMessageWidget({required this.message, super.key, required this.mkey});

  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxDouble progress = 0.0.obs;
  final Rx<Duration?> duration = Rx<Duration?>(null);
  final RxBool isCompleted = false.obs;
  final RxBool isLoading = false.obs;

  final EncryptionController ec = Get.put(EncryptionController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _initializePlayer() async {
    isLoading.value = true; // Start loading
    await _audioPlayer.setUrl(ec.messageDecrypt(message['message'], mkey));
    duration.value = _audioPlayer.duration;
    isLoading.value = false; // Loading complete

    // Listen to position changes for progress updates
    _audioPlayer.positionStream.listen((position) {
      final totalDuration = _audioPlayer.duration ?? Duration.zero;
      if (totalDuration.inMilliseconds > 0) {
        progress.value = position.inMilliseconds / totalDuration.inMilliseconds;
      }
    });

    // Listen to playback state changes
    _audioPlayer.playerStateStream.listen(
      (playerState) {
        isPlaying.value = playerState.playing;

        if (playerState.processingState == ProcessingState.completed) {
          isCompleted.value = true;
          isPlaying.value = false;
        }
      },
    );
  }

  void _togglePlayPause() async {
    if (isCompleted.value) {
      await _audioPlayer.seek(Duration.zero); // Reset to the start of the audio
      isCompleted.value = false; // Reset completion state
      await _audioPlayer.play(); // Play the audio again
    } else {
      if (isPlaying.value) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializePlayer();

    bool isMe = message['uid'] == _auth.currentUser!.uid;

    return Obx(
      () => Container(
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width / 1.425, //70% width of screen
          ),
          decoration: BoxDecoration(
              color: isMe ? primaryColor : Colors.white,
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0.5,
                  blurRadius: 0.5,
                  offset: isMe ? const Offset(0.5, 1) : const Offset(-0.5, 1),
                )
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: isMe ? Colors.white : primaryColor,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 30,
                        color: isMe ? Colors.white : primaryColor,
                      ),
                onPressed: _togglePlayPause,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '',
                      style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress.value,
                      color: isMe ? Colors.white : primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(duration.value ?? Duration.zero),
                          style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white : Colors.black),
                        ),
                        Text(
                          DateFormat('KK:mm a ')
                              .format(message['time'].toDate())
                              .toLowerCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.grey[200] : Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

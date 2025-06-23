import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDetails extends StatefulWidget {
  const VideoDetails({super.key, required this.videoFile});
  final File videoFile;

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {
  late VideoPlayerController _videoPalyerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPalyerController = VideoPlayerController.file(widget.videoFile);
    await _videoPalyerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPalyerController,
      autoInitialize: true,
      autoPlay: true,
      looping: true,
      pauseOnBackgroundTap: true,
      placeholder: Container(
        color: Colors.grey,
        child: Center(child: CircularProgressIndicator()),
      ),
      materialSeekButtonSize: 20,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightGreen,
      ),

      errorBuilder: (context, errorMessage) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(errorMessage, style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoPalyerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

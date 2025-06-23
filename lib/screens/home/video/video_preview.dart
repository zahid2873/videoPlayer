import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final File videoFile;
  final File? thumbnailImageFile; // Optional: for showing thumbnail
  final String? title;
  final FileSystemEntity entity;

  const VideoPreview({
    super.key,
    required this.videoFile,
    this.thumbnailImageFile,
    required this.entity,

    this.title,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _videoPalyerController;
  ChewieController? _chewieController;

  bool _isPlaying = false;

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
    return !_isPlaying
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() => _isPlaying = true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widget.thumbnailImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(8),
                              child: Image.file(
                                widget.thumbnailImageFile!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black12,
                              ),
                              child: Icon(Icons.videocam, size: 64),
                            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              //overflow: TextOverflow.fade,
                            ),
                            const SizedBox(height: 8),
                            subtitle(widget.entity),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child:
                    _chewieController != null &&
                        _chewieController!
                            .videoPlayerController
                            .value
                            .isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPalyerController.value.aspectRatio,
                        child: Chewie(controller: _chewieController!),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              Text(
                widget.title ?? "Untitled Video",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ],
          );
  }

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;

            return Text(
              FileManager.formatBytes(size),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.fade,
            );
          }
          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.fade,
          );
        } else {
          return Text("");
        }
      },
    );
  }
}

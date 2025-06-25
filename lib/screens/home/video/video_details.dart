import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/screens/home/video/video_preview.dart';
import 'package:video_player_app/utils.dart/utils.dart';
import 'package:video_player_app/widgets/hero_widget.dart';

class VideoDetails extends StatefulWidget {
  const VideoDetails({
    super.key,
    this.videoFile,
    this.title,
    required this.herotag,
    required this.entityList,
  });
  final File? videoFile;
  final String? title;
  final String? herotag;
  final List<FileSystemEntity> entityList;

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
    _videoPalyerController = VideoPlayerController.file(
      widget.videoFile ?? File(""),
    );
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
    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroWidget(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title ?? "Untitled Video",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ),
            SizedBox(height: 10),
            _buildVideoList(context),
          ],
        ),
      ),
    );
  }

  HeroWidget _buildHeroWidget(BuildContext context) {
    return HeroWidget(
      heroTag: widget.herotag ?? "",
      width: MediaQuery.of(context).size.width,
      heroBuilder: (BuildContext context) {
        return _buildCheiwePlayer(context);
      },
    );
  }

  Widget _buildCheiwePlayer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child:
          _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoPalyerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<List<File>> _extractVideoFilesOnly(
    List<FileSystemEntity> entities,
  ) async {
    const videoExtensions = [
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.flv',
      '.wmv',
      '.webm',
    ];

    return entities.whereType<File>().where((file) {
      final path = file.path.toLowerCase();
      return videoExtensions.any((ext) => path.endsWith(ext));
    }).toList();
  }

  Widget _buildVideoList(BuildContext context) {
    return Column(
      children: widget.entityList.map((videoFile) {
        return FutureBuilder<File?>(
          future: Utils.generateThumbnail(File(videoFile.path)),
          builder: (context, thumbnailSnapshot) {
            final thumbnail = thumbnailSnapshot.data;
            return VideoPreview(
              videoFile: File(videoFile.path),
              title: FileManager.basename(videoFile, showFileExtension: true),
              entity: videoFile,
              entityList: widget.entityList,
              thumbnailImageFile: thumbnail,
            );
          },
        );
      }).toList(),
    );
  }
}

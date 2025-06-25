
import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player_app/screens/home/video/video_details.dart';
import 'package:video_player_app/widgets/hero_widget.dart';

class VideoPreview extends StatelessWidget {
  final File videoFile;
  final File? thumbnailImageFile;
  final String? title;
  final FileSystemEntity entity;
  final List<FileSystemEntity>? entityList;

  const VideoPreview({
    super.key,
    required this.videoFile,
    this.thumbnailImageFile,
    this.entityList,
    required this.entity,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VideoDetails(
                herotag: thumbnailImageFile?.path ?? "",
                title: title,
                videoFile: videoFile,
                entityList: entityList??[],
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (thumbnailImageFile != null)
                  HeroWidget(
                    heroTag: thumbnailImageFile!.path,
                    width: 80,
                    heroBuilder: (context) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        thumbnailImageFile!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
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
                    children: [
                      Text(
                        title ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      subtitle(entity),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  // PageRoute<Object> _createTutorialDetailRoute({
  //   File? videoFile,
  //   String? title,
  //   String? thumbnailImageUri,
  // }) {
  //   return PageRouteBuilder(
  //     transitionDuration: Duration(seconds: 1),
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       return SlideTransition(
  //         position: Tween(
  //           begin: Offset(1.0, 0.0),
  //           end: Offset.zero,
  //         ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  //         child: FadeTransition(
  //           opacity: Tween(
  //             begin: 0.0,
  //             end: 1.0,
  //           ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  //           child: child,
  //         ),
  //       );
  //     },
  //     pageBuilder: (context, animation, secondaryAnimation) => VideoDetails(
  //       herotag: thumbnailImageUri,
  //       title: title,
  //       videoFile: videoFile,
  //     ),
  //   );
  // }
}

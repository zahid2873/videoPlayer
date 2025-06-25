import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Utils {
  
 static Future<File?> generateThumbnail(File videoFile) async {
    try {
      final tempDir = await getTemporaryDirectory();

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath:
            '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.png',
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 75,
      );

      return thumbnailPath != null ? File(thumbnailPath) : null;
    } catch (e) {
      debugPrint('Thumbnail generation error: $e');
      return null;
    }
  }
}

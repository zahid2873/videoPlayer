import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;

// ─────────────────────────────────────────────────────────────────────────────

mixin VideoActions {
  Future<void> renameVideo(
    AssetEntity video,
    String newName, {
    void Function(AssetEntity updated)? onRenamed,
    BuildContext? context,
  }) async {
    final file = await video.file;
    if (file == null) throw Exception('Could not access file');
    // Extract the directory path from the original file path
    var directoryPath = p.dirname(file.path);

    // Construct the new full path with the new file name
    // This example assumes the new name includes the extension (e.g., "my_new_video.mp4")
    var newPath = p.join(directoryPath, newName);

    try {
      // Attempt to rename the file using the new path
      // The File.rename() method returns a Future<File> that completes with the renamed file
      await file.rename(newPath);
      await Future.delayed(const Duration(milliseconds: 400));

      // Re-fetch the same asset by id — MediaStore updates the path automatically
      final updated = AssetEntity(
        id: video.id,
        typeInt: video.typeInt,
        width: video.width,
        height: video.height,
        duration: video.duration,
        orientation: video.orientation,
        isFavorite: video.isFavorite,
        title: newName,
        createDateSecond: video.createDateSecond,
        modifiedDateSecond: video.modifiedDateSecond,
        relativePath: video.relativePath,
        latitude: video.latitude,
        longitude: video.longitude,
        mimeType: video.mimeType,
        subtype: video.subtype,
      );

      onRenamed?.call(updated);

      if (context != null && context.mounted) {
        _showSnackbar(context, 'Renamed successfully');
      }
    } on FileSystemException catch (e) {
      // Handle potential errors, such as file not found or permission issues
      debugPrint("Error renaming file: $e");
      if (context != null && context.mounted) {
        _showSnackbar(context, 'Rename failed: ${e.toString()}', isError: true);
      }
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────
  Future<void> deleteVideo(
    BuildContext context,
    AssetEntity video, {
    VoidCallback? onDeleted,
  }) async {
    // 1 ── permission
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.hasAccess) {
      if (context.mounted) {
        _showSnackbar(context, 'Storage permission denied', isError: true);
      }
      return;
    }

    // 2 ── try deleteWithIds first (succeeds if app owns the file)
    try {
      final List<String> failed = await PhotoManager.editor.deleteWithIds([
        video.id,
      ]);
      if (failed.isEmpty) {
        onDeleted?.call();
        if (context.mounted) _showSnackbar(context, 'Video deleted');
        return;
      }
      // failed is non-empty → app doesn't own the file → step 3
    } on PlatformException catch (e) {
      if (e.code != 'deleteWithIds failed') {
        if (context.mounted) {
          _showSnackbar(
            context,
            'Delete failed: ${e.message ?? e.code}',
            isError: true,
          );
        }
        return;
      }
    }

    // Final verification
    if (await _isDeleted(video)) {
      onDeleted?.call();
      if (context.mounted) _showSnackbar(context, 'Video deleted');
    } else {
      // Truly cannot delete — guide user to grant All Files Access
      // if (context.mounted) _showDeletePermissionDialog(context, video, onDeleted);
    }
  }

  /// Returns true if the video file no longer exists on disk.
  Future<bool> _isDeleted(AssetEntity video) async {
    try {
      final file = await video.file;
      // file == null means MediaStore can no longer resolve it → deleted
      if (file == null) return true;
      return !await file.exists();
    } catch (_) {
      return true;
    }
  }

  /// Shows a dialog guiding the user to grant "All files access" manually.
  // void _showDeletePermissionDialog(
  //   BuildContext context,
  //   AssetEntity video,
  //   VoidCallback? onDeleted,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       backgroundColor: const Color(0xFF1E1E1E),
  //       shape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: const Text('Cannot Delete',
  //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
  //       content: const Text(
  //         'This video is protected by the system.\n\n'
  //         'To delete it, go to:\n'
  //         'Settings → Apps → Your App → Permissions → Files & Media\n'
  //         'and enable "All files access".',
  //         style: TextStyle(color: Colors.white70, height: 1.6),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(ctx).pop(),
  //           child: const Text('Cancel',
  //               style: TextStyle(color: Colors.white54)),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(ctx).pop();
  //             PhotoManager.openSetting(); // opens app settings
  //           },
  //           child: const Text('Open Settings',
  //               style: TextStyle(
  //                   color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── Properties ───────────────────────────────────────────────────────────
  /// Shows a bottom sheet with full metadata for [video].
  Future<void> showProperties(BuildContext context, AssetEntity video) async {
    final file = await video.file;
    final sizeBytes = await file?.length() ?? 0;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PropertiesSheet(video: video, fileSizeBytes: sizeBytes),
    );
  }

  // ── Share ────────────────────────────────────────────────────────────────
  /// Shares [video] file via the system share sheet.
  Future<void> shareVideo(BuildContext context, AssetEntity video) async {
    try {
      final file = await video.file;
      if (file == null) throw Exception('Could not access file');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'video/*')],
          text: video.title ?? '',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, 'Share failed: ${e.toString()}', isError: true);
      }
    }
  }

  // ── Internal snackbar helper ─────────────────────────────────────────────
  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : const Color(0xFF2E2E2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Properties bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _PropertiesSheet extends StatelessWidget {
  const _PropertiesSheet({required this.video, required this.fileSizeBytes});

  final AssetEntity video;
  final int fileSizeBytes;

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Properties',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Rows
          _PropRow(label: 'Name', value: video.title ?? '—'),
          _PropRow(label: 'Duration', value: _formatDuration(video.duration)),
          _PropRow(
            label: 'Resolution',
            value: '${video.width} × ${video.height}',
          ),
          _PropRow(label: 'Size', value: _formatSize(fileSizeBytes)),
          _PropRow(
            label: 'Created',
            value: video.createDateTime.toString().split('.').first,
          ),
          _PropRow(
            label: 'Modified',
            value: video.modifiedDateTime.toString().split('.').first,
          ),
          _PropRow(label: 'Type', value: video.mimeType ?? '—'),
        ],
      ),
    );
  }
}

class _PropRow extends StatelessWidget {
  const _PropRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player_app/controller/video_controller.dart';
import 'package:video_player_app/screens/home/video/video_action.dart';
import 'package:video_player_app/screens/home/video/video_player_screen.dart';

class VideoItemWidget extends StatefulWidget {
  const VideoItemWidget({
    super.key,
    required this.video,
    this.isGrid = false,
    required this.videos,
    this.isFromVideoPlayer = false,
  });

  final AssetEntity video;
  final bool isGrid;
  final List<AssetEntity> videos;
  final bool isFromVideoPlayer;

  @override
  State<VideoItemWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget> with VideoActions {
  final VideoController _controller = Get.find<VideoController>();

  Future<List<dynamic>> _loadData() async {
    final thumbnail = await widget.video.thumbnailDataWithSize(
      const ThumbnailSize(200, 200),
    );
    final file = await widget.video.file;
    return [thumbnail, file];
  }

  void _onDeleted() {
    _controller.folderVideos.removeWhere((v) => v.id == widget.video.id);
    _controller.update();
  }

  void _onRenamed(AssetEntity updated) {
    final index = _controller.folderVideos.indexWhere(
      (v) => v.id == widget.video.id,
    );
    if (index != -1) {
      _controller.folderVideos[index] = updated;
      _controller.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: widget.isGrid ? 140 : 90,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final Uint8List? thumbnail = snapshot.data![0];
        final File? videoFile = snapshot.data![1];

        if (thumbnail == null || videoFile == null) return const SizedBox();

        final menu = _VideoMenu(
          video: widget.video,
          onRename: (newName) => renameVideo(
            widget.video,
            newName,
            context: context,
            onRenamed: _onRenamed,
          ),
          onDelete: () =>
              deleteVideo(context, widget.video, onDeleted: _onDeleted),
          onProperties: () => showProperties(context, widget.video),
          onShare: () => shareVideo(context, widget.video),
        );

        return GestureDetector(
          onTap: () {
            if (!widget.isFromVideoPlayer) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    herotag: thumbnail,
                    title: widget.video.title,
                    videoFile: videoFile,
                    videos: widget.videos,
                    video: widget.video,
                  ),
                ),
              );
            }
          },
          child: widget.isGrid
              ? _GridItem(video: widget.video, thumbnail: thumbnail, menu: menu)
              : _ListItem(
                  video: widget.video,
                  thumbnail: thumbnail,
                  menu: menu,
                ),
        );
      },
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem({
    required this.video,
    required this.thumbnail,
    required this.menu,
  });

  final AssetEntity video;
  final Uint8List thumbnail;
  final _VideoMenu menu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.memory(thumbnail, fit: BoxFit.cover),
              ),
            ),
            // Duration badge
            Positioned(
              right: 6,
              bottom: 6,
              child: _DurationBadge(seconds: video.duration),
            ),
          ],
        ),
        SizedBox(height: 5),
        Container(
          color: Colors.amber,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  video.title.toString(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.fade,
                  maxLines: 2,
                ),
              ),
              _MenuButton(menu: menu, isGrid: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.video,
    required this.thumbnail,
    required this.menu,
  });

  final AssetEntity video;
  final Uint8List thumbnail;
  final _VideoMenu menu;

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.all(8),
      height: 90,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    thumbnail,
                    fit: BoxFit.cover,
                    height: 90,
                    width: 110,
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: _DurationBadge(seconds: video.duration),
                ),
              ],
            ),
            const SizedBox(width: 15),
            // Title
            Expanded(
              child: Text(
                video.title ?? 'Untitled',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            // More menu
            Spacer(),
            _MenuButton(menu: menu, isGrid: false),
          ],
        ),
      ),
    );
  }
}

class _VideoMenu {
  const _VideoMenu({
    required this.video,
    required this.onRename,
    required this.onDelete,
    required this.onProperties,
    required this.onShare,
  });

  final AssetEntity video;
  final void Function(String) onRename;
  final VoidCallback onDelete;
  final VoidCallback onProperties;
  final VoidCallback onShare;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.menu, required this.isGrid});

  final _VideoMenu menu;
  final bool isGrid;

  String get _title => menu.video.title ?? 'Untitled';

  void _onSelected(BuildContext context, _MenuAction action) {
    switch (action) {
      case _MenuAction.rename:
        _showRenameDialog(context);
      case _MenuAction.delete:
        _showDeleteDialog(context);
      case _MenuAction.properties:
        menu.onProperties();
      case _MenuAction.share:
        menu.onShare();
    }
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: _title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rename',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFFE53935),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                menu.onRename(name);
              }
            },
            child: const Text(
              'Rename',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Video',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Delete "$_title"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              Future.microtask(() => menu.onDelete());
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      onSelected: (action) => _onSelected(context, action),
      padding: EdgeInsets.zero, // ← remove default padding
      constraints: const BoxConstraints(),
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // ← removes 48px min
        minimumSize: WidgetStateProperty.all(Size.zero),
      ),
      icon: Icon(
        Icons.more_vert,
        size: 20,
        // White on grid (over dark thumbnail), default on list
        // color: isGrid ? Colors.white : null,
      ),

      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _MenuAction.rename,
          child: _MenuRow(
            icon: Icons.drive_file_rename_outline_rounded,
            label: 'Rename',
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            isDestructive: true,
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.properties,
          child: _MenuRow(
            icon: Icons.info_outline_rounded,
            label: 'Properties',
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.share,
          child: _MenuRow(icon: Icons.share_rounded, label: 'Share'),
        ),
      ],
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.seconds});

  final int seconds;

  String _fmt() {
    final d = Duration(seconds: seconds);
    String p(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${p(h)}:${p(m)}:${p(s)}' : '${p(m)}:${p(s)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _fmt(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal enum + menu row
// ─────────────────────────────────────────────────────────────────────────────
enum _MenuAction { rename, delete, properties, share }

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFE53935) : Colors.white;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

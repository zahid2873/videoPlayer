import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/common/custom_appbar.dart';
import 'package:video_player_app/utils.dart/utils.dart';

import 'custom_video_control.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    this.videoFile,
    this.videoUrl,
    this.title,
    required this.herotag,
    required this.videos,
    required this.video,
  });

  final File? videoFile;
  final String? videoUrl;
  final String? title;
  final Uint8List? herotag;
  final List<AssetEntity> videos;
  final AssetEntity video;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isInitializing = true;
  String? _errorMessage;
  File? _currentFile;
  late AssetEntity _currentAsset;
  late String? _currentTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentAsset = widget.video;
    _currentTitle = widget.title;
    _initPlayer(widget.videoFile ?? File(''));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeControllers();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _videoController?.pause();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  Future<void> _initPlayer(File file, {AssetEntity? asset}) async {
    if (!mounted) return;
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    _disposeControllers();
    _currentFile = file;
    if (asset != null) {
      setState(() {
        _currentAsset = asset;
        _currentTitle = asset.title;
      });
    }

    try {
      final vpc = widget.videoUrl != null
          ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
          : VideoPlayerController.file(file);

      await vpc.initialize();
      if (!mounted) {
        vpc.dispose();
        return;
      }

      _videoController = vpc;
      final nativeRatio = vpc.value.aspectRatio;
      final safeRatio = (nativeRatio.isFinite && nativeRatio > 0)
          ? nativeRatio
          : 16 / 9;

      _chewieController = ChewieController(
        videoPlayerController: vpc,
        aspectRatio: safeRatio,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        customControls: CustomVideoControls(thumbnail: widget.herotag),
        placeholder: widget.herotag != null
            ? Image.memory(widget.herotag!, fit: BoxFit.cover)
            : const ColoredBox(color: Colors.black),
        errorBuilder: (_, msg) => _PlayerError(message: msg),
      );

      setState(() => _isInitializing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Could not play this video.\n${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        // ── Single ListView — player is item 0, videos follow ─────────────
        // Putting the player inside the ListView means Flutter's gesture
        // arena gives scroll priority to the list on vertical drags, while
        // horizontal drags / taps still reach the custom controls.
        child: ListView.builder(
          itemCount: widget.videos.length + 1, // +1 for the player header
          itemBuilder: (context, index) {
            // ── Item 0: player + title + divider ──────────────────────────
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlayerSection(context),
                  _buildTitle(),
                  const Divider(color: Colors.black12, height: 1),
                ],
              );
            }

            // ── Items 1+: video list ──────────────────────────────────────
            final asset = widget.videos[index - 1];
            final isLast = index == widget.videos.length;

            return Column(
              children: [
                _VideoListTile(
                  asset: asset,
                  isPlaying: _currentAsset.id == asset.id,
                  onTap: (file) {
                    if (_currentFile?.path != file.path) {
                      _initPlayer(file, asset: asset);
                    }
                  },
                ),
                if (!isLast)
                  const Divider(color: Colors.black12, height: 1, indent: 72),
                if (isLast) const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(leading: CustomBackButton());
  }

  Widget _buildPlayerSection(BuildContext context) {
    if (_isInitializing) return _LoadingPlayer(thumbnail: widget.herotag);
    if (_errorMessage != null) return _PlayerError(message: _errorMessage!);
    final chewie = _chewieController;
    if (chewie == null) return const _LoadingPlayer();

    final ratio = _videoController?.value.aspectRatio ?? 16 / 9;

    return Hero(
      tag: 'video_${widget.herotag.hashCode}',
      child: AspectRatio(
        aspectRatio: ratio,
        child: Chewie(controller: chewie),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        _currentTitle ?? 'Untitled Video',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingPlayer extends StatelessWidget {
  const _LoadingPlayer({this.thumbnail});
  final Uint8List? thumbnail;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnail != null)
            Image.memory(thumbnail!, fit: BoxFit.cover)
          else
            const ColoredBox(color: Color(0xFF0D0D0D)),
          Container(color: Colors.black45),
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE53935),
              strokeWidth: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: const Color(0xFF0D0D0D),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE53935),
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoListTile extends StatelessWidget {
  const _VideoListTile({
    required this.asset,
    required this.isPlaying,
    required this.onTap,
  });

  final AssetEntity asset;
  final bool isPlaying;
  final void Function(File) onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        asset.thumbnailDataWithSize(const ThumbnailSize(160, 100)),
        asset.file,
      ]),
      builder: (context, snapshot) {
        final thumb = snapshot.data?[0] as Uint8List?;
        final file = snapshot.data?[1] as File?;

        return InkWell(
          onTap: file == null ? null : () => onTap(file),
          splashColor: Colors.black12,
          highlightColor: Colors.black12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: isPlaying
                ? Utils.colorWithOpacity(Colors.grey, 0.06)
                : Colors.transparent,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 100,
                    height: 62,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        thumb != null
                            ? Image.memory(thumb, fit: BoxFit.cover)
                            : const ColoredBox(color: Color(0xFF1C1C1C)),
                        if (isPlaying)
                          Container(
                            color: Colors.black45,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/video_player_logo.svg',
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.title ?? 'Unknown',
                        style: TextStyle(
                          color: isPlaying
                              ? const Color(0xFF53BC77)
                              : Colors.black,
                          fontSize: 13,
                          fontWeight: isPlaying
                              ? FontWeight.w600
                              : FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(asset.videoDuration),
                        style: TextStyle(
                          color: isPlaying
                              ? const Color(0xFF66D15F)
                              : Colors.black87,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }
}

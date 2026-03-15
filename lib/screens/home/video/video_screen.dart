import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player_app/common/custom_appbar.dart';
import 'package:video_player_app/controller/video_controller.dart';
import 'package:video_player_app/screens/home/video/video_item_widget.dart';

class FolderVideosScreen extends StatefulWidget {
  final AssetPathEntity folder;

  const FolderVideosScreen({super.key, required this.folder});

  @override
  State<FolderVideosScreen> createState() => _FolderVideosScreenState();
}

class _FolderVideosScreenState extends State<FolderVideosScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(VideoController()).loadVideos(widget.folder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          widget.folder.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: CustomBackButton(),
        action: GetBuilder<VideoController>(
          builder: (controller) {
            return IconButton(
              onPressed: () {
                controller.toggleView();
              },
              icon: controller.isGrid
                  ? SvgPicture.asset(
                      'assets/images/list.svg',
                      height: 20,
                      width: 20,
                    )
                  : SvgPicture.asset(
                      'assets/images/Grid.svg',
                      height: 20,
                      width: 20,
                    ),
            );
          },
        ),
      ),

      body: GetBuilder<VideoController>(
        builder: (videoController) {
          if (videoController.isLoadingVideos) {
            return const Center(child: CircularProgressIndicator());
          }

          final videos = videoController.folderVideos;

          return videoController.isGrid
              ? _getGridVideos(context, videos)
              : _getListVideos(context, videos);
        },
      ),
    );
  }

  Widget _getGridVideos(BuildContext context, List<AssetEntity> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .80,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoItemWidget(video: video, videos: videos, isGrid: true);
      },
    );
  }

  Widget _getListVideos(BuildContext context, List<AssetEntity> videos) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoItemWidget(video: video, videos: videos);
      },
    );
  }
}

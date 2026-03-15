import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:video_player_app/common/custom_appbar.dart';
import 'package:video_player_app/controller/home_controller.dart';
import 'package:video_player_app/screens/home/fileManagement/folder_widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "Video Folders",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        action: GetBuilder<HomeController>(
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

      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final folders = controller.folders;
          if (folders.isEmpty) {
            return const Center(child: Text("No videos found"));
          }

          return FolderWidget(folders: folders, isGrid: controller.isGrid);
        },
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoController extends GetxController {
  List<AssetEntity> folderVideos = [];
  bool isGrid = false;
  bool isLoadingVideos = false;

  Future<void> loadVideos(AssetPathEntity folder) async {
    isLoadingVideos = true;
    final count = await folder.assetCountAsync;

    folderVideos = await folder.getAssetListPaged(page: 0, size: count);
    isLoadingVideos = false;
    update();
  }

  void toggleView() {
    isGrid = !isGrid;
    update();
  }
}

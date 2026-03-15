import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeController extends GetxController {
  // ── State ─────────────────────────────────────────────────────────────────
  List<AssetPathEntity> folders = [];
  bool isGrid = false;
  bool isLoading = true;
  bool hasPermission = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadFolders();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void toggleView() {
    isGrid = !isGrid;
    update();
  }

  Future<void> loadFolders() async {
    isLoading = true;

    final permission = await PhotoManager.requestPermissionExtend();
    hasPermission = permission.isAuth;

    if (!permission.isAuth) {
      isLoading = false;
      return;
    }

    final result = await PhotoManager.getAssetPathList(type: RequestType.video);

    result.sort((a, b) => a.name.compareTo(b.name));
    folders = result;
    isLoading = false;
    update();
  }

  //Future<void> refresh() => loadFolders();
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player_app/screens/home/video/video_screen.dart';

class FolderWidget extends StatelessWidget {
  FolderWidget({
    super.key,
    this.title,
    required this.folders,
    VoidCallback? onTap,
    this.isGrid = false,
  }) : onTap = onTap ?? (() {});
  final VoidCallback onTap;
  final String? title;
  final List<AssetPathEntity> folders;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: isGrid ? _buildGridFolders(context) : _buildListFolders(context),
    );
  }

  Widget _buildListFolders(BuildContext context) {
    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, index) {
        return ListFolder(folder: folders[index]);
      },
    );
  }

  Widget _buildGridFolders(BuildContext context) {
    return GridView.builder(
      itemCount: folders.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        return GridFolder(folder: folders[index]);
      },
    );
  }
}

class ListFolder extends StatefulWidget {
  const ListFolder({super.key, required this.folder});
  final AssetPathEntity folder;

  @override
  State<ListFolder> createState() => _ListFolderState();
}

class _ListFolderState extends State<ListFolder> {
  int count = 0;
  @override
  void initState() {
    super.initState();
    _getCount();
  }

  Future<void> _getCount() async {
    count = await widget.folder.assetCountAsync;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.all(8),
        height: 80,
        width: 130,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FolderVideosScreen(folder: widget.folder),
              ),
            );
          },
          onLongPress: () {},
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/images/folder.svg",
                  height: 50,
                  width: 50,
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.folder.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    ),
                    Text(
                      "$count videos",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.chevron_right, size: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridFolder extends StatefulWidget {
  const GridFolder({super.key, required this.folder});
  final AssetPathEntity folder;

  @override
  State<GridFolder> createState() => _GridFolderState();
}

class _GridFolderState extends State<GridFolder> {
  int count = 0;
  @override
  void initState() {
    super.initState();
    _getCount();
  }

  Future<void> _getCount() async {
    count = await widget.folder.assetCountAsync;
    if(mounted){
    setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(8),
        height: 80,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FolderVideosScreen(folder: widget.folder),
              ),
            );
          },
          onLongPress: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/folder.svg",
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.folder.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "$count videos",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    ),
                  ],
                ),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/screens/home/floder_widget.dart';

class HomeTab extends StatelessWidget {
  HomeTab({super.key});
  final FileManagerController controller = FileManagerController();

  @override
  Widget build(BuildContext context) {
    return ControlBackButton(
      controller: controller,
      child: Scaffold(
        appBar: appBar(context),
        body: FileManager(
          controller: controller,
          builder: (context, snapshot) {
            return FutureBuilder<List<FileSystemEntity>>(
              future: _filterVideoFilesAndDeleteOthers(snapshot),
              builder: (context, filteredSnapshot) {
                if (!filteredSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final filtered = filteredSnapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    FileSystemEntity entity = filtered[index];
                    return FileManager.isFile(entity)
                        ? Card(
                            child: ListTile(
                              leading: FileManager.isFile(entity)
                                  ? Icon(Icons.feed_outlined)
                                  : Icon(Icons.folder),
                              title: Text(
                                FileManager.basename(
                                  entity,
                                  showFileExtension: true,
                                ),
                              ),
                              subtitle: subtitle(entity),
                              onTap: () async {
                                if (FileManager.isDirectory(entity)) {
                                  // open the folder
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    controller.openDirectory(entity);
                                  });

                                  // delete a folder
                                  // await entity.delete(recursive: true);

                                  // rename a folder
                                  // await entity.rename("newPath");

                                  // Check weather folder exists
                                  // entity.exists();

                                  // get date of file
                                  // DateTime date = (await entity.stat()).modified;
                                } else {
                                  // delete a file
                                  // await entity.delete();

                                  // rename a file
                                  // await entity.rename("newPath");

                                  // Check weather file exists
                                  // entity.exists();

                                  // get date of file
                                  // DateTime date = (await entity.stat()).modified;

                                  // get the size of the file
                                  // int size = (await entity.stat()).size;
                                }
                              },
                            ),
                          )
                        : FloderWidget(
                            title: FileManager.basename(
                              entity,
                              showFileExtension: true,
                            ),
                            entity: entity,
                            onTap: () {
                              if (FileManager.isDirectory(entity)) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  controller.openDirectory(entity);
                                });
                              } else {}
                            },
                          );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Permission.storage.request();
            await Permission.manageExternalStorage.request();
          },
          label: Text("Request File Access Permission"),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () => createFolder(context),
          icon: Icon(Icons.create_new_folder_outlined),
        ),
        IconButton(
          onPressed: () => sort(context),
          icon: Icon(Icons.sort_rounded),
        ),
        IconButton(
          onPressed: () => selectStorage(context),
          icon: Icon(Icons.sd_storage_rounded),
        ),
      ],
      title: ValueListenableBuilder<String>(
        valueListenable: controller.titleNotifier,
        builder: (context, title, _) {
          return Text(title);
        },
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () async {
          await controller.goToParentDirectory();
        },
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

            return Text(FileManager.formatBytes(size));
          }
          return Text("${snapshot.data!.modified}".substring(0, 10));
        } else {
          return Text("");
        }
      },
    );
  }

  Future<void> selectStorage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: storageList
                      .map(
                        (e) => ListTile(
                          title: Text(FileManager.basename(e)),
                          onTap: () {
                            controller.openDirectory(e);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            }
            return Dialog(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Name"),
                onTap: () {
                  controller.sortBy(SortBy.name);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Size"),
                onTap: () {
                  controller.sortBy(SortBy.size);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Date"),
                onTap: () {
                  controller.sortBy(SortBy.date);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("type"),
                onTap: () {
                  controller.sortBy(SortBy.type);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  createFolder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController folderName = TextEditingController();
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: TextField(controller: folderName)),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FileManager.createFolder(
                        controller.getCurrentPath,
                        folderName.text,
                      );

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.setCurrentPath =
                            "${controller.getCurrentPath}/${folderName.text}";
                      });
                    } catch (e) {
                      debugPrint('Failed to create folder: $e');
                    }

                    Navigator.pop(context);
                  },
                  child: Text('Create Folder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _folderHasVideoFile(Directory dir) async {
    const videoExtensions = [
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.flv',
      '.wmv',
      '.webm',
    ];

    try {
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          if (videoExtensions.any((ext) => path.endsWith(ext))) {
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint("Error reading folder: ${dir.path}, $e");
    }

    return false;
  }

  Future<List<FileSystemEntity>> _filterVideoFilesAndDeleteOthers(
    List<FileSystemEntity> entities,
  ) async {
    const videoExtensions = [
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.flv',
      '.wmv',
      '.webm',
    ];
    List<FileSystemEntity> result = [];

    for (var entity in entities) {
      if (entity is File) {
        final ext = entity.path.toLowerCase();
        if (videoExtensions.any((videoExt) => ext.endsWith(videoExt))) {
          result.add(entity);
        }
      } else if (entity is Directory) {
        final hasVideo = await _folderHasVideoFile(entity);
        if (hasVideo) {
          result.add(entity);
        }
      }
    }
    return result;
  }
}

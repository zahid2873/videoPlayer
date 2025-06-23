import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FloderWidget extends StatelessWidget {
  FloderWidget({
    super.key,
    this.title,
    required this.entity,
    VoidCallback? onTap,
  }) : onTap = onTap ?? (() {});
  final VoidCallback onTap;
  final String? title;
  final FileSystemEntity entity;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(8),
        height: 120,
        width: 130,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          onLongPress: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/images/phoneImg.svg",
                  height: 80,
                  width: 80,
                ),
                const SizedBox(width: 15),
                Text(
                  title ?? "",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
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
}

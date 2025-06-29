import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.leading,
    this.title,
    this.backgroundColor,
    this.action,
    this.titleSpace,
    this.isCenterTitle = false,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  final Widget? leading;
  final Widget? title;
  @override
  final Size preferredSize;
  final Color? backgroundColor;
  final Widget? action;
  final bool isCenterTitle;
  final double? titleSpace;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading,
      title: title,
      titleSpacing: titleSpace,
      elevation: 0,
      scrolledUnderElevation: 2,
      iconTheme: Theme.of(context).iconTheme,
      backgroundColor: Colors.blueAccent,
      surfaceTintColor: Colors.transparent,
      centerTitle: isCenterTitle,
      actions: [
        Padding(padding: const EdgeInsets.only(right: 4), child: action),
      ],
    );
  }
}


class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.color,
  });
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: color ?? Theme.of(context).iconTheme.color,
        ),
        onPressed: () {
       Navigator.of(context).pop();
        },
      ),
    );
  }
}

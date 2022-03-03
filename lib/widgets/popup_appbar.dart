import 'package:flutter/material.dart';

class PopupAppbar extends StatelessWidget implements PreferredSizeWidget {
  const PopupAppbar({Key? key, this.title}) : super(key: key);
  final Text? title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_outlined),
            splashRadius: 15,
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

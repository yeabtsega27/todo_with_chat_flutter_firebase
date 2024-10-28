import 'package:flutter/material.dart';

class ToDoAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<bool> onChange;

  const ToDoAppBar({super.key, required this.onChange});

  @override
  State<ToDoAppBar> createState() => _ToDoAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ToDoAppBarState extends State<ToDoAppBar> {
  bool isGrid = true;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('ToDo'), actions: [
      IconButton(
        icon: Icon(
          isGrid ? Icons.list : Icons.grid_view,
          color: Colors.black,
        ),
        onPressed: () {
          setState(() {
            isGrid = !isGrid;
            widget.onChange(isGrid);
          });
        },
      )
    ]);
  }
}

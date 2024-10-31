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
    return AppBar(
        backgroundColor: const Color(0xFF229ED9),
        title: const Text(
          'ToDo',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isGrid ? Icons.list : Icons.grid_view,
              color: Colors.white,
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

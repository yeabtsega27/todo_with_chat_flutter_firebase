import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/DatabaseService.dart';
import 'package:todo_app_with_chat/locator.dart';

class TitleInput extends StatefulWidget {
  final String title;
  final String id;
  const TitleInput({super.key, required this.title, required this.id});

  @override
  State<TitleInput> createState() => _TitleInputState();
}

class _TitleInputState extends State<TitleInput> {
  late TextEditingController titleController;

  late DatabaseService _databaseService;

  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
    titleController = TextEditingController(
        text: widget.title); // Initialize with title value
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: titleController,
      decoration: const InputDecoration(
        hintText: 'Title',
        hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
      ),
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      onChanged: (value) {
        _databaseService.editToDoTitle(widget.id, value);
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/locator.dart';

class NoteInput extends StatefulWidget {
  final String note;
  final String id;
  const NoteInput({super.key, required this.note, required this.id});

  @override
  State<NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends State<NoteInput> {
  late TextEditingController noteController;
  late DatabaseService _databaseService;

  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();

    super.initState();
    noteController =
        TextEditingController(text: widget.note); // Initialize with title value
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: noteController,
      decoration: const InputDecoration(
        hintText: 'Note',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
      ),
      onChanged: (value) {
        _databaseService.editToDoNote(widget.id, value);
      },
      minLines: 2,
      maxLines: 100,
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}

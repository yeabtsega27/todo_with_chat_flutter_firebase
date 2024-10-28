import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/DatabaseService.dart';
import 'package:todo_app_with_chat/core/models/photoModel.dart';
import 'package:todo_app_with_chat/locator.dart';

class ShowImage extends StatefulWidget {
  final Photo photo;
  final String todoId;
  const ShowImage({super.key, required this.photo, required this.todoId});

  @override
  State<ShowImage> createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  late DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                bool result = await _databaseService.removeImageFromFirebase(
                    widget.photo, widget.todoId);
                print(result);
                if (result) Navigator.pop(context);
              },
              icon: Icon(
                Icons.delete,
                color: Colors.deepOrange,
              ))
        ],
      ),
      body: Center(
        child: Image.network(
          widget.photo.photoURL,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

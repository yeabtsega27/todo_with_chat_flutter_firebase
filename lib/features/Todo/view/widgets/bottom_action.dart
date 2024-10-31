import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/alert_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/photoModel.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/core/utils/utils.dart';
import 'package:todo_app_with_chat/features/Todo/view//collaborator_page.dart';
import 'package:todo_app_with_chat/locator.dart';

class BottomAction extends StatefulWidget {
  final String date;
  final String todoId;
  final List<Users> users;
  const BottomAction(
      {super.key,
      required this.date,
      required this.todoId,
      required this.users});

  @override
  State<BottomAction> createState() => _BottomActionState();
}

class _BottomActionState extends State<BottomAction> {
  final ImagePicker _picker = ImagePicker();
  late DatabaseService _databaseService;
  late AlertService _alertService;
  late NavigationService _navigationService;

  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    _navigationService = locator.get<NavigationService>();
    _alertService = locator.get<AlertService>();
    super.initState();
  }

  Future<void> pickImage(ImageSource source) async {
    final currentContext = context;
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final result =
          await _databaseService.uploadImageToFirebase("todo", imageFile);
      String downloadUrl = result["downloadUrl"];
      FullMetadata imageMetadata = result["imageMetadata"];
      if (downloadUrl.isNotEmpty) {
        Photo photo = Photo(
            photoURL: downloadUrl,
            uploadTime: DateTime.now(),
            path: imageMetadata.fullPath);
        bool res = await DatabaseService().addPhotoToToDo(widget.todoId, photo);
        if (currentContext.mounted) {
          if (res) {
            _alertService.showAlert(
                currentContext, "Image added", AlertType.info);
          } else {
            _alertService.showAlert(
                currentContext, "Failed to add image ", AlertType.info);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => bottomAddSheet(context),
            icon: const Icon(Icons.add_box_outlined),
          ),
          Text("Edited ${formatDate(widget.date)}"),
          IconButton(
            onPressed: () => bottomMenuSheet(context),
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
    );
  }

  bottomAddSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        builder: (BuildContext context) {
          return Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_outlined),
                title: const Text('Add photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tack photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.check_box_outlined),
              //   title: const Text('Checkboxes'),
              //   onTap: () {},
              // ),
            ],
          );
        });
  }

  bottomMenuSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        builder: (BuildContext context) {
          return Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined),
                title: const Text('Delete'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                              "Are you sure you want to delete this todo"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                  ..pop()
                                  ..pop(); // Close the dialog
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                final currentContext = context;

                                bool res = await _databaseService
                                    .deleteToDo(widget.todoId);
                                if (currentContext.mounted) {
                                  if (res) {
                                    _alertService.showAlert(
                                        currentContext,
                                        "Todo delete successfully",
                                        AlertType.info);
                                    _navigationService.goBack();
                                    _navigationService.goBack();
                                    _navigationService.goBack();
                                  } else {
                                    _alertService.showAlert(
                                        currentContext,
                                        "Field to delete todo",
                                        AlertType.error);
                                  }
                                }
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      });
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Collaborator'),
                onTap: () {
                  _navigationService.goBack();
                  _navigationService.push(MaterialPageRoute(
                      builder: (context) =>
                          CollaboratorPage(todoId: widget.todoId)));
                },
              ),
            ],
          );
        });
  }
}

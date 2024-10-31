import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/alert_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/photoModel.dart';
import 'package:todo_app_with_chat/features/chat/view/group_chat_page.dart';
import 'package:todo_app_with_chat/locator.dart';

class NewGroupCreate extends StatefulWidget {
  const NewGroupCreate({super.key});

  @override
  State<NewGroupCreate> createState() => _NewGroupCreateState();
}

class _NewGroupCreateState extends State<NewGroupCreate> {
  final TextEditingController _groupNameController = TextEditingController();
  String? _selectedImagePath; // For storing the selected image path
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  @override
  void initState() {
    _alertService = locator.get<AlertService>();
    _navigationService = locator.get<NavigationService>();
    _databaseService = locator.get<DatabaseService>();
    // TODO: implement initState
    super.initState();
  }

  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _onDone() async {
    if (_groupNameController.text.isEmpty) {
      _alertService.showAlert(
          context, "Please enter a group name", AlertType.error);
      return;
    }
    Photo photo = Photo(photoURL: "", uploadTime: DateTime.now(), path: "");
    if (_selectedImagePath != null) {
      File imageFile = File(_selectedImagePath ?? "");
      var imageInfo =
          await _databaseService.uploadImageToFirebase("chats", imageFile);
      String downloadUrl = imageInfo["downloadUrl"];
      FullMetadata imageMetadata = imageInfo["imageMetadata"];
      if (downloadUrl.isNotEmpty) {
        photo = Photo(
            photoURL: downloadUrl,
            uploadTime: DateTime.now(),
            path: imageMetadata.fullPath);
      }
    }
    String key = await _databaseService.createNewGroupChat(
        photo, _groupNameController.text);

    _navigationService.pushReplacementRoute(
        MaterialPageRoute(builder: (context) => GroupChatPage(chatId: key)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              _navigationService.goBack();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: const Color(0xFF229ED9),
        title: const Text(
          "New Group",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF229ED9),
                  backgroundImage: _selectedImagePath != null
                      ? FileImage(File(_selectedImagePath!))
                      : null,
                  child: _selectedImagePath == null
                      ? const Icon(Icons.camera_alt_sharp,
                          size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _groupNameController,
                  decoration: const InputDecoration(
                    hintText: "Enter group name",
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF229ED9),
                          width: 2.0), // Default bottom border color
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF229ED9),
                        width: 2.0,
                      ), // Bottom border color when enabled
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF229ED9),
                          width: 2.0), // Bottom border color when focused
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onDone,
        backgroundColor: const Color(0xFF229ED9),
        child: const Icon(Icons.done, color: Colors.white),
      ),
    );
  }
}

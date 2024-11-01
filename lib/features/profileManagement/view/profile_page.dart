import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/alert_service.dart';
import 'package:todo_app_with_chat/Service/auth_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/core/widgets/network_image_with_fallback.dart';
import 'package:todo_app_with_chat/locator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AlertService _alertService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;
  late AuthService _authService;
  final ImagePicker _imagePicker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _alertService = locator.get<AlertService>();
    _navigationService = locator.get<NavigationService>();
    _databaseService = locator.get<DatabaseService>();
    _authService = locator.get<AuthService>();
  }

  void _showEditBottomSheet(String field, String value) {
    TextEditingController controller = TextEditingController();
    controller.text = value;

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the modal to resize with the keyboard
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                16.0, // Adjusts for keyboard
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Change $field",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "$field",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF229ED9),
                  ),
                  onPressed: () {
                    print(field);
                    if (field == "Name") {
                      _databaseService.uploadName(controller.text);
                      _alertService.showAlert(context,
                          "user name change successfully", AlertType.success);
                    } else if (field == "Email") {
                      print("object");
                      print(controller.text);
                      // _authService.changeEmail(controller.text);
                      _alertService.showAlert(
                          context,
                          "Email address change successfully",
                          AlertType.success);
                      // Update email
                    } else if (field == "Password") {
                      // _authService.changePassword(controller.text);
                      _alertService.showAlert(context,
                          "password change successfully", AlertType.success);
                      // Update password
                    }
                    _navigationService.goBack();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print("Image selected: ${pickedFile.path}");
      File file = File(pickedFile.path);

      await _databaseService.uploadProfile(file);
      _alertService.showAlert(
          context, "Profile image add successfully", AlertType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF229ED9),
        title: const Text(
          "Profile",
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                final currentContext = context; // Capture the context early

                bool result = await _authService.logOut();
                if (!result) {
                  if (currentContext.mounted) {
                    // Check if context is still valid
                    _alertService.showAlert(
                        currentContext, "error while log out", AlertType.error);
                  }
                } else {
                  // Navigator/
                  if (currentContext.mounted) {
                    _alertService.showAlert(
                        currentContext, "you have log out", AlertType.info);
                  }
                  _navigationService.pushReplacement("/auth");
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: Container(
        child: StreamBuilder(
            stream: _databaseService.getMyInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null) {
                const CircularProgressIndicator();
              }
              UserModel user =
                  snapshot.data ?? UserModel.fromJson({"photos": []});
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipOval(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              shape: BoxShape
                                  .circle, // Make the container circular
                              color: Colors.red,
                            ),
                            child: NetworkImageWithFallback(
                              imageUrl: user.photos.isNotEmpty
                                  ? user.photos.first.photoURL
                                  : "",
                              fallbackAssetPath: 'assets/default_profile.jpg',
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            _showEditBottomSheet("Name", user.username);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            _showEditBottomSheet("Email", user.email);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF229ED9)),
                      onPressed: () {
                        _showEditBottomSheet("Password", "");
                      },
                      child: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

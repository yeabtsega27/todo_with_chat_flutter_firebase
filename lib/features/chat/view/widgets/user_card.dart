import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/core/utils/utils.dart';
import 'package:todo_app_with_chat/features/chat/view/chat_page.dart';
import 'package:todo_app_with_chat/locator.dart';

class UserCard extends StatefulWidget {
  final UserModel user;
  const UserCard({super.key, required this.user});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    _navigationService = locator.get<NavigationService>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        String key = "";
        Map<String, dynamic> res =
            await _databaseService.checkChatExist(widget.user);
        if (res["status"]) {
          key = res["key"];
        } else {
          key = await _databaseService.createNewPersonalChat(widget.user);
        }
        if (key.isNotEmpty) {
          _navigationService.pushReplacementRoute(MaterialPageRoute(
              builder: (context) => ChatPage(chatId: res["key"])));
        }
      },
      child: GestureDetector(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: widget.user.photos.isNotEmpty
                ? NetworkImage(widget
                    .user.photos.first.photoURL) // Show the first photo URL
                : null, // Set to null if no photo is available
            child: widget.user.photos.isEmpty
                ? Text(widget
                    .user.username[0]) // Show the first letter of the username
                : null, // Don't show text if there's a photo Fallback image
          ),
          title: Text(widget.user.username),
          subtitle: widget.user.online
              ? const Text(
                  "Online",
                  style: TextStyle(color: Colors.blue),
                )
              : Text("Last seen: ${formatDate(widget.user.lastSeen)}"),
        ),
      ),
    );
  }
}

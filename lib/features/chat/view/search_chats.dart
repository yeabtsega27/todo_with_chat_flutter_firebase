import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/features/chat/view/chat_page.dart';
import 'package:todo_app_with_chat/features/chat/view/group_chat_page.dart';
import 'package:todo_app_with_chat/locator.dart';

class SearchChats extends StatefulWidget {
  const SearchChats({super.key});

  @override
  State<SearchChats> createState() => _SearchChatsState();
}

class _SearchChatsState extends State<SearchChats> {
  final TextEditingController _searchController = TextEditingController();

  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  List result = [];

  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    _navigationService = locator.get<NavigationService>();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) async {
            if (value.length > 2) {
              result = await _databaseService.globalSearch(value);
            } else {
              result = [];
            }
            setState(() {});
          },
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: result.length,
          itemBuilder: (context, i) {
            if (result[i] is ChatModel) {
              ChatModel chat = result[i];
              return GestureDetector(
                onTap: () async {
                  _navigationService.pushReplacementRoute(MaterialPageRoute(
                      builder: (context) => GroupChatPage(chatId: chat.id)));
                },
                child: GestureDetector(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: chat.groupPhoto.photoURL.isNotEmpty
                          ? NetworkImage(chat
                              .groupPhoto.photoURL) // Show the first photo URL
                          : null, // Set to null if no photo is available
                      child: chat.groupPhoto.photoURL.isEmpty
                          ? Text(chat.groupName[
                              0]) // Show the first letter of the username
                          : null, // Don't show text if there's a photo Fallback image
                    ),
                    title: Text(chat.groupName),
                    subtitle: Text("${chat.members.length} Members"),
                  ),
                ),
              );
            } else {
              UserModel user = result[i];
              return GestureDetector(
                onTap: () async {
                  String key = "";
                  Map<String, dynamic> res =
                      await _databaseService.checkChatExist(user);
                  if (res["status"]) {
                    key = res["key"];
                  } else {
                    key = await _databaseService.createNewPersonalChat(user);
                  }
                  if (key.isNotEmpty) {
                    _navigationService.pushReplacementRoute(MaterialPageRoute(
                        builder: (context) => ChatPage(chatId: res["key"])));
                  }
                },
                child: GestureDetector(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photos.isNotEmpty
                          ? NetworkImage(user.photos.first
                              .photoURL) // Show the first photo URL
                          : null, // Set to null if no photo is available
                      child: user.photos.isEmpty
                          ? Text(user.username[
                              0]) // Show the first letter of the username
                          : null, // Don't show text if there's a photo Fallback image
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                  ),
                ),
              );
            }
          }),
    );
  }
}

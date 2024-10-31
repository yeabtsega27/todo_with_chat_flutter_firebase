import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/core/models/messageModel.dart';
import 'package:todo_app_with_chat/core/utils/utils.dart';
import 'package:todo_app_with_chat/features/chat/view/group_chat_page.dart';
import 'package:todo_app_with_chat/locator.dart';

class GroupChatListCard extends StatefulWidget {
  final ChatModel chat;
  const GroupChatListCard({super.key, required this.chat});

  @override
  State<GroupChatListCard> createState() => _GroupChatListCardState();
}

class _GroupChatListCardState extends State<GroupChatListCard> {
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
    return ListTile(
      onTap: () {
        _navigationService.push(MaterialPageRoute(
            builder: (context) => GroupChatPage(chatId: widget.chat.id)));
      },
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: widget.chat.groupPhoto.photoURL.isNotEmpty
            ? NetworkImage(
                widget.chat.groupPhoto.photoURL) // Show the first photo URL
            : null, // Set to null if no photo is available
        child: widget.chat.groupPhoto.photoURL.isEmpty
            ? Text(widget
                .chat.groupName[0]) // Show the first letter of the username
            : null, // Don't show text if there's a photo Fallback image
      ),
      title: Text(widget.chat.groupName),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(formatDate(widget.chat.latestMessage.sendTime)),
          StreamBuilder<List<MessageModel>>(
              stream: _databaseService.unReadMessage(widget.chat.id),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const Text("");
                }

                int noOfUnRead = (snapshot.data ?? []).length;
                if (noOfUnRead == 0) {
                  return const Text("");
                }
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: Color(0xFF229ED9),
                        borderRadius: BorderRadius.circular(50)),
                    child: Text(
                      "$noOfUnRead",
                      style: const TextStyle(color: Colors.white),
                    ));
              }),
        ],
      ),
      subtitle: StreamBuilder(
          stream: _databaseService
              .getUserById(widget.chat.latestMessage.senderEmail),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const SizedBox();
            }
            return Row(
              children: [
                Text(
                  "${snapshot.data!.username}: ",
                  style: const TextStyle(color: Colors.blue),
                ),
                widget.chat.latestMessage.type == ""
                    ? const Text("Create the group",
                        style: TextStyle(color: Colors.blue))
                    : widget.chat.latestMessage.type == "text"
                        ? Text(widget.chat.latestMessage.content)
                        : const Text("1 Image",
                            style: TextStyle(color: Colors.blue))
              ],
            );
          }),
    );
  }
}

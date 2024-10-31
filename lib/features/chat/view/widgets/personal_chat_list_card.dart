import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/core/models/messageModel.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/core/utils/utils.dart';
import 'package:todo_app_with_chat/features/chat/view/chat_page.dart';
import 'package:todo_app_with_chat/locator.dart';

class PersonalChatListCard extends StatefulWidget {
  final ChatModel chat;
  const PersonalChatListCard({super.key, required this.chat});

  @override
  State<PersonalChatListCard> createState() => _PersonalChatListCardState();
}

class _PersonalChatListCardState extends State<PersonalChatListCard> {
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
    return StreamBuilder(
      stream: _databaseService.getUserById(
          FirebaseAuth.instance.currentUser!.email ==
                  widget.chat.members[0].email
              ? widget.chat.members[1].id
              : widget.chat.members[0].id),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        UserModel user = snapshot.data ?? UserModel.fromJson({});
        return ListTile(
          onTap: () {
            _navigationService.push(MaterialPageRoute(
              builder: (context) => ChatPage(chatId: widget.chat.id),
            ));
          },
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: widget.chat.groupPhoto.photoURL.isNotEmpty
                    ? NetworkImage(widget.chat.groupPhoto.photoURL)
                    : null,
                child: widget.chat.groupPhoto.photoURL.isEmpty
                    ? Text(
                        FirebaseAuth.instance.currentUser!.email ==
                                widget.chat.members[0].email
                            ? widget.chat.members[1].email[0]
                            : widget.chat.members[0].email[0],
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: user.online ? Colors.green : Colors.grey,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          title: Text(user.email),
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
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "$noOfUnRead",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
          subtitle: widget.chat.latestMessage.type == ""
              ? const SizedBox()
              : widget.chat.latestMessage.type == "text"
                  ? Text(
                      widget.chat.latestMessage.content,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    )
                  : const Text(
                      "1 Image",
                      style: TextStyle(color: Colors.blue),
                    ),
        );
      },
    );
  }
}

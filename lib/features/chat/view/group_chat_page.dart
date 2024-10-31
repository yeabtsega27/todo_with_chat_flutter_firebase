import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/core/models/messageModel.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/message_bubble.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/message_bubble_r.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/message_input.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/user_avatar.dart';
import 'package:todo_app_with_chat/locator.dart';

class GroupChatPage extends StatefulWidget {
  final String chatId;
  const GroupChatPage({super.key, required this.chatId});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  List<MessageModel> _cachedMessages = [];

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();

    _navigationService = locator.get<NavigationService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _databaseService.getChatById(widget.chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _cachedMessages.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        ChatModel chat = snapshot.data ?? ChatModel.fromJson({});
        bool isMember = chat.members.any((member) =>
            member.email == FirebaseAuth.instance.currentUser!.email);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF229ED9),
            leading: IconButton(
                onPressed: () {
                  _navigationService.goBack();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.groupName,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${chat.members.length} Members",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/bg.jpg'), // Replace with your image path
                      fit: BoxFit
                          .cover, // Fits the image to the width, cropping excess height
                    ),
                  ),
                  child: StreamBuilder<List<MessageModel>>(
                    stream:
                        _databaseService.getMessagesFromChatId(widget.chatId),
                    builder: (context, messageSnapshot) {
                      if (messageSnapshot.hasData) {
                        _cachedMessages = messageSnapshot.data!;
                      }

                      if (_cachedMessages.isEmpty &&
                          messageSnapshot.connectionState ==
                              ConnectionState.waiting) {
                        return const Center(child: Text("Loading..."));
                      }
                      if (_cachedMessages.isEmpty) {
                        return const Center(child: Text("No messages yet"));
                      }
                      List<MessageModel> messagesList =
                          messageSnapshot.data ?? [];

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: ListView.builder(
                          reverse: true,
                          itemCount: messagesList.length,
                          itemBuilder: (context, index) {
                            MessageModel message = messagesList[index];
                            // Use current user ID to determine if this message is sent by the user
                            bool isSender = message.senderEmail == uid;
                            bool showAvatar = index == 0 ||
                                _cachedMessages[index - 1].senderEmail !=
                                    message.senderEmail;

                            // Ensure `MessageBubble` receives correct sender info
                            return Row(
                              mainAxisAlignment: isSender
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isSender && showAvatar)
                                  UserAvatar(userId: message.senderEmail)
                                else if (!isSender)
                                  const SizedBox(
                                      width:
                                          35), // Spacer if avatar is not shown for continuous messages

                                isSender
                                    ? (MessageBubble(
                                        message: message,
                                        isSender: isSender,
                                        chatId: chat.id,
                                      ))
                                    : MessageBubbleR(
                                        message: message,
                                        isSender: isSender,
                                        chatId: chat.id,
                                      ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              MessageInput(
                isMember: isMember,
                chatId: chat.id,
              ),
            ],
          ),
        );
      },
    );
  }
}

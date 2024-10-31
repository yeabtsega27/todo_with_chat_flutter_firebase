import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/core/models/messageModel.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/core/utils/utils.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/message_bubble.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/message_bubble_r.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/message_input.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/show_avatar.dart';
import 'package:todo_app_with_chat/locator.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  List<MessageModel> _cachedMessages = [];
  bool isFirstMessage = false;

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
            title: StreamBuilder<UserModel>(
                stream: _databaseService.getUserById(
                    FirebaseAuth.instance.currentUser!.email ==
                            chat.members[0].email
                        ? chat.members[1].id
                        : chat.members[0].id),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox();
                  }
                  UserModel user = snapshot.data ?? UserModel.fromJson({});
                  return Row(
                    children: [
                      ShowAvatar(user: user),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                          user.lastSeen == "online"
                              ? const Text("online",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue))
                              : Text(formatDate(user.lastSeen),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70))
                        ],
                      )
                    ],
                  );
                }),
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
                        isFirstMessage = _cachedMessages.isEmpty;
                      }

                      if (_cachedMessages.isEmpty &&
                          messageSnapshot.connectionState ==
                              ConnectionState.waiting) {
                        return const Center(child: Text("Loading..."));
                      }
                      if (_cachedMessages.isEmpty) {
                        return const Center(child: Text("No messages yet"));
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: ListView.builder(
                          reverse: true,
                          itemCount: _cachedMessages.length,
                          itemBuilder: (context, index) {
                            MessageModel message = _cachedMessages[index];
                            String uid = FirebaseAuth.instance.currentUser!.uid;
                            bool isSender = message.senderEmail == uid;

                            return Row(
                              mainAxisAlignment: isSender
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
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
                isMember: true,
                chatId: chat.id,
              ),
            ],
          ),
        );
      },
    );
  }
}

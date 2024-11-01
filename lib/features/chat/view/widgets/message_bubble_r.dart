import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/messageModel.dart';
import 'package:todo_app_with_chat/core/utils/utils.dart';
import 'package:todo_app_with_chat/core/widgets/network_image_with_fallback.dart';
import 'package:todo_app_with_chat/locator.dart';

class MessageBubbleR extends StatefulWidget {
  final MessageModel message;
  final bool isSender;
  final String chatId;

  const MessageBubbleR({
    super.key,
    required this.message,
    required this.isSender,
    required this.chatId,
  });

  @override
  State<MessageBubbleR> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubbleR> {
  readMessage() {
    bool isRead = false;
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    for (String userId in widget.message.readUsers) {
      if (userId == uid) {
        isRead = true;
      }
    }
    if (!isRead) {
      locator
          .get<DatabaseService>()
          .readMessage(widget.chatId, widget.message.id);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    readMessage();
    return Row(
      mainAxisAlignment:
          widget.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.message.type == 'text')
          ChatBubble(
            clipper: ChatBubbleClipper2(type: BubbleType.receiverBubble),
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 20),
            backGroundColor: const Color(0xffffffff),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: 60,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      widget.message.content,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text(
                      formatDate(widget.message.sendTime),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(top: 15),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: 60,
                minHeight: 50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), // Rounded corners
              child: NetworkImageWithFallback(
                imageUrl: widget.message.mediaUrl.photoURL,
                fallbackAssetPath: 'assets/default_image.jpg',
              ),
            ),
          )
      ],
    );
  }
}

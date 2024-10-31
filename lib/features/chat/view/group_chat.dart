import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/group_chat_list_card.dart';
import 'package:todo_app_with_chat/locator.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late DatabaseService _databaseService;
  List<ChatModel> groupChats = [];
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _databaseService.getMyChats(true),
      builder: (BuildContext context, AsyncSnapshot<List<ChatModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Loading state
        }
        groupChats = snapshot.data ?? [];

        return ListView.builder(
            itemCount: groupChats.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, i) {
              ChatModel groupChat = groupChats[i];
              return GroupChatListCard(chat: groupChat);
            });
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/personal_chat_list_card.dart';
import 'package:todo_app_with_chat/locator.dart';

class PersonalChat extends StatefulWidget {
  const PersonalChat({super.key});

  @override
  State<PersonalChat> createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> {
  late DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _databaseService.getMyChats(false),
      builder: (BuildContext context, AsyncSnapshot<List<ChatModel>> snapshot) {
        if (snapshot.data == null) {
          return const Text("No chat found");
        }
        List<ChatModel> personalChats = snapshot.data ?? [];
        return Container(
          decoration: BoxDecoration(
              // color: Color(0xffaf2828),
              ),
          child: ListView.builder(
              itemCount: personalChats.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, i) {
                return PersonalChatListCard(chat: personalChats[i]);
              }),
        );
      },
    );
  }
}

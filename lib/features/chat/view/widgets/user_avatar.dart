import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/show_avatar.dart';
import 'package:todo_app_with_chat/locator.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  const UserAvatar({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = locator.get<DatabaseService>();

    return StreamBuilder<UserModel>(
      stream: databaseService.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const CircleAvatar(
            child: Icon(Icons.person),
          );
        }

        UserModel senderUser = snapshot.data ?? UserModel.fromJson({});
        return ShowAvatar(user: senderUser);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';

class ShowAvatar extends StatelessWidget {
  final UserModel user;
  const ShowAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: user.photos.isNotEmpty
          ? NetworkImage(user.photos.first.photoURL)
          : null,
      child: user.photos.isEmpty ? Text(user.email[0]) : null,
    );
  }
}

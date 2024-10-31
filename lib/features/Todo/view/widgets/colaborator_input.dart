import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/locator.dart';

class CollaboratorInput extends StatefulWidget {
  final String todoId;
  const CollaboratorInput({super.key, required this.todoId});

  @override
  State<CollaboratorInput> createState() => _CollaboratorInputState();
}

class _CollaboratorInputState extends State<CollaboratorInput> {
  late TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isEmailValid(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  late DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                  onPressed: () {}, icon: const Icon(Icons.person_add))),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email to share with',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                } else if (!_isEmailValid(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onEditingComplete: () {
                if (_formKey.currentState!.validate()) {
                  Users user = Users(
                    email: emailController.text,
                    type: "collaborator",
                  );
                  _databaseService.addUserToToDo(widget.todoId, user);
                  emailController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}

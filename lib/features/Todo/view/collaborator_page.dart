import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/features/Todo/view//widgets/colaborator_input.dart';
import 'package:todo_app_with_chat/locator.dart';

class CollaboratorPage extends StatefulWidget {
  final String todoId;
  const CollaboratorPage({super.key, required this.todoId});

  @override
  State<CollaboratorPage> createState() => _CollaboratorPageState();
}

class _CollaboratorPageState extends State<CollaboratorPage> {
  String? email = FirebaseAuth.instance.currentUser?.email;

  late DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: StreamBuilder(
            stream: _databaseService.getUsersFromToDo(widget.todoId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Scaffold(
                    body: Center(
                        child:
                            Text('Error: ${snapshot.error}'))); // Error state
              }
              List<Users> users = snapshot.data ?? [];

              return Column(
                children: [
                  ...List.generate(users.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Text(
                              users[i].email[0],
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              users[i].email,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          users[i].type != "owner"
                              ? IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Are you sure you remove this collaborator",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  DatabaseService()
                                                      .removeUserToToDo(
                                                          widget.todoId,
                                                          users[i]);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.close))
                              : const SizedBox(
                                  width: 10,
                                ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  users[0].email == email
                      ? CollaboratorInput(todoId: widget.todoId)
                      : const SizedBox(),
                ],
              );
            }),
      ),
    );
  }
}

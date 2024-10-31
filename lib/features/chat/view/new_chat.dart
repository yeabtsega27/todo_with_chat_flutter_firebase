import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/features/chat/view/widgets/user_card.dart';
import 'package:todo_app_with_chat/locator.dart';

class NewChat extends StatefulWidget {
  const NewChat({super.key});

  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    _navigationService = locator.get<NavigationService>();
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "New Chat",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _navigationService.pushNamed("/chatSearch");
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _navigationService.pushReplacement("/newGroupCreate");
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 30,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "New Group",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(color: Color(0xFFE1E1E1)),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
              child: Row(
                children: [
                  Text(
                    "Users",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _databaseService
                  .getUsers(), // Ensure this returns a List<UserModel>
              builder: (context, snapshot) {
                // Check connection state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // Loading state
                }
                // Check if snapshot has data
                if (snapshot.hasData && snapshot.data != null) {
                  List<UserModel> users =
                      snapshot.data!; // Use null-aware operator
                  return ListView.builder(
                    itemCount: users.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      UserModel user = users[index];
                      return UserCard(user: user);
                    },
                  );
                } else {
                  // Handle no data or error case
                  return const Center(child: Text("No users found."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

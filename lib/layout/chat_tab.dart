import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/features/chat/view/Personal_chat.dart';
import 'package:todo_app_with_chat/features/chat/view/group_chat.dart';
import 'package:todo_app_with_chat/locator.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  late NavigationService _navigationService;
  @override
  void initState() {
    _navigationService = locator.get<NavigationService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: const Color(0xFF229ED9),
                  title: const Text(
                    "Chat",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                    )
                  ],
                ),
                // Tab Bar
                Container(
                  color: const Color(
                      0xFF229ED9), // Background color for the TabBar container
                  child: const TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white, // Text color of the selected tab
                    unselectedLabelColor:
                        Colors.white70, // Text color of unselected tabs
                    tabs: [
                      Tab(text: 'Personal'),
                      Tab(text: 'Group'),
                    ],
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      PersonalChat(),
                      GroupChat(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Floating Action Button
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                _navigationService.pushNamed("/newChat");
              },
              child: Container(
                margin: const EdgeInsets.all(
                    16.0), // Optional: Add margin around the button
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0), // Adjust padding for size
                  child: Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 30, // Size of the icon
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

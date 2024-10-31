import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/Service/background_services.dart';
import 'package:todo_app_with_chat/features/Todo/view/to_do_page.dart';
import 'package:todo_app_with_chat/features/profileManagement/view/profile_page.dart';
import 'package:todo_app_with_chat/layout/chat_tab.dart';
import 'package:todo_app_with_chat/locator.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    ToDoPage(),
    ChatTab(),
    ProfilePage()
  ];
  @override
  void initState() {
    locator.get<BackgroundServices>().registerPeriodicTask();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains("resume")) {
        locator.get<DatabaseService>().updatedUserStates(true);
      }
      if (message.toString().contains("pause")) {
        locator.get<DatabaseService>().updatedUserStates(false);
      }
      return Future.value(message);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF229ED9), // Set background color to blue
        selectedItemColor: Colors.white, // Set selected item color to white
        unselectedItemColor: Colors
            .white70, // Set unselected item color to slightly transparent white
        currentIndex: _selectedIndex,
        onTap: (val) {
          setState(() {
            _selectedIndex = val;
          });
        },
        selectedFontSize:
            18.0, // Increase font size for selected item to create scaling effect
        unselectedFontSize: 14.0, // Set smaller font size for unselected items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

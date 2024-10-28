import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/features/Todo/view/to_do_page.dart';
import 'package:todo_app_with_chat/features/profileManagement/view/profile_page.dart';
import 'package:todo_app_with_chat/layout/chat_tab.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue, // Set background color to blue
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

import 'package:flutter/material.dart';

class SearchChats extends StatefulWidget {
  const SearchChats({super.key});

  @override
  State<SearchChats> createState() => _SearchChatsState();
}

class _SearchChatsState extends State<SearchChats> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

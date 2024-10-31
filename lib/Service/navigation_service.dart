import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/features/authentication/view//auth_screen.dart';
import 'package:todo_app_with_chat/features/chat/view/new_chat.dart';
import 'package:todo_app_with_chat/features/chat/view/new_group_create.dart';
import 'package:todo_app_with_chat/features/chat/view/search_chats.dart';
import 'package:todo_app_with_chat/features/splash_screen.dart';
import 'package:todo_app_with_chat/layout/homeLayout.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;
  final Map<String, Widget Function(BuildContext)> _routes = {
    "/auth": (context) => const AuthScreen(),
    "/splash": (context) => const SplashScreen(),
    "/home": (context) => const HomeLayout(),
    "/chatSearch": (context) => const SearchChats(),
    "/newChat": (context) => const NewChat(),
    "/newGroupCreate": (context) => const NewGroupCreate(),
  };

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  GlobalKey<NavigatorState> get navigatorKey {
    return _navigatorKey;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }
  void pushReplacement(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushReplacementRoute(MaterialPageRoute route) {
    _navigatorKey.currentState?.pushReplacement(route);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}

//, (Route<dynamic> router) => false

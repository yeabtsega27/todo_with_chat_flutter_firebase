import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/features/authentication/view//auth_screen.dart';
import 'package:todo_app_with_chat/features/splash_screen.dart';
import 'package:todo_app_with_chat/layout/homeLayout.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;
  final Map<String, Widget Function(BuildContext)> _routes = {
    "/auth": (context) => const AuthScreen(),
    "/splash": (context) => const SplashScreen(),
    "/home": (context) => const HomeLayout(),
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
    _navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (Route<dynamic> router) => false);
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}

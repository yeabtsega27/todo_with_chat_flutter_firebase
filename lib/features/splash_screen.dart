import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/auth_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late NavigationService _navigationService;
  @override
  void initState() {
    _navigationService = locator.get<NavigationService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF229ED9), // Set your desired background color
        body: StreamBuilder(
            stream: locator.get<AuthService>().isUserLogin(),
            builder: (context, snapshot) {
              Timer(const Duration(seconds: 3), () async {
                if (snapshot.connectionState == ConnectionState.active) {
                  User? user = snapshot.data;
                  if (user == null) {
                    // User is not signed in, show the Authentication page
                    _navigationService.pushReplacement("/auth");
                  } else {
                    _navigationService.pushReplacement("/home");
                  }
                }
              });

              return const Center(
                child: Text(
                  'Welcome', // Replace with your desired text
                  style: TextStyle(
                    fontSize: 36, // Adjust the font size as needed
                    fontWeight: FontWeight.bold, // Make the text bold
                    color: Colors.white, // Set text color
                  ),
                ),
              );
            }));
  }
}

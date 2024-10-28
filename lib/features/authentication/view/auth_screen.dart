import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/features/authentication/view//widgets/sign_in_form.dart';
import 'package:todo_app_with_chat/features/authentication/view/widgets/sign_up_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Sign In and Sign Up
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign In / Sign Up'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sign In'),
              Tab(text: 'Sign Up'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SignInForm(), // Sign In form
            const SignUpForm(), // Sign Up form
          ],
        ),
      ),
    );
  }
}

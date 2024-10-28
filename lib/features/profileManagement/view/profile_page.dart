import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/alert_service.dart';
import 'package:todo_app_with_chat/Service/auth_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/locator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AlertService _alertService;
  late NavigationService _navigationService;
  @override
  void initState() {
    super.initState();
    _alertService = locator.get<AlertService>();
    _navigationService = locator.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
            onPressed: () async {
              final currentContext = context; // Capture the context early

              bool result = await locator.get<AuthService>().logOut();
              if (!result) {
                if (currentContext.mounted) {
                  // Check if context is still valid
                  _alertService.showAlert(
                      currentContext, "error while log out", AlertType.error);
                }
              } else {
                // Navigator/
                if (currentContext.mounted) {
                  _alertService.showAlert(
                      currentContext, "you have log out", AlertType.info);
                }
                _navigationService.pushReplacement("/auth");
              }
            },
            icon: const Icon(Icons.logout)),
      ),
    );
  }
}

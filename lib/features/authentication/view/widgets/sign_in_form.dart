import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/alert_service.dart';
import 'package:todo_app_with_chat/Service/auth_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/locator.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _alertService = locator.get<AlertService>();
    _authService = locator.get<AuthService>();
    _navigationService = locator.get<NavigationService>();
  }

  Future<void> _signIn() async {
    final currentContext = context;
    try {
      bool res = await _authService.loginUser(email, password);

      if (currentContext.mounted) {
        if (res) {
          _alertService.showAlert(
              currentContext, "you have successfully login", AlertType.success);
          _navigationService.pushReplacement("/home");
        }
        _alertService.showAlert(
            currentContext, "failed to login", AlertType.error);
      }
    } catch (e) {
      if (currentContext.mounted) {
        _alertService.showAlert(currentContext, "Error:$e", AlertType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signIn();
                  }
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

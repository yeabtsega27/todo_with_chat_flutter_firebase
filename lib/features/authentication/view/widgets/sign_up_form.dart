import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/alert_service.dart';
import 'package:todo_app_with_chat/Service/auth_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/locator.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  @override
  void initState() {
    super.initState();
    _authService = locator.get<AuthService>();
    _navigationService = locator.get<NavigationService>();
    _alertService = locator.get<AlertService>();
  }

  Future<void> _signUp() async {
    final currentContext = context;
    try {
      bool u = await _authService.registerUser(
          emailController.text, passwordController.text, nameController.text);
      if (currentContext.mounted) {
        if (u) {
          _alertService.showAlert(
              currentContext, "you have successfully login", AlertType.success);
          _navigationService.pushReplacement("/home");
        } else {
          _alertService.showAlert(
              currentContext, "you have successfully login", AlertType.error);
        }
      }
    } catch (e) {
      if (currentContext.mounted) {
        _alertService.showAlert(currentContext, "Error :$e", AlertType.error);
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
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.name,
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
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
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be grater than 6 char';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                controller: confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be grater than 6 char';
                  }
                  if (!(value == passwordController.text)) {
                    return 'Password dose not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signUp();
                  }
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

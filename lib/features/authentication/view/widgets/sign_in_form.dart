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
        } else {
          _alertService.showAlert(
              currentContext, "failed to login", AlertType.error);
        }
      }
    } catch (e) {
      if (currentContext.mounted) {
        _alertService.showAlert(currentContext, "Error:$e", AlertType.error);
      }
    }
  }

  bool obscureText = true;
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
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.grey[600], // Label color
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your email',
                  hintStyle:
                      TextStyle(color: Colors.grey[400]), // Hint text color
                  prefixIcon: Icon(
                    Icons.email,
                    color: Color(0xFF229ED9), // Icon color to match underline
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF229ED9),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF229ED9),
                      width: 2.0,
                    ),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.grey[600], // Label color
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color(0xFF229ED9),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.visibility_off, // Default icon
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF229ED9),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF229ED9),
                      width: 2.0,
                    ),
                  ),
                ),
                obscureText: obscureText, // Toggles visibility
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF229ED9), // Primary color
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 24.0), // Adjust padding for a larger button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  elevation: 5, // Slight elevation for depth
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // Text color
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

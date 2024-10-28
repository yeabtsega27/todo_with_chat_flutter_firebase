import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/locator.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setUp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late NavigationService _navigationService;
  MyApp({super.key}) {
    _navigationService = locator.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: _navigationService.routes,
      initialRoute: "/splash",
    );
  }
}

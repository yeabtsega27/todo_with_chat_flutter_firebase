import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:workmanager/workmanager.dart';

callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await Firebase.initializeApp();
    if (taskName == "newMessage") {
      print("Task execute: $taskName");
      await DatabaseService()
          .getUnReadMessages(inputData?["uid"], inputData?["email"]);
    }
    return Future.value(true);
  });
}

class BackgroundServices {
  BackgroundServices() {
    Workmanager().initialize(callbackDispatcher);
  }

  void registerPeriodicTask() {
    var email = FirebaseAuth.instance.currentUser?.email ?? "";
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    Workmanager().registerPeriodicTask("taskName", "newMessage",
        frequency: const Duration(minutes: 1),
        inputData: {"uid": uid, "email": email});
  }

  void registerOneOffTask() {
    var email = FirebaseAuth.instance.currentUser?.email ?? "";
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    Workmanager().registerOneOffTask("taskName1", "newMessage",
        initialDelay: const Duration(seconds: 1),
        inputData: {"uid": uid, "email": email});
  }

  void cancelAll() {
    Workmanager().cancelAll();
  }

  void remove() {
    Workmanager().cancelByUniqueName("taskName1");
  }
}

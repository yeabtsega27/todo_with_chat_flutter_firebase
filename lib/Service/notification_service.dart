import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/features/chat/view/chat_page.dart';
import 'package:todo_app_with_chat/features/chat/view/group_chat_page.dart';
import 'package:todo_app_with_chat/locator.dart';

// Initialize the notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Your app icon

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        onNotificationTap(response.payload!);
      }
    },
    onDidReceiveBackgroundNotificationResponse:
        (NotificationResponse response) {
      if (response.payload != null) {
        onNotificationTap(response.payload!);
      }
    },
  );
}

// Handle navigation when a notification is tapped
Future<void> onNotificationTap(String chatId) async {
  if (chatId[0] == "1") {
    locator.get<NavigationService>().push(MaterialPageRoute(
        builder: (context) => GroupChatPage(chatId: chatId.substring(1))));
  } else {
    locator.get<NavigationService>().push(MaterialPageRoute(
        builder: (context) => ChatPage(chatId: chatId.substring(1))));
  }
}

// Show a notification with the chat ID as payload
Future<void> showChatNotification(
    String chatId, String message, int id, String name) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    chatId, // Channel ID
    name, // Channel name
    playSound: true,
    importance: Importance.max,
    priority: Priority.max,
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id, // Notification ID
    name,
    message,
    platformChannelSpecifics,
    payload: chatId, // Chat ID as payload
  );
}

// Cancel a specific notification
Future<void> cancel(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

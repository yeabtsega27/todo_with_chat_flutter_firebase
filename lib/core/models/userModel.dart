import 'package:todo_app_with_chat/core/models/photoModel.dart';

class UserModel {
  String userId;
  String username;
  String email;
  bool online;
  String lastSeen;
  List<Photo> photos;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.photos,
    required this.online,
    required this.lastSeen,
  });

  // Convert UserModel to JSON (for storing in Firebase Realtime Database)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'photos': photos.map((photo) => photo.toJson()).toList(),
      "online": online,
      "lastSeen": lastSeen
    };
  }

  // Create UserModel from JSON (for retrieving from Firebase Realtime Database)
  factory UserModel.fromJson(Map<String, dynamic>? json) {
    return UserModel(
      userId: json?['userId'] ?? "",
      username: json?['username'] ?? "",
      email: json?['email'] ?? "",
      photos: (json?['photos'] as List).map((e) => Photo.fromJson(e)).toList(),
      online: json?['online'] ?? "",
      lastSeen: json?['lastSeen'] ?? "",
    );
  }
}

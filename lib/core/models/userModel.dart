class UserModel {
  String userId;
  String username;
  String email;
  bool online;
  String lastSeen;
  List<ProfilePhoto> photos;

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
      userId: json?['userId'],
      username: json?['username'],
      email: json?['email'],
      photos: (json?['photos'] as List)
          .map((e) => ProfilePhoto.fromJson(e))
          .toList(),
      online: json?['online'],
      lastSeen: json?['lastSeen'],
    );
  }
}

// Define the Photo class to store photoURL and uploadTime
class ProfilePhoto {
  String photoURL;
  DateTime uploadTime;

  ProfilePhoto({
    required this.photoURL,
    required this.uploadTime,
  });

  // Convert Photo to JSON
  Map<String, dynamic> toJson() {
    return {
      'photoURL': photoURL,
      'uploadTime': uploadTime.toIso8601String(),
    };
  }

  // Create Photo from JSON
  factory ProfilePhoto.fromJson(Map<String, dynamic>? json) {
    return ProfilePhoto(
      photoURL: json?['photoURL'],
      uploadTime: DateTime.parse(json?['uploadTime']),
    );
  }
}

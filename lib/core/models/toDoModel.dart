import 'package:todo_app_with_chat/core/models/photoModel.dart';

class ToDoModel {
  final String id;
  final String title;
  final String note;
  final String createdAt;
  final String updatedAt;
  final List<Users> users;
  final List<Photo> photos;
  final List<CheckBox> checkBoxList;
  final bool pined;
  final String priority;

  ToDoModel(
      {required this.id,
      required this.title,
      required this.priority,
      required this.note,
      required this.createdAt,
      required this.updatedAt,
      required this.users,
      required this.photos,
      required this.checkBoxList,
      required this.pined});

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "id": id,
      "note": note,
      "createdAt": createdAt.toString(),
      "updatedAt": updatedAt.toString(),
      "users": users.map((user) => user.toJson()),
      "photo": photos.map((photo) => photo.toJson()),
      "checkBoxList": checkBoxList.map((checkBox) => checkBox.toJson()),
      "pined": pined
    };
  }

  factory ToDoModel.fromJson(Map<String, dynamic>? json) => ToDoModel(
        id: json?["id"] ?? '', // Default value if null
        title: json?["title"] ?? '',
        note: json?["note"] ?? '',
        createdAt:
            json?["createdAt"] ?? DateTime.now().toString(), // Set a default
        updatedAt:
            json?["updatedAt"] ?? DateTime.now().toString(), // Set a default
        users: (json?["users"] as List<dynamic>? ?? [])
            .map((e) => Users.fromJson(e))
            .toList(),
        photos: (json?["photos"] as List<dynamic>? ?? [])
            .map((e) => Photo.fromJson(e))
            .toList(),
        checkBoxList: (json?["checkBoxList"] as List<dynamic>? ?? [])
            .map((e) => CheckBox.fromJson(e))
            .toList(),
        pined: json?["pined"] ?? false, // Default value if null
        priority: json?["priority"] ?? '',
      );
}

class Users {
  final String type;
  final String email;

  Users({required this.email, required this.type});

  Map<String, dynamic> toJson() {
    return {"email": email, "type": type};
  }

  factory Users.fromJson(Map<String, dynamic>? json) =>
      Users(type: json?["type"], email: json?["email"]);
}

class CheckBox {
  final String id;
  final String note;
  final String status;
  final String priority;
  CheckBox(
      {required this.note,
      this.id = "0",
      required this.status,
      required this.priority});
  Map<String, dynamic> toJson() {
    return {"note": note, "status": status, "priority": priority};
  }

  factory CheckBox.fromJson(Map<String, dynamic> json) => CheckBox(
      note: json["note"] ?? "",
      status: json["status"] ?? "",
      priority: json["priority"] ?? "",
      id: json["id"] ?? "");
}

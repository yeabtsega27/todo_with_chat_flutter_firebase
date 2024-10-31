import 'package:todo_app_with_chat/core/models/messageModel.dart';
import 'package:todo_app_with_chat/core/models/photoModel.dart';

class ChatModel {
  final String id;
  final bool isGroup;
  final List<Member> members;
  final Photo groupPhoto;
  final MessageModel latestMessage;
  final String latestTime;
  final String createdBy;
  final String createdAt;
  final String groupName;

  ChatModel(
      {required this.id,
      required this.isGroup,
      required this.members,
      required this.groupPhoto,
      required this.latestMessage,
      required this.latestTime,
      required this.createdBy,
      required this.groupName,
      required this.createdAt});

  Map<String, dynamic> toJson() => {
        "id": id,
        "isGroup": isGroup,
        "members": members.map((e) => e.toJson()),
        "groupPhoto": groupPhoto.toJson(),
        "latestMessage": latestMessage.toJson(),
        "latestTime": latestTime.toString(),
        "createdBy": createdBy,
        "createdAt": createdAt.toString(),
        "groupName": groupName.toString(),
      };
  factory ChatModel.fromJson(Map<String, dynamic>? json) => ChatModel(
      id: json?["id"] ?? "",
      isGroup: json?["isGroup"] ?? "",
      members:
          (json?["members"] as List).map((e) => Member.fromJson(e)).toList(),
      groupPhoto: Photo.fromJson(json?["groupPhoto"] ?? {}),
      latestMessage: MessageModel.fromJson(json?["latestMessage"] ?? {}),
      latestTime: json?["latestTime"] ?? "",
      createdBy: json?["createdBy"] ?? "",
      createdAt: json?["createdAt"] ?? "",
      groupName: json?["groupName"] ?? "");
}

class Member {
  final String id;
  final String email;
  final bool status;
  Member({required this.email, required this.id, required this.status});
  Map<String, dynamic> toJson() => {"email": email, "id": id, "status": status};

  factory Member.fromJson(Map<String, dynamic>? json) => Member(
      email: json?["email"], status: json?["status"], id: json?["id"] ?? "");
}

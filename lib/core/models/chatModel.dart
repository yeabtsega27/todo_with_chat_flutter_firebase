import 'package:todo_app_with_chat/core/models/photoModel.dart';

class ChatModel {
  final String id;
  final bool isGroup;
  final List<Member> members;
  final Photo groupPhoto;
  final String latestMessage;
  final String latestTime;
  final String createdBy;
  final String createdAt;

  ChatModel(
      {required this.id,
      required this.isGroup,
      required this.members,
      required this.groupPhoto,
      required this.latestMessage,
      required this.latestTime,
      required this.createdBy,
      required this.createdAt});

  Map<String, dynamic> toJson() => {
        "id": id,
        "isGroup": isGroup,
        "members": members,
        "groupPhoto": groupPhoto,
        "latestMessage": latestMessage,
        "latestTime": latestTime.toString(),
        "createdBy": createdBy,
        "createdAt": createdAt.toString(),
      };
  factory ChatModel.formJson(Map<String, dynamic> json) => ChatModel(
      id: json["id"],
      isGroup: json["isGroup"],
      members: json["members"],
      groupPhoto: json["groupPhoto"],
      latestMessage: json["latestMessage"],
      latestTime: json["latestTime"],
      createdBy: json["createdBy"],
      createdAt: json["createdAt"]);
}

class Member {
  final String email;
  final bool status;
  Member({required this.email, required this.status});
  Map<String, dynamic> toJson() => {"email": email, "status": status};

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(email: json["email"], status: json["status"]);
}

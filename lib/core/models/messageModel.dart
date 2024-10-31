import 'package:todo_app_with_chat/core/models/photoModel.dart';

class MessageModel {
  final String id;
  final String senderEmail;
  final String type;
  final String content;
  final Photo mediaUrl;
  final String sendTime;
  final List<String> readUsers;

  MessageModel(
      {required this.id,
      required this.senderEmail,
      required this.type,
      required this.content,
      required this.mediaUrl,
      required this.readUsers,
      required this.sendTime});

  Map<String, dynamic> toJson() => {
        "id": id,
        "senderEmail": senderEmail,
        "type": type,
        "content": content,
        "mediaUrl": mediaUrl.toJson(),
        "sendTime": sendTime,
        "readUsers": readUsers,
      };

  factory MessageModel.fromJson(Map<String, dynamic>? json) => MessageModel(
        id: json?["id"],
        senderEmail: json?["senderEmail"],
        type: json?["type"],
        content: json?["content"],
        mediaUrl: Photo.fromJson(json?["mediaUrl"] ?? {}),
        sendTime: json?["sendTime"],
        readUsers:
            (json?["readUsers"] as List).map((e) => e.toString()).toList(),
      );
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/locator.dart';

class MessageInput extends StatefulWidget {
  final bool isMember;
  final String chatId;
  const MessageInput({
    super.key,
    required this.isMember,
    required this.chatId,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late DatabaseService _databaseService;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print("Image selected: ${pickedFile.path}");
      File file = File(pickedFile.path);
      await _databaseService.sendImageMessage(
          widget.chatId, _textController.text, file);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMember) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _textController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                _textController.text.isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: _pickImage,
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          _databaseService.sendTextMessage(
                              widget.chatId, _textController.text);
                          _textController.text = "";
                        },
                      ),
              ],
            ),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () => _databaseService.joinGroup(widget.chatId),
        child: const Center(
          child: Text(
            "Join",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
  }
}

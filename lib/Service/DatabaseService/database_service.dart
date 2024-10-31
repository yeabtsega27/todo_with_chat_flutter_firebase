import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_app_with_chat/Service/notification_service.dart';
import 'package:todo_app_with_chat/core/models/chatModel.dart';
import 'package:todo_app_with_chat/core/models/messageModel.dart';
import 'package:todo_app_with_chat/core/models/photoModel.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/core/utils/utils.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;

  final storageRef = FirebaseStorage.instance.ref();

  DatabaseService() {
    setUpCollectionReference();
  }
  CollectionReference? _usersCollection;
  CollectionReference? _todosCollection;
  CollectionReference? _chatsCollection;
  void setUpCollectionReference() {
    _usersCollection = _firebaseFireStore
        .collection("users")
        .withConverter<UserModel>(
            fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()),
            toFirestore: (user, _) => user.toJson());
    _todosCollection = _firebaseFireStore
        .collection("todos")
        .withConverter<ToDoModel>(
            fromFirestore: (snapshot, _) => ToDoModel.fromJson(snapshot.data()),
            toFirestore: (user, _) => user.toJson());
    _chatsCollection = _firebaseFireStore
        .collection("chats")
        .withConverter<ChatModel>(
            fromFirestore: (snapshot, _) => ChatModel.fromJson(snapshot.data()),
            toFirestore: (user, _) => user.toJson());
  }

  CollectionReference<MessageModel> getMessagesCollection(String chatId) {
    return _chatsCollection!
        .doc(chatId)
        .collection("messages")
        .withConverter<MessageModel>(
          fromFirestore: (snapshot, _) =>
              MessageModel.fromJson(snapshot.data()!),
          toFirestore: (message, _) => message.toJson(),
        );
  }

  Future<void> addUser(UserModel user) async {
    try {
      return await _usersCollection?.doc(user.userId).set(user);
    } catch (error) {
      print('Error adding user: $error');
    }
  }

  Future<void> updatedAtToDo(String todoId) async {
    await _firebaseFireStore
        .collection("todos")
        .doc(todoId)
        .update({"updatedAt": DateTime.now().toString()});
  }

  Future<void> updatedUserStates(bool online) async {
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    await _firebaseFireStore
        .collection("users")
        .doc(uid)
        .update({"lastSeen": DateTime.now().toString(), "online": online});
  }

  Stream<List<ToDoModel>>? getMyToDo() {
    var email = FirebaseAuth.instance.currentUser?.email ?? "";
    Map<dynamic, dynamic> u = {"email": email, "type": "owner"};
    Map<dynamic, dynamic> v = {"email": email, "type": "collaborator"};
    return _todosCollection
        ?.orderBy("updatedAt", descending: true)
        .where('users', arrayContainsAny: [u, v])
        .snapshots()
        .map((snapshot) {
          var list = snapshot.docs.map<ToDoModel>((doc) {
            return doc.data() as ToDoModel;
          }).toList();
          return list;
        });
  }

  Stream<List<Users>>? getUsersFromToDo(String todoId) {
    return _todosCollection!.doc(todoId).snapshots().map((snapshot) {
      ToDoModel todo = snapshot.data() as ToDoModel;
      return todo.users;
    });
  }

  Stream<ToDoModel>? getToDoById(String id) {
    return _todosCollection!.doc(id).snapshots().map((snapshot) {
      return snapshot.data() as ToDoModel;
    });
  }

  Future<String> createToDo() async {
    try {
      String key = _todosCollection!.doc().id;
      User? user = FirebaseAuth.instance.currentUser;
      String email = user!.email ?? "";
      Users owner = Users(
        email: email,
        type: "owner",
      );
      ToDoModel newTodo = ToDoModel(
          id: key,
          title: "",
          priority: "",
          note: "",
          createdAt: DateTime.now().toString(),
          updatedAt: DateTime.now().toString(),
          users: [owner],
          photos: [],
          checkBoxList: [],
          pined: false);
      await _todosCollection?.doc(key).set(newTodo);
      return key;
    } catch (error) {
      print('Error updating user status: $error');
      return "";
    }
  }

  Future<bool> deleteToDo(String todoId) async {
    try {
      var todoRef = _firebaseFireStore.collection("todos").doc(todoId);
      await todoRef.delete();
      return true;
    } catch (error) {
      print('Error updating user status: $error');
    }
    return false;
  }

  Future<void> addUserToToDo(String todoId, Users user) async {
    try {
      var todoUsersRef = _todosCollection!.doc(todoId);
      // Use push() to add a new user with a unique key
      await todoUsersRef.update({
        "users": FieldValue.arrayUnion([user.toJson()])
      });
      updatedAtToDo(todoId);
      print('User added successfully to ToDo ID: $todoId');
    } catch (error) {
      print('Error adding user to todo: $error');
    }
  }

  Future<void> removeUserToToDo(String todoId, Users user) async {
    try {
      var todoUsersRef = _todosCollection!.doc(todoId);
      await todoUsersRef.update({
        "users": FieldValue.arrayRemove([user.toJson()])
      });
      updatedAtToDo(todoId);
      print('User remove successfully from ToDo ID: $todoId');
    } catch (error) {
      print('Error adding user to todo: $error');
    }
  }

  Future<bool> addPhotoToToDo(String todoId, Photo photo) async {
    try {
      var todoRef = _firebaseFireStore.collection("todos").doc(todoId);
      await todoRef.update({
        "photos": FieldValue.arrayUnion([photo.toJson()])
      });

      await updatedAtToDo(todoId);

      return true;
    } catch (error) {
      print('Error adding photo to todo: $error');
    }
    return false;
  }

  Future<void> removePhotoFromToDo(String todoId, Photo photo) async {
    try {
      var todoPhotosRef = _todosCollection!.doc(todoId);

      await todoPhotosRef.update({
        "photos": FieldValue.arrayRemove([photo.toJson()])
      });
      updatedAtToDo(todoId);
      print('Photo remove successfully from ToDo ID: $todoId');
    } catch (error) {
      print('Error removing photo from todo: $error');
    }
  }

  Future<void> pinUnPinToDo(String todoId, BuildContext context) async {
    try {
      var pinedRef = _firebaseFireStore.collection("todos").doc(todoId);
      var snapshot = await pinedRef.get();

      bool value = snapshot.data()?["pined"] as bool? ?? false;

      await pinedRef.update({"pined": !value});

      await updatedAtToDo(todoId);
    } catch (error) {
      print('Error pinning/unpinning todo: $error');
    }
  }

  Future<void> editToDoTitle(String todoId, String title) async {
    try {
      var pinedRef = _firebaseFireStore.collection("todos").doc(todoId);
      await pinedRef.update({"title": title});
      updatedAtToDo(todoId);
    } catch (error) {
      print('Error Pining todo: $error');
    }
  }

  Future<void> editToDoNote(String todoId, String title) async {
    try {
      var pinedRef = _firebaseFireStore.collection("todos").doc(todoId);
      pinedRef.update({"note": title});
      updatedAtToDo(todoId);
    } catch (error) {
      print('Error Pining todo: $error');
    }
  }

  Future<Map<String, dynamic>> uploadImageToFirebase(
      String to, File imageFile) async {
    String fileName = const Uuid().v4();
    final uploadTask = storageRef.child("$to/$fileName").putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    final imageMetadata = await snapshot.ref.getMetadata();

    return {"downloadUrl": downloadUrl, "imageMetadata": imageMetadata};
  }

  Future<bool> removeImageFromFirebase(Photo photo, String todoId) async {
    try {
      await storageRef.child(photo.path).delete();
      await removePhotoFromToDo(todoId, photo);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> createNewGroupChat(
    Photo photo,
    String groupName,
  ) async {
    String key = _chatsCollection!.doc().id;

    User? user = FirebaseAuth.instance.currentUser;
    String email = user!.email ?? "";
    String uid = user.uid;
    Member member = Member(email: email, status: true, id: uid);
    MessageModel message = emptyMessage(uid);
    ChatModel newChat = ChatModel(
        id: key,
        isGroup: true,
        members: [member],
        groupPhoto: photo,
        latestMessage: message,
        latestTime: DateTime.now().toString(),
        createdBy: email,
        createdAt: DateTime.now().toString(),
        groupName: groupName);
    await _chatsCollection!.doc(key).set(newChat);
    return key;
  }

  Stream<List<UserModel>>? getUsers() {
    return _usersCollection
        ?.orderBy("lastSeen", descending: true)
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs.map<UserModel>((doc) {
        return doc.data() as UserModel;
      }).toList();
      return list;
    });
  }

  checkChatExist(UserModel user) async {
    User? u = FirebaseAuth.instance.currentUser;
    String uid = u!.uid;
    String key = generatePersonChatId(uid, user.userId);
    var chatRef = _chatsCollection!.doc(key);
    var snapshot = await chatRef.get();

    if (snapshot.data() != null) {
      return {"key": key, "status": true};
    }
    return {"key": key, "status": false};
  }

  Future<String> createNewPersonalChat(UserModel user) async {
    User? u = FirebaseAuth.instance.currentUser;
    String uid = u!.uid;
    String key = generatePersonChatId(uid, user.userId);

    String email = u.email ?? "";
    Member member = Member(email: email, status: true, id: uid);
    Member member2 = Member(email: user.email, status: true, id: user.userId);
    MessageModel message = emptyMessage(uid);

    ChatModel newChat = ChatModel(
        id: key,
        isGroup: false,
        members: [member, member2],
        groupPhoto: Photo(photoURL: "", uploadTime: DateTime.now(), path: ""),
        latestMessage: message,
        latestTime: DateTime.now().toString(),
        createdBy: email,
        createdAt: DateTime.now().toString(),
        groupName: "");
    await _chatsCollection!.doc(key).set(newChat);
    return key;
  }

  Stream<List<ChatModel>>? getMyChats(bool isGroup) {
    var email = FirebaseAuth.instance.currentUser?.email ?? "";
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    Map<dynamic, dynamic> u = {"email": email, "status": true, "id": uid};
    return _chatsCollection
        ?.orderBy("latestTime", descending: true)
        .where('members', arrayContainsAny: [u])
        .where('isGroup', isEqualTo: isGroup)
        .snapshots()
        .map((snapshot) {
          var list = snapshot.docs.map<ChatModel>((doc) {
            return doc.data() as ChatModel;
          }).toList();
          return list;
        });
  }

  Future<List> globalSearch(String search) async {
    List result = [];
    var group = await _chatsCollection!
        .where("isGroup", isEqualTo: true)
        .where("groupName", isGreaterThanOrEqualTo: search)
        .where("groupName", isLessThan: '$search\uf8ff')
        .get();
    var user = await _usersCollection!
        .where("email", isGreaterThanOrEqualTo: search)
        .where("email", isLessThan: '$search\uf8ff')
        .get();

    for (var e in group.docs) {
      result.add(e.data() as ChatModel);
    }
    for (var e in user.docs) {
      result.add(e.data() as UserModel);
    }
    return result;
  }

  Stream<UserModel> getUserById(String userId) {
    return _usersCollection!.doc(userId).snapshots().map<UserModel>((e) {
      return e.data() as UserModel;
    });
  }

  Stream<ChatModel> getChatById(String chatId) {
    return _chatsCollection!.doc(chatId).snapshots().map<ChatModel>((e) {
      return e.data() as ChatModel;
    });
  }

  Future joinGroup(String chatId) async {
    var email = FirebaseAuth.instance.currentUser?.email ?? "";
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    _chatsCollection!.doc(chatId).update({
      "members": FieldValue.arrayUnion([
        {"email": email, "status": true, "id": uid}
      ])
    });
  }

  sendTextMessage(String chatId, String message) async {
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    String key = getMessagesCollection(chatId).doc().id;
    MessageModel newMessage = MessageModel(
        id: key,
        senderEmail: uid,
        type: "text",
        content: message,
        mediaUrl: Photo.fromJson({}),
        sendTime: DateTime.now().toString(),
        readUsers: [uid]);
    await getMessagesCollection(chatId).doc(key).set(newMessage);
    await updateLatestMessage(chatId, newMessage);
  }

  readMessage(String chatId, String messageId) async {
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    await getMessagesCollection(chatId).doc(messageId).update({
      "readUsers": FieldValue.arrayUnion([uid])
    });
  }

  sendImageMessage(String chatId, String message, File imageFile) async {
    var imageData = await uploadImageToFirebase("messages", imageFile);
    Photo photo = Photo(
        photoURL: imageData["downloadUrl"],
        uploadTime: DateTime.now(),
        path: (imageData["imageMetadata"] as FullMetadata).fullPath);
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    String key = getMessagesCollection(chatId).doc().id;
    MessageModel newMessage = MessageModel(
        id: key,
        senderEmail: uid,
        type: "media",
        content: message,
        mediaUrl: photo,
        sendTime: DateTime.now().toString(),
        readUsers: [uid]);
    await getMessagesCollection(chatId).doc(key).set(newMessage);
    await updateLatestMessage(chatId, newMessage);
  }

  updateLatestMessage(String chatId, MessageModel message) async {
    await _chatsCollection!.doc(chatId).update({
      "latestMessage": message.toJson(),
      "latestTime": DateTime.now().toString()
    });
  }

  Stream<List<MessageModel>> getMessagesFromChatId(String chatId) {
    return getMessagesCollection(chatId)
        .orderBy("sendTime", descending: true)
        .snapshots()
        .map((snapshot) {
      List<MessageModel> list = snapshot.docs.map<MessageModel>((message) {
        return message.data();
      }).toList();
      return list;
    });
  }

  Stream<List<MessageModel>> unReadMessage(String chatId) {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return getMessagesCollection(chatId).snapshots().map((snapshot) {
      List<MessageModel> unreadMessages = snapshot.docs
          .map<MessageModel>((message) => message.data())
          .where((message) => !(message.readUsers.contains(uid)))
          .toList();
      return unreadMessages;
    });
  }

  Future<void> getUnReadMessages(String uid, String email) async {
    Map<String, dynamic> user = {"email": email, "status": true, "id": uid};
    int id = 0;

    // Get chats where the user is a member
    var snapshot = await _chatsCollection
        ?.where('members', arrayContainsAny: [user]).get();

    // Iterate through each chat
    for (var doc in snapshot!.docs) {
      ChatModel chat = doc.data() as ChatModel;

      // Fetch unread messages in the chat
      var messageSnapshot = await getMessagesCollection(chat.id).get();
      List<MessageModel> unreadMessages = messageSnapshot.docs
          .map((messageDoc) => messageDoc.data() as MessageModel)
          .where((message) => !message.readUsers.contains(uid))
          .toList();

      if (unreadMessages.isNotEmpty) {
        showChatNotification(
            "${chat.isGroup ? 1 : 0}${chat.id}",
            unreadMessages.last.type == "text"
                ? unreadMessages.last.content
                : "1 Image",
            id,
            chat.isGroup ? chat.groupName : "user");
        id++;
      }
    }
  }
}

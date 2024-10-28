import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_app_with_chat/core/models/photoModel.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;

  final storageRef = FirebaseStorage.instance.ref();

  DatabaseService() {
    setUpCollectionReference();
  }
  CollectionReference? _usersCollection;
  CollectionReference? _todosCollection;
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
  }

  Future<void> addUser(UserModel user) async {
    try {
      return await _usersCollection?.doc(user.userId).set(user);
    } catch (error) {
      print('Error adding user: $error');
    }
  }

  Future<void> addPhoto(String userId, ProfilePhoto photo) async {
    try {
      final DatabaseReference userPhotosRef =
          _dbRef.child('users/$userId/photos');
      await userPhotosRef
          .push()
          .set(photo.toJson()); // Add photo to user's photo list
    } catch (error) {
      print('Error adding photo: $error');
    }
  }

  Future<void> updateUserStatus(
      String userId, bool online, String lastSeen) async {
    try {
      await _dbRef.child('users/$userId').update({
        'online': online,
        'lastSeen': lastSeen,
      });
      print('User status updated successfully');
    } catch (error) {
      print('Error updating user status: $error');
    }
  }

  Future<void> updatedAtToDo(String todoId) async {
    await _firebaseFireStore
        .collection("todos")
        .doc(todoId)
        .update({"updatedAt": DateTime.now().toString()});
  }

  Stream<List<ToDoModel>>? getMyToDo() {
    var uid = FirebaseAuth.instance.currentUser!.uid;
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
      String uid = user!.uid;
      String email = user.email ?? "";
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

  Future<void> addCheckBoxListToTodo(String todoId, CheckBox checkBox) async {
    try {
      var checkBoxListRef = _dbRef.child("todos/$todoId/checkBoxList");
      checkBoxListRef.push().set(checkBox.toJson());
      updatedAtToDo(todoId);
    } catch (error) {
      print('Error Pining todo: $error');
    }
  }

  Future<void> editCheckBoxListToTodo(
      String todoId, CheckBox checkBox, String checkBoxId) async {
    try {
      var checkBoxListRef =
          _dbRef.child("todos/$todoId/checkBoxList/$checkBoxId");
      checkBoxListRef.update(checkBox.toJson());
      updatedAtToDo(todoId);
    } catch (error) {
      print('Error Pining todo: $error');
    }
  }

  Future<void> deleteCheckBoxListToTodo(
      String todoId, String checkBoxId) async {
    try {
      var checkBoxListRef =
          _dbRef.child("todos/$todoId/checkBoxList/$checkBoxId");
      checkBoxListRef.remove();
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
}

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:todo_app_with_chat/core/models/photoModel.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final storageRef = FirebaseStorage.instance.ref();

  Future<void> addUser(UserModel user) async {
    try {
      await _dbRef.child('users').child(user.userId).set(user.toJson());
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
    await _dbRef
        .child("todos/$todoId")
        .update({"updatedAt": DateTime.now().toString()});
  }

  Stream<DatabaseEvent> getMyToDo() {
    var uid = FirebaseAuth.instance.currentUser!.uid;

    return _dbRef.child('todos').orderByChild('users/$uid/type').onValue;
  }

  Stream<DatabaseEvent> getToDoById(String id) {
    return _dbRef.child('todos/$id').onValue;
  }

  Future<String> createToDo(ToDoModel todo) async {
    try {
      var todoRef = _dbRef.child("todos").push();
      await todoRef.set(todo.toJson());
      addUserToToDo(todoRef.key.toString(), todo.users[0]);
      return todoRef.key.toString();
    } catch (error) {
      print('Error updating user status: $error');
      return "";
    }
  }

  Future<void> deleteToDo(String todoId) async {
    try {
      var todoRef = _dbRef.child("todos/$todoId");
      await todoRef.remove();
    } catch (error) {
      print('Error updating user status: $error');
    }
  }

  Future<void> addUserToToDo(String todoId, Users user) async {
    try {
      var todoUsersRef = _dbRef.child("todos/$todoId/users");
      // Use push() to add a new user with a unique key
      await todoUsersRef.set({user.email: user.type});
      updatedAtToDo(todoId);
      print('User added successfully to ToDo ID: $todoId');
    } catch (error) {
      print('Error adding user to todo: $error');
    }
  }

  Future<void> removeUserToToDo(String todoId, String userId) async {
    try {
      var todoUsersRef = _dbRef.child("todos/$todoId/users/$userId");
      await todoUsersRef.remove();
      updatedAtToDo(todoId);

      print('User remove successfully from ToDo ID: $todoId');
    } catch (error) {
      print('Error adding user to todo: $error');
    }
  }

  Future<void> addPhotoToToDo(String todoId, Photo photo) async {
    try {
      var todoPhotosRef = _dbRef.child("todos/$todoId/photos");

      await todoPhotosRef.push().set(photo.toJson());
      updatedAtToDo(todoId);
      print('Photo added successfully to ToDo ID: $todoId');
    } catch (error) {
      print('Error adding photo to todo: $error');
    }
  }

  Future<void> removePhotoFromToDo(String todoId, String photoId) async {
    try {
      var todoPhotosRef = _dbRef.child("todos/$todoId/photos/$photoId");

      await todoPhotosRef.remove();
      updatedAtToDo(todoId);
      print('Photo remove successfully from ToDo ID: $todoId');
    } catch (error) {
      print('Error removing photo from todo: $error');
    }
  }

  Future<void> pinUnPinToDo(String todoId) async {
    try {
      var pinedRef = _dbRef.child("todos/$todoId");
      var snapshot = await pinedRef.child("pined").get();
      bool value = snapshot.value as bool;

      pinedRef.update({"pined": !value});
      updatedAtToDo(todoId);
      if (value) {
        print('Todo UnPined successfully: $todoId');
      } else {
        print('Todo Pined successfully: $todoId');
      }
    } catch (error) {
      print('Error Pining todo: $error');
    }
  }

  Future<void> editeToDoTitle(String todoId, String title) async {
    try {
      var pinedRef = _dbRef.child("todos/$todoId");
      await pinedRef.update({"title": title});
      updatedAtToDo(todoId);
    } catch (error) {
      print('Error Pining todo: $error');
    }
  }

  Future<void> editeToDoNote(String todoId, String title) async {
    try {
      var pinedRef = _dbRef.child("todos/$todoId");
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

  Future<void> editeCheckBoxListToTodo(
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

  Future<Map<String, dynamic>> uploadImageTOFirebase(
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
      await removePhotoFromToDo(todoId, photo.path);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

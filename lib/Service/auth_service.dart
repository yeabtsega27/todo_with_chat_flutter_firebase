import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/userModel.dart';
import 'package:todo_app_with_chat/locator.dart';

class AuthService {
  final FirebaseAuth _authInstance = FirebaseAuth.instance;
  late DatabaseService _databaseService;
  AuthService() {
    _databaseService = locator.get<DatabaseService>();
  }
  User? _user;

  User? get user {
    return _user;
  }

  Stream<User?> isUserLogin() {
    return _authInstance.authStateChanges();
  }

  Future<bool> registerUser(String email, String password, String name) async {
    try {
      var credential = await _authInstance.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        UserModel newUser = UserModel(
            userId: _user!.uid,
            username: name,
            email: email,
            photos: [],
            online: true,
            lastSeen: "online");
        _databaseService.addUser(newUser);
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      var credential = await _authInstance.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        _databaseService.updatedUserStates(true);
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> logOut() async {
    try {
      await _databaseService.updatedUserStates(false);
      await _authInstance.signOut();

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }
}

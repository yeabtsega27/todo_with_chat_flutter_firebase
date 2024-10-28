import 'package:get_it/get_it.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/DatabaseService.dart';
import 'package:todo_app_with_chat/Service/alert_service.dart';
import 'package:todo_app_with_chat/Service/auth_service.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';

final locator = GetIt.instance;

void setUp() {
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<DatabaseService>(() => DatabaseService());
  locator.registerLazySingleton<AlertService>(() => AlertService());
}

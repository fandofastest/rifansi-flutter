import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final isLoggedIn = authController.isLoggedIn;

    // Debug logging
    print('[AuthMiddleware] Route: $route');
    print(
        '[AuthMiddleware] Token: ${authController.token.value.isNotEmpty ? 'EXISTS' : 'EMPTY'}');
    print(
        '[AuthMiddleware] User: ${authController.currentUser.value != null ? 'EXISTS' : 'NULL'}');
    print('[AuthMiddleware] IsLoggedIn: $isLoggedIn');

    if (!isLoggedIn) {
      print('[AuthMiddleware] Redirecting to login');
      return const RouteSettings(name: Routes.login);
    }

    print('[AuthMiddleware] Access granted');
    return null;
  }
}

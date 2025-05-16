import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isLoggedIn = Get.find<AuthController>().isLoggedIn;
    if (!isLoggedIn) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
} 
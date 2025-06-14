import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'app_routes.dart';

class SupervisorMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // Check if user is logged in
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: Routes.login);
    }

    // Check if user has supervisor role
    final user = authController.currentUser.value;
    if (user == null || user.role.roleName.toLowerCase() != 'supervisor') {
      // Redirect to home if not supervisor
      Get.snackbar(
        'Akses Ditolak',
        'Halaman ini hanya dapat diakses oleh Supervisor',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return const RouteSettings(name: Routes.home);
    }

    return null;
  }
}

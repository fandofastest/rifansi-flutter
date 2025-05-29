import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rifansi/app/modules/login/login_page.dart';
import 'app/data/providers/graphql_service.dart';
import 'app/data/providers/storage_service.dart';
import 'app/data/providers/hive_service.dart';
import 'app/controllers/auth_controller.dart';
import 'app/theme/app_theme.dart';
import 'app/modules/splash/splash_page.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // Inisialisasi Hive (hanya sekali)
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Initialize services
  await Get.putAsync(() => GraphQLService().init());
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => HiveService().init(), permanent: true);

  // Initialize controllers
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rifansi App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // This will follow system theme
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}

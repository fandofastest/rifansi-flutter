import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../data/providers/storage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    usernameController = TextEditingController();
    passwordController = TextEditingController();
    _loadLastUsername();
  }

  Future<void> _loadLastUsername() async {
    final storage = Get.find<StorageService>();
    final lastUsername = await storage.getLastUsername();
    if (lastUsername != null && lastUsername.isNotEmpty) {
      setState(() {
        usernameController.text = lastUsername;
      });
    }
  }

  Future<void> _saveLastUsername(String username) async {
    final storage = Get.find<StorageService>();
    await storage.saveLastUsername(username);
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> authenticateWithBiometrics() async {
    final AuthController authController = Get.find<AuthController>();
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      print('canCheckBiometrics: $canCheckBiometrics');
      print('isDeviceSupported: $isDeviceSupported');
      print('availableBiometrics: $availableBiometrics');
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Login dengan fingerprint',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (didAuthenticate) {
        final success = await authController.fetchCurrentUser();
        if (success) {
          Get.offAllNamed(Routes.home);
        } else {
          Get.snackbar('Gagal', 'Fingerprint valid, tapi user tidak ditemukan.');
        }
      } else {
        Get.snackbar('Gagal', 'Fingerprint tidak dikenali');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Fingerprint tidak tersedia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: Stack(
        children: [
          // Gradient oranye atas dengan border radius bawah
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              height: size.height * 0.34,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF924F), Color(0xFFFF4747)],
                ),
              ),
              child: Stack(
                children: [
                  // Overlay semi transparan
                  Container(
                    height: size.height * 0.34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xA5FF924F), Color(0xD8FF4747)],
                      ),
                    ),
                    child:  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 56.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         const SizedBox(
                            height: 40,
                          ),
                          Container(
                            width: 67,
                            height: 67,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/logo_light.png'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rifansi Task Management',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                  // Logo di tengah atas
                 
                ],
              ),
            ),
          ),
          // Card login fade-in
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                child: Container(
                  width: size.width > 400 ? 360 : size.width * 0.95,
                  margin: EdgeInsets.only(top: size.height * 0.22),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Hello Again!',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Easily track your contractor jobs what's done, in progress, or still pending all in one app.",
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.abu,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.71,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Username
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Focus(
                          child: Builder(
                            builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;
                              return TextField(
                                controller: usernameController,
                                style: GoogleFonts.dmSans(
                                  color: FigmaColors.abu,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Username...',
                                  hintStyle: GoogleFonts.dmSans(
                                    color: FigmaColors.abu,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.71,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide(
                                      color: FigmaColors.primary,
                                      width: isFocused ? 2.5 : 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: const BorderSide(
                                      color: FigmaColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: const BorderSide(
                                      color: FigmaColors.primary,
                                      width: 2.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Password
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Focus(
                          child: Builder(
                            builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;
                              return TextField(
                                controller: passwordController,
                                obscureText: true,
                                style: GoogleFonts.dmSans(
                                  color: FigmaColors.abu,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password...',
                                  hintStyle: GoogleFonts.dmSans(
                                    color: FigmaColors.abu,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.71,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide(
                                      color: FigmaColors.primary,
                                      width: isFocused ? 2.5 : 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: const BorderSide(
                                      color: FigmaColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: const BorderSide(
                                      color: FigmaColors.primary,
                                      width: 2.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Login button
                      Obx(() => authController.isLoading.value
                          ? const CircularProgressIndicator()
                          : Container(
                              width: double.infinity,
                              height: 52,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: FigmaColors.primary,
                                borderRadius: BorderRadius.circular(46),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(46),
                                  onTap: () async {
                                    final success = await authController.login(
                                      usernameController.text,
                                      passwordController.text,
                                    );
                                    if (success) {
                                      await _saveLastUsername(usernameController.text);
                                      Get.offAllNamed(Routes.home);
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Login failed. Please check your credentials.',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'Log In',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      // Fingerprint button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: FigmaColors.abu,
                          borderRadius: BorderRadius.circular(46),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(46),
                            onTap: authenticateWithBiometrics,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.fingerprint, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Use Finger Scan',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.71,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
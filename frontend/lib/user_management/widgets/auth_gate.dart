import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../controllers/auth_controller.dart';
import '../screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  final AuthController? authController;

  const AuthGate({super.key, this.authController});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController _authController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.authController != null) {
      _authController = widget.authController!;
    } else {
      _authController = AuthController();
      _ownsController = true;
    }
    _authController.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _authController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        if (!_authController.isInitialized) {
          return const _AuthSplashView();
        }

        if (_authController.isAuthenticated) {
          return BiblioneShell(authController: _authController);
        }

        return LoginScreen(authController: _authController);
      },
    );
  }
}

class _AuthSplashView extends StatelessWidget {
  const _AuthSplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BiblioneLogoMark(size: 64),
            const SizedBox(height: 20),
            Text(
              'BIBLIONE',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'University Library Portal',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF8FA3B8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

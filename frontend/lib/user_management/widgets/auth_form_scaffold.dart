import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui_kit.dart';

class AuthFormScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? headerLeading;
  final bool showLogo;

  const AuthFormScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.headerLeading,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            children: [
              NavyAppHeader(
                leading: headerLeading ??
                    (showLogo ? const BiblioneLogoMark(size: 32) : null),
                eyebrow: 'BIBLIONE LIBRARY',
                title: title,
                showBell: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

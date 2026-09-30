import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin/screens/admin_dashboard_screen.dart';
import 'debug_agent_log.dart';
import 'seat_recommender/screens/find_seat_screen.dart';
import 'screens/MyBookingsScreen.dart';
import 'screens/SearchCatalogScreen.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/ui_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // #region agent log
  FlutterError.onError = (details) {
    agentDebugLog(
      location: 'main.dart:FlutterError',
      message: details.exceptionAsString(),
      hypothesisId: 'A-E',
      data: {
        'library': details.library,
        'stack': details.stack?.toString().split('\n').take(12).join(' | '),
      },
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    agentDebugLog(
      location: 'main.dart:platformError',
      message: error.toString(),
      hypothesisId: 'A-E',
      data: {'stack': stack.toString().split('\n').take(12).join(' | ')},
    );
    return false;
  };
  // #endregion
  runApp(const BiblioneApp());
}

class BiblioneApp extends StatelessWidget {
  const BiblioneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblione',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BiblioneShell(),
    );
  }
}

class BiblioneShell extends StatefulWidget {
  const BiblioneShell({super.key});

  @override
  State<BiblioneShell> createState() => _BiblioneShellState();
}

class _BiblioneShellState extends State<BiblioneShell> {
  int _index = 2;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _PlaceholderPage(
        title: 'Home',
        subtitle: 'Welcome back to the university library.',
      ),
      FindSeatScreen(onBack: () => setState(() => _index = 2)),
      const SearchCatalogScreen(),
      const MyBookingsScreen(),
      _PlaceholderPage(
        title: 'Profile',
        subtitle: 'RW • CS Dept • Card 2024-9182',
        onAdmin: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ColoredBox(
            color: AppColors.pageBg,
            child: Column(
              children: [
                Expanded(child: pages[_index]),
                BiblioneBottomNav(
                  index: _index,
                  onTap: (i) => setState(() => _index = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAdmin;
  const _PlaceholderPage({
    required this.title,
    required this.subtitle,
    this.onAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const NavyAppHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                  ),
                ),
                if (onAdmin != null) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onAdmin,
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Library operations'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

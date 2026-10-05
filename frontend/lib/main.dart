import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin/screens/admin_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'seat_recommender/screens/find_seat_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/search_catalog_screen.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/ui_kit.dart';
import 'user_management/controllers/auth_controller.dart';
import 'user_management/screens/profile_screen.dart';
import 'user_management/widgets/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BiblioneApp());
}

class BiblioneApp extends StatelessWidget {
  final AuthController? authController;
  final Widget? home;

  const BiblioneApp({super.key, this.authController, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblione',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home ?? AuthGate(authController: authController),
    );
  }
}

class BiblioneShell extends StatefulWidget {
  final AuthController? authController;

  const BiblioneShell({super.key, this.authController});

  @override
  State<BiblioneShell> createState() => _BiblioneShellState();
}

class _BiblioneShellState extends State<BiblioneShell> {
  int _index = 0;
  final Set<int> _visitedIndexes = {0};

  void _selectTab(int index) {
    if (index == _index && _visitedIndexes.contains(index)) return;
    setState(() {
      _index = index;
      _visitedIndexes.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authController?.currentUser;
    final universityId = currentUser?.universityId;
    final bookingsUserId =
        universityId != null && universityId.trim().isNotEmpty
        ? universityId.trim()
        : currentUser?.id;
    final pages = List<Widget>.generate(5, (index) {
      if (!_visitedIndexes.contains(index)) return const SizedBox.shrink();
      return switch (index) {
        0 => HomeScreen(
          userProfile: currentUser,
          authToken: widget.authController?.token,
          onFindSeat: () => _selectTab(1),
          onExploreBooks: () => _selectTab(2),
          onViewBookings: () => _selectTab(3),
        ),
        1 => FindSeatScreen(
          userId: bookingsUserId,
          onBack: () => _selectTab(0),
        ),
        2 => const SearchCatalogScreen(),
        3 => MyBookingsScreen(userId: bookingsUserId),
        4 when widget.authController != null =>
          ProfileScreen(authController: widget.authController!),
        _ => _PlaceholderPage(
          title: 'Profile',
          subtitle: 'RW • CS Dept • Card 2024-9182',
          onAdmin: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          ),
        ),
      };
    });
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ColoredBox(
            color: AppColors.pageBg,
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _index, children: pages),
                ),
                BiblioneBottomNav(
                  index: _index,
                  onTap: _selectTab,
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
    return _ProfilePage(title: title, subtitle: subtitle, onAdmin: onAdmin);
  }
}

class _ProfilePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAdmin;

  const _ProfilePage({
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

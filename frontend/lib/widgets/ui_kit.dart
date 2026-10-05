import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../notifications/controllers/notification_controller.dart';
import '../notifications/screens/notification_screen.dart';
import '../notifications/services/notification_api_client.dart';

class BiblioneLogoMark extends StatelessWidget {
  final double size;
  const BiblioneLogoMark({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SvgPicture.asset(
        'assets/brand/logo.svg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class NavyAppHeader extends StatelessWidget {
  final Widget? leading;
  final String? eyebrow;
  final String? title;
  final String? authToken;
  final Widget? extra;
  final bool showBell;

  const NavyAppHeader({
    super.key,
    this.leading,
    this.eyebrow,
    this.title,
    this.authToken,
    this.extra,
    this.showBell = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 10,
        16,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading ??
                  Row(
                    children: [
                      const BiblioneLogoMark(),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biblione',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'UNIVERSITY LIBRARY',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF9BB0C3),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              const Spacer(),
              if (showBell) _NotificationBell(authToken: authToken),
            ],
          ),
          if (eyebrow != null || title != null || extra != null) ...[
            const SizedBox(height: 18),
            if (eyebrow != null)
              Text(
                eyebrow!,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF2EC4A7),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            if (title != null)
              Text(
                title!,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ?extra,
          ],
        ],
      ),
    );
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell({this.authToken});

  final String? authToken;

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell>
    with WidgetsBindingObserver {
  static const _refreshInterval = Duration(seconds: 30);

  late final NotificationController _controller = NotificationController(
    apiClient: NotificationApiClient(token: widget.authToken),
  );
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshIfAuthenticated();
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _refreshIfAuthenticated(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIfAuthenticated();
    }
  }

  Future<void> _refreshIfAuthenticated() async {
    final token = widget.authToken;
    if (!mounted || token == null || token.isEmpty) return;
    await _controller.loadNotifications();
  }

  Future<void> _openNotifications() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
    if (mounted) await _refreshIfAuthenticated();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final unreadCount = _controller.unreadCount;
        return IconButton(
          tooltip: unreadCount == 0
              ? 'Notifications'
              : 'Notifications, $unreadCount unread',
          onPressed: _openNotifications,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -8,
                  top: -7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 17),
                    height: 17,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D5D),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.navy, width: 1.5),
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class LightSubHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String badge;
  final VoidCallback? onBack;
  final Widget? trailing;

  const LightSubHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badge = 'RW',
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.paddingOf(context).top + 6,
        16,
        12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          trailing ??
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A9B84),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final bool success;
  const StatusPill({super.key, required this.label, this.success = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: success ? AppColors.mintBg : AppColors.checkedBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: success ? AppColors.mintText : AppColors.checkedText,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailing;
  final bool expanded;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailing,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.ice,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, size: 18),
          ],
        ],
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class SoftButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? foreground;
  final bool expanded;

  const SoftButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.foreground,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground ?? AppColors.textPrimary,
        backgroundColor: AppColors.ice,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
          Text(label),
        ],
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class BookCover extends StatelessWidget {
  final String url;
  final String badge;
  final double width;
  final double height;

  const BookCover({
    super.key,
    required this.url,
    this.badge = '',
    this.width = 72,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFE8D5B5)),
            if (url.isNotEmpty)
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              ),
            if (badge.isNotEmpty)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  color: badge.toLowerCase().contains('pearson')
                      ? const Color(0xFF1B365D)
                      : badge.toLowerCase().contains('4th')
                      ? const Color(0xFF12355B)
                      : const Color(0xFFC44B2F),
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFD7C4A3),
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book, color: Color(0xFF7A5A32)),
    );
  }
}

class BiblioneBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const BiblioneBottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.event_seat_outlined, Icons.event_seat_rounded, 'Seats'),
      (Icons.search_rounded, Icons.search_rounded, 'Search'),
      (Icons.bookmark_border_rounded, Icons.bookmark_rounded, 'Bookings'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? items[i].$2 : items[i].$1,
                      color: selected
                          ? AppColors.emerald
                          : const Color(0xFF8A97A6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].$3,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: selected
                            ? AppColors.emerald
                            : const Color(0xFF8A97A6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

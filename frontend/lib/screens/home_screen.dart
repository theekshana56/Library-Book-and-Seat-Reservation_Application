import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../user_management/models/user_profile.dart';
import '../widgets/ui_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.apiClient,
    this.userProfile,
    this.authToken,
    required this.onFindSeat,
    required this.onExploreBooks,
    required this.onViewBookings,
  });

  final ApiClient? apiClient;
  final UserProfile? userProfile;
  final String? authToken;
  final VoidCallback onFindSeat;
  final VoidCallback onExploreBooks;
  final VoidCallback onViewBookings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiClient _api = widget.apiClient ?? ApiClient();
  UserBookings? _bookings;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = widget.userProfile;
      final userId = profile?.universityId?.trim().isNotEmpty == true
          ? profile!.universityId!.trim()
          : profile?.id.trim();
      if (userId == null || userId.isEmpty) {
        throw ApiException('Sign in to view your library activity.');
      }
      final bookings = await _api.getBookings(userId);
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _bookings;
    final profile = widget.userProfile;
    final fullName = profile?.fullName.trim() ?? '';
    final firstName = fullName.isEmpty ? 'there' : fullName.split(' ').first;
    final memberId = profile?.universityId?.trim().isNotEmpty == true
        ? profile!.universityId!.trim()
        : profile?.id.trim();
    final greeting = switch (DateTime.now().hour) {
      < 12 => 'Good morning',
      < 17 => 'Good afternoon',
      _ => 'Good evening',
    };

    return Column(
      children: [
        NavyAppHeader(authToken: widget.authToken),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.emerald,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$greeting,\n$firstName 👋',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF25483F),
                    fontSize: 29,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                if (memberId != null && memberId.isNotEmpty)
                  _MemberBadge(userId: memberId),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.chair_rounded,
                        title: 'Find a desk',
                        subtitle: 'Choose your study spot',
                        onTap: widget.onFindSeat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.menu_book_rounded,
                        title: 'Borrow a book',
                        subtitle: 'Explore the catalog',
                        onTap: widget.onExploreBooks,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.bookmark_added_rounded,
                        title: 'My bookings',
                        subtitle: 'See your reservations',
                        onTap: widget.onViewBookings,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.auto_stories_rounded,
                        title: 'On loan',
                        subtitle: '${bookings?.loans.length ?? 0} active books',
                        onTap: widget.onViewBookings,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                if (_loading && bookings == null)
                  const _LoadingCard()
                else if (_error != null && bookings == null)
                  _ErrorCard(message: _error!, onRetry: _load)
                else ...[
                  _OverviewCard(
                    bookings: bookings!,
                    onViewBookings: widget.onViewBookings,
                  ),
                  const SizedBox(height: 22),
                  _SectionHeading(
                    title: 'Your library activity',
                    actionLabel: 'View all',
                    onTap: widget.onViewBookings,
                  ),
                  const SizedBox(height: 10),
                  if (bookings.reservations.isEmpty &&
                      bookings.seatHolds.isEmpty &&
                      bookings.loans.isEmpty)
                    _EmptyActivity(onExploreBooks: widget.onExploreBooks)
                  else
                    ..._activityItems(bookings),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Could not refresh: $_error',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _activityItems(UserBookings bookings) {
    final items = <Widget>[];
    for (final reservation in bookings.reservations.take(2)) {
      items.add(
        _ActivityTile(
          icon: Icons.menu_book_rounded,
          title: reservation.status == 'READY_FOR_PICKUP'
              ? 'Your book is ready'
              : 'Book reservation',
          detail: '${reservation.title} · ${reservation.pickupDesk}',
          status: reservation.status.replaceAll('_', ' '),
        ),
      );
    }
    for (final seat in bookings.seatHolds.take(2)) {
      items.add(
        _ActivityTile(
          icon: Icons.chair_rounded,
          title: 'Desk reserved',
          detail: '${seat.seatName} · ${seat.zone}',
          status: seat.slotLabel,
        ),
      );
    }
    for (final loan in bookings.loans.take(2)) {
      items.add(
        _ActivityTile(
          icon: Icons.auto_stories_rounded,
          title: 'Book on loan',
          detail: loan.title,
          status: 'Due ${DateFormat('MMM d').format(loan.dueDate.toLocal())}',
        ),
      );
    }
    return [
      for (var index = 0; index < items.length; index++) ...[
        if (index > 0) const SizedBox(height: 10),
        items[index],
      ],
    ];
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EFEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.badge_outlined,
              size: 17,
              color: AppColors.checkedText,
            ),
            const SizedBox(width: 7),
            Text(
              userId,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF31574E),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFDFD),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 142),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF0F1F1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5F2EC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.emerald, size: 25),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF29445C),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: Color(0xFF9AA5A8),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.bookings, required this.onViewBookings});

  final UserBookings bookings;
  final VoidCallback onViewBookings;

  @override
  Widget build(BuildContext context) {
    final readyBooks = bookings.reservations
        .where((reservation) => reservation.status == 'READY_FOR_PICKUP')
        .length;
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFF293F50),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF4DD4B1),
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                'YOUR LIBRARY SNAPSHOT',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFC5D3DC),
                  fontSize: 10,
                  letterSpacing: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  count: bookings.seatHolds.length,
                  label: 'desks reserved',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  count: readyBooks,
                  label: 'books to pick up',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  count: bookings.loans.length,
                  label: 'books on loan',
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewBookings,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF788995)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('Manage my bookings'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF39C5A5),
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 2,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFD4DEE4),
            height: 1.25,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF29445C),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.mintText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFD5F2EC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.emerald),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF29445C),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.mintText,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Center(child: CircularProgressIndicator(color: AppColors.emerald)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.warning),
          const SizedBox(height: 8),
          Text(
            'We couldn’t load your library activity.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity({required this.onExploreBooks});

  final VoidCallback onExploreBooks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_library_outlined,
            color: AppColors.emerald,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            'Your next great study session starts here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF29445C),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: onExploreBooks,
            child: const Text('Explore the catalog'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../api/api_client.dart';
import '../../models/models.dart';

class ActiveBookingsView extends StatefulWidget {
  final String userId;

  const ActiveBookingsView({super.key, required this.userId});

  @override
  State<ActiveBookingsView> createState() => _ActiveBookingsViewState();
}

class _ActiveBookingsViewState extends State<ActiveBookingsView> {
  final ApiClient _api = ApiClient();
  UserBookings? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // First try with the given userId
      var data = await _api.getBookings(widget.userId);
      
      bool hasItems = data.reservations.isNotEmpty || data.loans.isNotEmpty || data.seatHolds.isNotEmpty;
      
      // If empty, try without trailing 'v'/'V'
      if (!hasItems && widget.userId.toLowerCase().endsWith('v')) {
        final trimmedId = widget.userId.substring(0, widget.userId.length - 1);
        final altData = await _api.getBookings(trimmedId);
        if (altData.reservations.isNotEmpty || altData.loans.isNotEmpty || altData.seatHolds.isNotEmpty) {
          data = altData;
        }
      }

      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00875A)),
        ),
      );
    }

    if (_data == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> items = [];
    final df = DateFormat('dd MMM');

    // 1. Reservations
    for (var r in _data!.reservations) {
      final s = r.status.toUpperCase();
      if (s == 'CANCELLED' || s == 'EXPIRED' || s == 'RETURNED') continue;
      items.add(_buildCard(
        title: r.title,
        icon: Icons.menu_book_rounded,
        dateText1: 'Reserved on ${df.format(r.createdAt)}',
        dateText2: 'Return by ${df.format(r.expiresAt)}',
        start: r.createdAt,
        end: r.expiresAt,
      ));
    }

    // 2. Loans
    for (var l in _data!.loans) {
      final s = l.status.toUpperCase();
      if (s == 'RETURNED') continue;
      items.add(_buildCard(
        title: l.title,
        icon: Icons.menu_book_rounded,
        dateText1: 'Reserved on ${df.format(l.borrowedAt)}',
        dateText2: 'Return by ${df.format(l.dueDate)}',
        start: l.borrowedAt,
        end: l.dueDate,
      ));
    }

    // 3. Seat Holds
    for (var s in _data!.seatHolds) {
      final st = s.status.toUpperCase();
      if (st == 'CANCELLED' || st == 'EXPIRED') continue;
      items.add(_buildCard(
        title: s.seatName,
        icon: Icons.chair_alt_rounded,
        dateText1: 'Seat: ${s.seatCode} (${s.zone})',
        dateText2: 'Check in by ${DateFormat('hh:mm a').format(s.checkInBy)}',
        start: DateTime.now().subtract(const Duration(minutes: 30)),
        end: s.checkInBy,
      ));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: items,
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required String dateText1,
    required String dateText2,
    required DateTime start,
    required DateTime end,
  }) {
    final now = DateTime.now();
    final totalMinutes = end.difference(start).inMinutes.abs();
    final elapsedMinutes = now.difference(start).inMinutes;

    double progress = 0.0;
    if (totalMinutes > 0) {
      progress = (elapsedMinutes / totalMinutes).clamp(0.0, 1.0);
    }
    if (now.isAfter(end)) {
      progress = 1.0;
    }

    Color colorTheme = const Color(0xFF00875A); // Emerald green
    Color iconBg = const Color(0xFFE8F8F2);
    String footerLeft = '';
    String footerRight = '';
    IconData finalIcon = icon;

    final totalDays = (totalMinutes / (24 * 60)).ceil().clamp(1, 999);
    final elapsedDays = (elapsedMinutes / (24 * 60)).ceil().clamp(1, totalDays);

    if (now.isAfter(end)) {
      // Overdue
      colorTheme = const Color(0xFFDC2626); // Red
      iconBg = const Color(0xFFFEE2E2);
      final daysLate = now.difference(end).inDays.clamp(1, 999);
      footerLeft = '$daysLate days late';
      footerRight = 'Overdue — please return soon';
      finalIcon = Icons.warning_rounded;
    } else {
      final daysLeft = end.difference(now).inDays;
      if (daysLeft <= 3) {
        // Warning
        colorTheme = const Color(0xFFF59E0B); // Orange
        iconBg = const Color(0xFFFEF3C7);
        footerLeft = 'Day $elapsedDays of $totalDays';
        footerRight = daysLeft <= 0 ? 'Due today — return soon' : 'Due in $daysLeft days — almost time to return';
      } else {
        // Normal
        colorTheme = const Color(0xFF00875A);
        iconBg = const Color(0xFFE8F8F2);
        footerLeft = 'Day $elapsedDays of $totalDays';
        footerRight = 'Due in $daysLeft days — plenty of time';
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(finalIcon, color: colorTheme, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: const Color(0xFF0E1B2B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dateText1,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateText2,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: colorTheme,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress track
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: colorTheme,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                footerLeft,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                footerRight,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

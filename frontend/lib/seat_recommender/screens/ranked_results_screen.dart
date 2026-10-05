import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../seat_booking/models/seat_booking_models.dart';
import '../../seat_booking/screens/review_booking_screen.dart';
import '../../theme/app_colors.dart';
import '../models/seat_recommendation.dart';

class RankedResultsScreen extends StatefulWidget {
  final SeatRecommendationResponse response;
  final SeatSearchRequest request;
  final String? userId;

  const RankedResultsScreen({
    super.key,
    required this.response,
    required this.request,
    this.userId,
  });

  @override
  State<RankedResultsScreen> createState() => _RankedResultsScreenState();
}

class _RankedResultsScreenState extends State<RankedResultsScreen> {
  String _filter = 'Relevance';

  List<SeatMatch> get _visibleMatches {
    final matches = [...widget.response.exactMatches];
    if (_filter == 'Under 30 dB') {
      matches.removeWhere((seat) => seat.acousticsDb >= 30);
    } else if (_filter == 'Fast Charging') {
      matches.removeWhere(
        (seat) => !seat.features.any(
          (feature) =>
              feature.toLowerCase().contains('fast') ||
              feature.toLowerCase().contains('charging'),
        ),
      );
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final matches = _visibleMatches;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                children: [
                  Row(
                    children: [
                      Text('${matches.length} available', style: _muted(12)),
                      const Spacer(),
                      Text(
                        'SORTED BY MATCH',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Relevance',
                      'Under 30 dB',
                      'Fast Charging',
                    ].map((filter) => _filterChip(filter)).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (matches.isEmpty)
                    _noFilteredResults()
                  else
                    ...matches.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _seatCard(entry.key + 1, entry.value),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    color: AppColors.navy,
    padding: const EdgeInsets.fromLTRB(10, 6, 20, 17),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back',
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR PERSONALIZED SHORTLIST',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF9DB3C7),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'Best Matches For You',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${widget.request.zonePreference} | ${DateFormat('EEE, MMM d').format(widget.request.date)} | ${DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(widget.request.startTime))}',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFCAD6E1),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _filterChip(String label) {
    final selected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = label),
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: AppColors.mintBg,
      side: BorderSide(
        color: selected ? AppColors.emerald : const Color(0xFFE1E7EE),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: selected ? AppColors.emerald : AppColors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _seatCard(int rank, SeatMatch seat) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE3E9EF)),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.mintBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#$rank BEST MATCH',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.mintText,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${seat.matchScore}%',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.emerald,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          'Seat - ${seat.seatCode}',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${seat.floor} | ${seat.zone}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _muted(11),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _spec(
                Icons.graphic_eq,
                '${seat.acousticsDb} dB | ${_acousticLabel(seat.acousticsDb)}',
              ),
            ),
            Expanded(
              child: _spec(
                seat.hasPowerOutlet ? Icons.bolt : Icons.power_off,
                seat.hasPowerOutlet ? 'Power outlet' : 'No outlet',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _tag(seat.zone, AppColors.ice, AppColors.textMuted),
            if (seat.hasPowerOutlet)
              _tag('Power Outlet', AppColors.mintBg, AppColors.mintText),
            _tag(
              'Available for selected slot',
              const Color(0xFFEAF4F1),
              AppColors.emerald,
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton.icon(
            onPressed: () => _showSeatDetails(seat),
            icon: const Icon(Icons.event_seat_outlined, size: 17),
            label: Text('View & Book Seat - ${seat.seatCode}'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _spec(IconData icon, String value) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.emerald),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _muted(10),
        ),
      ),
    ],
  );

  Widget _tag(String label, Color background, Color foreground) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        color: foreground,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _noFilteredResults() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.filter_alt_off_outlined,
          color: AppColors.textMuted,
          size: 30,
        ),
        const SizedBox(height: 8),
        Text(
          'No seats match this filter.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        Text('Try Relevance to see every exact match.', style: _muted(11)),
      ],
    ),
  );

  Future<void> _showSeatDetails(SeatMatch seat) async {
    final startTime = DateFormat('HH:mm:ss').parse(widget.request.startTime);
    final endTime = startTime.add(
      Duration(minutes: widget.request.durationMinutes),
    );
    final startLabel = DateFormat('h:mm a').format(startTime);
    final endLabel = DateFormat('h:mm a').format(endTime);
    final canBook = widget.userId?.trim().isNotEmpty == true;
    final shouldBook = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seat - ${seat.seatCode}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text('${seat.floor} · ${seat.zone}', style: _muted(12)),
              const SizedBox(height: 12),
              Text(
                '${seat.acousticsDb} dB · ${seat.hasPowerOutlet ? 'Power outlet available' : 'No power outlet'}',
                style: _muted(12),
              ),
              const SizedBox(height: 12),
              Text(
                '${DateFormat('EEE, MMM d').format(widget.request.date)} · $startLabel–$endLabel',
                style: _muted(12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canBook
                      ? () => Navigator.pop(sheetContext, true)
                      : null,
                  icon: const Icon(Icons.event_available_rounded),
                  label: Text(
                    canBook ? 'Continue to booking' : 'Sign in to book a seat',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (shouldBook != true || !mounted) return;

    final bookingDate = DateFormat('yyyy-MM-dd').format(widget.request.date);
    final bookingEndTime = DateFormat('HH:mm:ss').format(endTime);
    final selectedSeat = SeatMapSeat(
      id: seat.id,
      seatCode: seat.seatCode,
      hallCode: '',
      floor: seat.floor,
      zone: seat.zone,
      hasPowerOutlet: seat.hasPowerOutlet,
      acousticsDb: seat.acousticsDb,
      features: seat.features,
      available: true,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ReviewBookingScreen(
          seat: selectedSeat,
          bookingDate: bookingDate,
          startTime: widget.request.startTime,
          endTime: bookingEndTime,
          userId: widget.userId,
        ),
      ),
    );
  }

  String _acousticLabel(int db) => db < 25
      ? 'Silent'
      : db < 35
      ? 'Quiet'
      : 'Lively';

  TextStyle _muted(double size) => GoogleFonts.plusJakartaSans(
    color: AppColors.textMuted,
    fontSize: size,
    fontWeight: FontWeight.w500,
  );
}

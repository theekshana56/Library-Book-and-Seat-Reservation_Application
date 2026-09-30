import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../models/seat_recommendation.dart';

class EmptyStateScreen extends StatefulWidget {
  final SeatRecommendationResponse response;
  final SeatSearchRequest request;

  const EmptyStateScreen({
    super.key,
    required this.response,
    required this.request,
  });

  @override
  State<EmptyStateScreen> createState() => _EmptyStateScreenState();
}

class _EmptyStateScreenState extends State<EmptyStateScreen> {
  bool _notifyWhenAvailable = false;

  @override
  Widget build(BuildContext context) {
    final seats = widget.response.closestMatches;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                children: [
                  _emptyHero(),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Modify Preferences'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: Color(0xFFCBD5DF)),
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CLOSEST MATCHES (${seats.length})',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (seats.isNotEmpty)
                        _mintPill(_relaxationLabel(seats.first)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (seats.isEmpty)
                    _noSeatsCard()
                  else
                    ...seats.map(
                      (seat) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _closestCard(seat),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _notifyCard(),
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
    padding: const EdgeInsets.fromLTRB(10, 6, 20, 14),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back',
        ),
        Text(
          'Seat availability',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );

  Widget _emptyHero() => Column(
    children: [
      Container(
        width: 92,
        height: 92,
        decoration: const BoxDecoration(
          color: AppColors.cyanAlert,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.search_rounded,
          color: AppColors.emerald,
          size: 42,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'No exact match found',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        'We couldn’t find an open seat matching every preference. Here are the closest available options.',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textMuted,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    ],
  );

  Widget _closestCard(SeatMatch seat) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE3E9EF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Seat - ${seat.seatCode}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            _mintPill(seat.floor),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          seat.zone,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _muted(10),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          children: [
            if (widget.request.powerRequired == true && !seat.hasPowerOutlet)
              _warningPill('No Outlet')
            else if (widget.request.zonePreference.toLowerCase() != 'any' &&
                !seat.zone.toLowerCase().contains(
                  widget.request.zonePreference.toLowerCase(),
                ))
              _warningPill('Different zone')
            else
              _warningPill('Closest available fit'),
            _mintPill('${seat.matchScore}% match'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: FilledButton.icon(
            onPressed: () => _showSeatDetails(seat),
            icon: const Icon(Icons.event_seat_outlined, size: 16),
            label: const Text('View & Book'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _notifyCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE3E9EF)),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.ice,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.notifications_none,
            color: AppColors.navy,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notify when a desk frees up',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
              Text('Notification preference for this search', style: _muted(9)),
            ],
          ),
        ),
        Switch.adaptive(
          value: _notifyWhenAvailable,
          activeTrackColor: AppColors.emerald,
          onChanged: (value) => setState(() => _notifyWhenAvailable = value),
        ),
      ],
    ),
  );

  Widget _noSeatsCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'No available seats were returned. Try another time or date.',
      style: _muted(12),
    ),
  );

  String _relaxationLabel(SeatMatch seat) {
    final zoneRelaxed =
        widget.request.zonePreference.toLowerCase() != 'any' &&
        !seat.zone.toLowerCase().contains(
          widget.request.zonePreference.toLowerCase(),
        );
    final powerRelaxed =
        widget.request.powerRequired != null &&
        seat.hasPowerOutlet != widget.request.powerRequired;
    final count = (zoneRelaxed ? 1 : 0) + (powerRelaxed ? 1 : 0);
    return 'Relaxing $count requirement${count == 1 ? '' : 's'}';
  }

  Widget _mintPill(String text) => Container(
    constraints: const BoxConstraints(maxWidth: 155),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.mintBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.mintText,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _warningPill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9DF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFFB54708),
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Future<void> _showSeatDetails(SeatMatch seat) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) => SafeArea(
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
            const SizedBox(height: 16),
            Text(
              'Seat reservations are not enabled in this module yet.',
              style: _muted(11),
            ),
          ],
        ),
      ),
    ),
  );

  TextStyle _muted(double size) => GoogleFonts.plusJakartaSans(
    color: AppColors.textMuted,
    fontSize: size,
    fontWeight: FontWeight.w500,
  );
}

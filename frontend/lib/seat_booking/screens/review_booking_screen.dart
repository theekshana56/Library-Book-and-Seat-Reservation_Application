import 'package:flutter/material.dart';
import 'booking_success_screen.dart';

class ReviewBookingScreen extends StatelessWidget {
  final String seatNumber;

  const ReviewBookingScreen({
    super.key,
    required this.seatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF073342),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biblione',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'SMART LIBRARY',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF00A087),
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      size: 15,
                      color: Color(0xFF173B46),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF173B46),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Review Booking',
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Review your reservation details before confirming.',
                style: TextStyle(
                  color: Color(0xFF78868A),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF087E6A),
                      Color(0xFF00A087),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SELECTED SEAT',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Icon(
                          Icons.chair_alt_outlined,
                          color: Colors.white,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      seatNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Level 2 Quiet Zone',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Divider(
                      color: Colors.white24,
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Expanded(
                          child: _HeaderDetail(
                            label: 'DATE',
                            value: '18 Sep 2026',
                          ),
                        ),
                        Expanded(
                          child: _HeaderDetail(
                            label: 'TIME',
                            value: '10:00 AM',
                          ),
                        ),
                        Expanded(
                          child: _HeaderDetail(
                            label: 'DURATION',
                            value: '2 Hours',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE1E8E7),
                  ),
                ),
                child: Column(
                  children: [
                    _detailRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date',
                      value: 'Friday, 18 September 2026',
                    ),
                    const Divider(height: 26),
                    _detailRow(
                      icon: Icons.access_time,
                      title: 'Time',
                      value: '10:00 AM – 12:00 PM',
                    ),
                    const Divider(height: 26),
                    _detailRow(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: 'Level 2 Quiet Zone, Central Cluster',
                    ),
                    const Divider(height: 26),
                    _detailRow(
                      icon: Icons.chair_alt_outlined,
                      title: 'Seat',
                      value: '$seatNumber – Window Side',
                    ),
                    const Divider(height: 26),
                    _detailRow(
                      icon: Icons.power_outlined,
                      title: 'Facilities',
                      value: 'Window View • Power Outlet • LAN',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Color(0xFF008C72),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Check-in Policy\nYou must check in within 15 minutes of your reserved start time. Scan the QR code at your reserved desk.',
                        style: TextStyle(
                          color: Color(0xFF31545C),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008C72),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingSuccessScreen(
                          seatNumber: seatNumber,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF173B46),
                    side: const BorderSide(
                      color: Color(0xFFD6E0DF),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Change Seat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xFF008C72),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF809094),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF173B46),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderDetail extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String seatNumber;

  const BookingSuccessScreen({
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
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F7F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF008C72),
                  size: 54,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Seat Reserved Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Your desk has been confirmed and reserved for your selected period.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF78868A),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE1E8E7),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF8F4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF008C72),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              seatNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SEAT LOCATION',
                                  style: TextStyle(
                                    color: Color(0xFF819094),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Level 2 Quiet Zone',
                                  style: TextStyle(
                                    color: Color(0xFF173B46),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Window Side',
                                  style: TextStyle(
                                    color: Color(0xFF78868A),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _detailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: '18 September 2026',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      icon: Icons.access_time,
                      label: 'Time Slot',
                      value: '10:00 AM – 12:00 PM',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      icon: Icons.timelapse,
                      label: 'Duration',
                      value: '2 Hours',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Booking ID',
                      value: '#LIB-2026-7843',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      icon: Icons.power_outlined,
                      label: 'Facilities',
                      value: 'Power Outlet • Window View',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE1E8E7),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'DIGITAL BOOKING PASS',
                      style: TextStyle(
                        color: Color(0xFF7B898D),
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 65,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.view_week,
                          color: Color(0xFF173B46),
                          size: 54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'LIB-2026-7843',
                      style: TextStyle(
                        color: Color(0xFF173B46),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

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
                      Icons.access_time_filled,
                      size: 20,
                      color: Color(0xFF008C72),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '15-Minute Check-in Window\nPlease check in within 15 minutes of your reservation start time.',
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Active Booking screen will open next.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'View Booking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFF53676D),
                    fontWeight: FontWeight.w600,
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
    required String label,
    required String value,
  }) {
    return Row(
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
                label,
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
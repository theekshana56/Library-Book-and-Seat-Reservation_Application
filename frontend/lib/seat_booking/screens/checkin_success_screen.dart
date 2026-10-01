import 'package:flutter/material.dart';

class CheckinSuccessScreen extends StatelessWidget {
  final String seatNumber;

  const CheckinSuccessScreen({
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
        title: const Text(
          'Check-in',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F7F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF008C72),
                  size: 62,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Check-in Successful!',
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Your desk reservation is now active.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF78868A),
                  fontSize: 12,
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
                            width: 58,
                            height: 58,
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
                                  'Seat A04',
                                  style: TextStyle(
                                    color: Color(0xFF173B46),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Level 2 Quiet Zone',
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
                      Icons.calendar_today_outlined,
                      'Date',
                      '18 September 2026',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      Icons.access_time,
                      'Session',
                      '10:00 AM – 12:00 PM',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      Icons.login,
                      'Check-in Time',
                      '10:03 AM',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      Icons.timelapse,
                      'Duration Remaining',
                      '1 hr 57 min',
                    ),

                    const Divider(height: 26),

                    _detailRow(
                      Icons.confirmation_number_outlined,
                      'Booking ID',
                      '#LIB-2026-7843',
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
                      color: Color(0xFF008C72),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Enjoy your study session! Remember to check out when you are done to free up the space for fellow scholars.',
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
                    Navigator.popUntil(
                      context,
                          (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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

  Widget _detailRow(
      IconData icon,
      String label,
      String value,
      ) {
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
            color: const Color(0xFF008C72),
            size: 19,
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
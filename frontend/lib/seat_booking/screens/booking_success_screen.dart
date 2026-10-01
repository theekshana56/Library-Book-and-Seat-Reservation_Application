import 'package:flutter/material.dart';

import 'active_booking_screen.dart';

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
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),

          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F7F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF008C72),
                  size: 58,
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
                'Your reservation has been confirmed.',
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
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF008C72),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        seatNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Level 2 Quiet Zone',
                      style: TextStyle(
                        color: Color(0xFF173B46),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _row('Date', '18 September 2026'),
                    const Divider(height: 25),

                    _row('Time', '10:00 AM – 12:00 PM'),
                    const Divider(height: 25),

                    _row('Booking ID', '#LIB-2026-7843'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Please check in within 15 minutes after your booking begins.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF31545C),
                    fontSize: 11,
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveBookingScreen(
                          seatNumber: seatNumber,
                        ),
                      ),
                    );
                  },

                  child: const Text(
                    'View Booking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF809094),
            fontSize: 11,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF173B46),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
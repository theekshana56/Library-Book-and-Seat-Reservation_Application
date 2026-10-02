import 'package:flutter/material.dart';

import 'booking_success_screen.dart';
import '../../api/api_client.dart';

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
        title: const Text(
          'Review Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 15),
                    SizedBox(width: 5),
                    Text('Back'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

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
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF087E6A),
                      Color(0xFF00A087),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECTED SEAT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      seatNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const Text(
                      'Level 2 Quiet Zone',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
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
                    _detail(
                      Icons.calendar_today_outlined,
                      'Date',
                      '18 September 2026',
                    ),

                    const Divider(height: 28),

                    _detail(
                      Icons.access_time,
                      'Time',
                      '10:00 AM – 12:00 PM',
                    ),

                    const Divider(height: 28),

                    _detail(
                      Icons.timelapse,
                      'Duration',
                      '2 Hours',
                    ),

                    const Divider(height: 28),

                    _detail(
                      Icons.location_on_outlined,
                      'Location',
                      'Level 2 Quiet Zone',
                    ),

                    const Divider(height: 28),

                    _detail(
                      Icons.chair_alt_outlined,
                      'Seat',
                      '$seatNumber – Window Side',
                    ),

                    const Divider(height: 28),

                    _detail(
                      Icons.power_outlined,
                      'Facilities',
                      'Power Outlet • Window View',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
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
                        'Check in within 15 minutes of your reservation start time using the QR code at your desk.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: Color(0xFF31545C),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () async {
                    try {
                      await ApiClient().createSeatBooking(
                        seatCode: seatNumber,
                        bookingDate: '2026-09-18',
                        startTime: '10:00:00',
                        endTime: '12:00:00',
                      );

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingSuccessScreen(
                            seatNumber: seatNumber,
                          ),
                        ),
                      );
                    } on ApiException catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to create seat booking.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },

                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Change Seat'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(
      IconData icon,
      String title,
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
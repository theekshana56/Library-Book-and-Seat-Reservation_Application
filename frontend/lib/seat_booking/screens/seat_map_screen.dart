import 'package:flutter/material.dart';

import 'review_booking_screen.dart';

class SeatMapScreen extends StatefulWidget {
  const SeatMapScreen({super.key});

  @override
  State<SeatMapScreen> createState() => _SeatMapScreenState();
}

class _SeatMapScreenState extends State<SeatMapScreen> {
  String selectedSeat = 'A04';

  final List<Map<String, String>> seats = [
    {'id': 'A01', 'status': 'available'},
    {'id': 'A02', 'status': 'occupied'},
    {'id': 'A03', 'status': 'available'},
    {'id': 'A04', 'status': 'available'},
    {'id': 'A05', 'status': 'available'},
    {'id': 'A06', 'status': 'occupied'},
    {'id': 'A07', 'status': 'available'},
    {'id': 'A08', 'status': 'available'},
    {'id': 'A09', 'status': 'occupied'},
    {'id': 'A10', 'status': 'available'},
    {'id': 'A11', 'status': 'occupied'},
    {'id': 'A12', 'status': 'available'},
  ];

  Color _seatColor(Map<String, String> seat) {
    if (seat['id'] == selectedSeat) {
      return const Color(0xFF008C72);
    }

    if (seat['status'] == 'occupied') {
      return const Color(0xFF28374D);
    }

    return const Color(0xFFF0F4F4);
  }

  Color _textColor(Map<String, String> seat) {
    if (seat['id'] == selectedSeat || seat['status'] == 'occupied') {
      return Colors.white;
    }

    return const Color(0xFF123642);
  }

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
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quiet Zone – Seat Map',
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Level 2 Quiet Zone',
                style: TextStyle(
                  color: Color(0xFF78868A),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  _legend(
                    const Color(0xFFF0F4F4),
                    'Available',
                  ),
                  _legend(
                    const Color(0xFF28374D),
                    'Occupied',
                  ),
                  _legend(
                    const Color(0xFF008C72),
                    'Selected',
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                    const Row(
                      children: [
                        Icon(
                          Icons.window_outlined,
                          color: Color(0xFF008C72),
                          size: 19,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'ROW A – WINDOW SIDE',
                          style: TextStyle(
                            color: Color(0xFF153A45),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: seats.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.18,
                      ),
                      itemBuilder: (context, index) {
                        final seat = seats[index];

                        final occupied =
                            seat['status'] == 'occupied';

                        return GestureDetector(
                          onTap: occupied
                              ? null
                              : () {
                            setState(() {
                              selectedSeat = seat['id']!;
                            });
                          },

                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 180),

                            decoration: BoxDecoration(
                              color: _seatColor(seat),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: seat['id'] == selectedSeat
                                    ? const Color(0xFF008C72)
                                    : const Color(0xFFDCE5E4),
                                width: 1.4,
                              ),
                            ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chair_alt_outlined,
                                  size: 23,
                                  color: _textColor(seat),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  seat['id']!,
                                  style: TextStyle(
                                    color: _textColor(seat),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  occupied ? 'Occupied' : 'Free',
                                  style: TextStyle(
                                    color: _textColor(seat)
                                        .withValues(alpha: 0.8),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

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
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF008C72),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedSeat,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$selectedSeat – Window View',
                            style: const TextStyle(
                              color: Color(0xFF173B46),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Level 2 Quiet Zone • Power outlet nearby',
                            style: TextStyle(
                              color: Color(0xFF78868A),
                              fontSize: 10,
                            ),
                          ),
                        ],
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

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewBookingScreen(
                          seatNumber: selectedSeat,
                        ),
                      ),
                    );
                  },

                  child: const Text(
                    'Continue to Review',
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

  Widget _legend(Color color, String text) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: const Color(0xFFD2DBDA),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF677579),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
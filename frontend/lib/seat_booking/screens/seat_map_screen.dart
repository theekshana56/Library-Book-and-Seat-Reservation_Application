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

  Color _getSeatColor(Map<String, String> seat) {
    if (seat['id'] == selectedSeat) {
      return const Color(0xFF008C72);
    }

    if (seat['status'] == 'occupied') {
      return const Color(0xFF2C394B);
    }

    return const Color(0xFFF1F5F4);
  }

  Color _getSeatTextColor(Map<String, String> seat) {
    if (seat['id'] == selectedSeat || seat['status'] == 'occupied') {
      return Colors.white;
    }

    return const Color(0xFF153A45);
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
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.maybePop(context);
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
                        fontSize: 13,
                        color: Color(0xFF173B46),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Quiet Zone – Seat Map',
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Level 2 Quiet Zone',
                style: TextStyle(
                  color: Color(0xFF7B888C),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  _legendItem(
                    color: const Color(0xFFF1F5F4),
                    label: 'Available',
                  ),
                  _legendItem(
                    color: const Color(0xFF2C394B),
                    label: 'Occupied',
                  ),
                  _legendItem(
                    color: const Color(0xFF008C72),
                    label: 'Selected',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.window_outlined,
                          size: 18,
                          color: Color(0xFF008C72),
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
                        final bool occupied =
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
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: _getSeatColor(seat),
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
                                  color: _getSeatTextColor(seat),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  seat['id']!,
                                  style: TextStyle(
                                    color: _getSeatTextColor(seat),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  occupied ? 'Occupied' : 'Free',
                                  style: TextStyle(
                                    color: _getSeatTextColor(seat)
                                        .withOpacity(0.8),
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
                  border: Border.all(
                    color: const Color(0xFFD6EEE7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF008C72),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedSeat,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$selectedSeat – Window View',
                            style: const TextStyle(
                              color: Color(0xFF153A45),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Level 2 Quiet Zone • Power outlet nearby',
                            style: TextStyle(
                              color: Color(0xFF7A888C),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

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
                        builder: (context) => ReviewBookingScreen(
                          seatNumber: selectedSeat,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue to Review',
                    style: TextStyle(
                      fontSize: 14,
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

  Widget _legendItem({
    required Color color,
    required String label,
  }) {
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
              label,
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
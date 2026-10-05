import 'package:flutter/material.dart';

class CheckinSuccessScreen extends StatelessWidget {
  final String seatNumber;

  const CheckinSuccessScreen({
    super.key,
    required this.seatNumber,
  });

  @override
  Widget build(BuildContext context) {
    final checkinTime =
    TimeOfDay.fromDateTime(
      DateTime.now(),
    ).format(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF073342),
        foregroundColor: Colors.white,
        title: const Text(
          'Check-in',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(
            18,
            24,
            18,
            30,
          ),

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

              const SizedBox(height: 7),

              const Text(
                'Your study session is now active.',
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
                  borderRadius:
                  BorderRadius.circular(18),
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
                        color:
                        const Color(0xFF008C72),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: Text(
                        seatNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Seat $seatNumber',
                      style: const TextStyle(
                        color:
                        Color(0xFF173B46),
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _row(
                      'Location',
                      'Level 2 Quiet Zone',
                    ),

                    const Divider(height: 26),

                    _row(
                      'Session',
                      '10:00 AM – 12:00 PM',
                    ),

                    const Divider(height: 26),

                    _row(
                      'Check-in Time',
                      checkinTime,
                    ),

                    const Divider(height: 26),

                    _row(
                      'Status',
                      'CHECKED IN',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F3),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: const Text(
                  'Enjoy your study session. Please leave the desk clean and available after your booking period.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF31545C),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF008C72),
                    foregroundColor:
                    Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
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
                      fontWeight:
                      FontWeight.bold,
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

  Widget _row(
      String title,
      String value,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
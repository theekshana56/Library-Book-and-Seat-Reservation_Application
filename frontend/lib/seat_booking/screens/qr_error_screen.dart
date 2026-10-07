import 'package:flutter/material.dart';

class QRErrorScreen extends StatelessWidget {
  final String seatNumber;
  final String scannedValue;
  final String errorMessage;

  const QRErrorScreen({
    super.key,
    required this.seatNumber,
    required this.scannedValue,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF073342),
        foregroundColor: Colors.white,
        title: const Text(
          'Check-in',
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
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  color: Color(0xFFD9534F),
                  size: 60,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Unable to Check In',
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                  border: Border.all(color: const Color(0xFFE1E8E7)),
                ),

                child: Column(
                  children: [
                    _row('Reserved Seat', seatNumber),

                    const Divider(height: 26),

                    _row('Expected QR', 'SEAT:$seatNumber'),

                    const Divider(height: 26),

                    _row('Scanned QR', scannedValue),

                    const Divider(height: 26),

                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: Color(0xFFD9534F)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Check that this booking is active and scan the QR code attached to the reserved seat.',
                            style: TextStyle(
                              color: Color(0xFF173B46),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFFD49A00)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Go to your reserved desk and scan the QR code attached to that desk.',
                        style: TextStyle(
                          color: Color(0xFF66511B),
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
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005F4B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(Icons.qr_code_scanner),

                  label: const Text(
                    'Scan Again',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
          style: const TextStyle(color: Color(0xFF809094), fontSize: 11),
        ),

        const SizedBox(width: 15),

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

import 'package:flutter/material.dart';
import 'checkin_success_screen.dart';

class QRScannerScreen extends StatelessWidget {
  final String seatNumber;

  const QRScannerScreen({
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

              const Center(
                child: Column(
                  children: [
                    Text(
                      'Scan QR Code',
                      style: TextStyle(
                        color: Color(0xFF0A3443),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Point your camera at the QR code near your\nreserved seat to check in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF78868A),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF102D3C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      color: Colors.white24,
                      size: 140,
                    ),

                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF00D5B0),
                          width: 3,
                        ),
                      ),
                    ),

                    const Positioned(
                      top: 25,
                      left: 25,
                      child: _ScannerCorner(
                        top: true,
                        left: true,
                      ),
                    ),

                    const Positioned(
                      top: 25,
                      right: 25,
                      child: _ScannerCorner(
                        top: true,
                        left: false,
                      ),
                    ),

                    const Positioned(
                      bottom: 25,
                      left: 25,
                      child: _ScannerCorner(
                        top: false,
                        left: true,
                      ),
                    ),

                    const Positioned(
                      bottom: 25,
                      right: 25,
                      child: _ScannerCorner(
                        top: false,
                        left: false,
                      ),
                    ),

                    const Positioned(
                      bottom: 12,
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Camera Active',
                            style: TextStyle(
                              color: Colors.white70,
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
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF008C72),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        seatNumber,
                        style: const TextStyle(
                          color: Colors.white,
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
                            'Desk $seatNumber – Window Side',
                            style: const TextStyle(
                              color: Color(0xFF173B46),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Level 2 Quiet Zone • 10:00 AM – 12:00 PM',
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

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
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
                        builder: (context) => CheckinSuccessScreen(
                          seatNumber: seatNumber,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Simulate Valid QR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF53676D),
                    side: const BorderSide(
                      color: Color(0xFFD6E0DF),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Invalid QR detected – error screen next.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: const Text(
                    'Simulate Invalid QR',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.flashlight_on_outlined,
                      color: Color(0xFF60757B),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Flashlight',
                      style: TextStyle(
                        color: Color(0xFF60757B),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final bool top;
  final bool left;

  const _ScannerCorner({
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(
        painter: _ScannerCornerPainter(
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _ScannerCornerPainter({
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E0B8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (top && left) {
      path
        ..moveTo(0, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0);
    } else if (top && !left) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height);
    } else if (!top && left) {
      path
        ..moveTo(0, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
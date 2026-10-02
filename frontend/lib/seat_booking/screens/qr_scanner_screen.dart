import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'checkin_success_screen.dart';
import 'qr_error_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final String seatNumber;

  const QRScannerScreen({
    super.key,
    required this.seatNumber,
  });

  @override
  State<QRScannerScreen> createState() =>
      _QRScannerScreenState();
}

class _QRScannerScreenState
    extends State<QRScannerScreen> {
  final MobileScannerController _controller =
  MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  bool _processing = false;

  Future<void> _handleQR(
      BarcodeCapture capture,
      ) async {
    if (_processing || capture.barcodes.isEmpty) {
      return;
    }

    final rawValue =
        capture.barcodes.first.rawValue;

    if (rawValue == null ||
        rawValue.trim().isEmpty) {
      return;
    }

    _processing = true;

    final scanned =
    rawValue.trim().toUpperCase();

    final reservedSeat =
    widget.seatNumber.trim().toUpperCase();

    final expectedQR =
        'SEAT:$reservedSeat';

    final valid =
        scanned == expectedQR ||
            scanned == reservedSeat;

    try {
      await _controller.stop();
    } catch (_) {}

    if (!mounted) {
      return;
    }

    if (valid) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckinSuccessScreen(
            seatNumber: widget.seatNumber,
          ),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QRErrorScreen(
            seatNumber: widget.seatNumber,
            scannedValue: scanned,
          ),
        ),
      );
    }

    if (!mounted) {
      return;
    }

    _processing = false;

    try {
      await _controller.start();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF073342),
        foregroundColor: Colors.white,
        title: const Text(
          'Scan QR Code',
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
            18,
            18,
            30,
          ),

          child: Column(
            children: [
              const Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Point your camera at the QR code attached to your reserved desk.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF78868A),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              ClipRRect(
                borderRadius:
                BorderRadius.circular(20),

                child: SizedBox(
                  height: 330,
                  width: double.infinity,

                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _handleQR,

                        errorBuilder:
                            (context, error) {
                          return Container(
                            color:
                            const Color(0xFF102D3C),
                            alignment:
                            Alignment.center,
                            padding:
                            const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons
                                      .camera_alt_outlined,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  error.errorCode.message,
                                  textAlign:
                                  TextAlign.center,
                                  style:
                                  const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration:
                          BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                            border: Border.all(
                              color:
                              const Color(
                                0xFF00E0B8,
                              ),
                              width: 3,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 14,
                        child: Center(
                          child: Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              Colors.black54,
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: const Text(
                              'Camera Active',
                              style: TextStyle(
                                color:
                                Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF8F4),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF008C72),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.seatNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Desk ${widget.seatNumber}',
                            style: const TextStyle(
                              color:
                              Color(0xFF173B46),
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Level 2 Quiet Zone',
                            style: TextStyle(
                              color:
                              Color(0xFF78868A),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _controller.toggleTorch();
                  },
                  icon: const Icon(
                    Icons.flashlight_on_outlined,
                  ),
                  label: const Text(
                    'Flashlight',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Expected QR: SEAT:${widget.seatNumber}',
                style: const TextStyle(
                  color: Color(0xFF78868A),
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
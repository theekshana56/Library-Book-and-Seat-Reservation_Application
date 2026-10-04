import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../api/seat_booking_api.dart';
import 'checkin_success_screen.dart';
import 'qr_error_screen.dart';

class QRScannerScreen
    extends StatefulWidget {

  final String bookingId;

  final String seatNumber;

  const QRScannerScreen({
    super.key,
    required this.bookingId,
    required this.seatNumber,
  });

  @override
  State<QRScannerScreen>
  createState() =>
      _QRScannerScreenState();
}

class _QRScannerScreenState
    extends State<
      QRScannerScreen
    > {

  final SeatBookingApi _api =
      SeatBookingApi();

  late final
  MobileScannerController
      _controller;

  bool _processing = false;

  @override
  void initState() {

    super.initState();

    _controller =
        MobileScannerController(

      detectionSpeed:
          DetectionSpeed
              .noDuplicates,

      formats: const [
        BarcodeFormat.qrCode,
      ],
    );
  }

  String _seatCodeFromQr(
    String raw,
  ) {

    final value =
        raw
            .trim()
            .toUpperCase();

    if (
      value.startsWith(
        'SEAT:',
      )
    ) {

      return value
          .substring(5)
          .trim();
    }

    return value;
  }

  Future<void>
  _handleQr(
    BarcodeCapture capture,
  ) async {

    if (
      _processing ||
          capture
              .barcodes
              .isEmpty
    ) {

      return;
    }

    final raw =
        capture
            .barcodes
            .first
            .rawValue;

    if (
      raw == null ||
          raw
              .trim()
              .isEmpty
    ) {

      return;
    }

    setState(() {
      _processing = true;
    });

    final scannedSeat =
        _seatCodeFromQr(
      raw,
    );

    try {

      await _controller
          .stop();

      await _api
          .checkIn(

        bookingId:
            widget
                .bookingId,

        seatCode:
            scannedSeat,
      );

      if (!mounted) {
        return;
      }

      await Navigator
          .of(context)
          .push(

        MaterialPageRoute(
          builder:
              (_) =>
                  CheckinSuccessScreen(

            seatNumber:
                widget
                    .seatNumber,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator
          .of(context)
          .pop();

    } catch (_) {

      if (!mounted) {
        return;
      }

      await Navigator
          .of(context)
          .push(

        MaterialPageRoute(
          builder:
              (_) =>
                  QRErrorScreen(

            seatNumber:
                widget
                    .seatNumber,

            scannedValue:
                raw.trim(),
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _processing =
            false;
      });

      try {

        await _controller
            .start();

      } catch (_) {}
    }
  }

  @override
  void dispose() {

    _controller
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF8FAFA,
      ),

      appBar: AppBar(

        backgroundColor:
            const Color(
          0xFF073342,
        ),

        foregroundColor:
            Colors.white,

        title:
            const Text(
          'Scan QR Code',
          style:
              TextStyle(
            fontWeight:
                FontWeight
                    .w800,
          ),
        ),
      ),

      body: SafeArea(

        child: ListView(

          padding:
              const EdgeInsets
                  .fromLTRB(
            18,
            20,
            18,
            30,
          ),

          children: [

            const Text(
              'Scan QR Code',
              textAlign:
                  TextAlign
                      .center,
              style:
                  TextStyle(
                color:
                    Color(
                  0xFF0A3443,
                ),
                fontSize:
                    24,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            const Text(
              'Point the camera at the QR code attached to your reserved desk.',
              textAlign:
                  TextAlign
                      .center,
              style:
                  TextStyle(
                color:
                    Color(
                  0xFF78868A,
                ),
                fontSize:
                    12,
                height:
                    1.4,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            ClipRRect(

              borderRadius:
                  BorderRadius
                      .circular(
                20,
              ),

              child: SizedBox(

                height:
                    330,

                child: Stack(

                  fit:
                      StackFit
                          .expand,

                  children: [

                    MobileScanner(

                      controller:
                          _controller,

                      onDetect:
                          _handleQr,

                      errorBuilder:
                          (
                        context,
                        error,
                      ) {

                        return Container(

                          color:
                              const Color(
                            0xFF102D3C,
                          ),

                          padding:
                              const EdgeInsets
                                  .all(
                            20,
                          ),

                          alignment:
                              Alignment
                                  .center,

                          child:
                              const Column(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [

                              Icon(
                                Icons
                                    .camera_alt_outlined,
                                color:
                                    Colors
                                        .white,
                                size:
                                    48,
                              ),

                              SizedBox(
                                height:
                                    12,
                              ),

                              Text(
                                'Camera is unavailable. Check camera permission and try again.',
                                textAlign:
                                    TextAlign
                                        .center,
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    Center(
                      child:
                          Container(

                        width:
                            220,

                        height:
                            220,

                        decoration:
                            BoxDecoration(

                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),

                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFF00E0B8,
                            ),
                            width:
                                3,
                          ),
                        ),
                      ),
                    ),

                    if (_processing)

                      Container(

                        color:
                            Colors
                                .black45,

                        alignment:
                            Alignment
                                .center,

                        child:
                            const Column(

                          mainAxisSize:
                              MainAxisSize
                                  .min,

                          children: [

                            CircularProgressIndicator(
                              color:
                                  Colors
                                      .white,
                            ),

                            SizedBox(
                              height:
                                  10,
                            ),

                            Text(
                              'Validating QR...',
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Container(

              padding:
                  const EdgeInsets
                      .all(
                14,
              ),

              decoration:
                  BoxDecoration(

                color:
                    const Color(
                  0xFFEDF8F4,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),

              child: Row(
                children: [

                  Container(

                    width:
                        56,

                    height:
                        56,

                    alignment:
                        Alignment
                            .center,

                    decoration:
                        BoxDecoration(

                      color:
                          const Color(
                        0xFF008C72,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),

                    child: Text(

                      widget
                          .seatNumber,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(
                          'Reserved desk ${widget.seatNumber}',
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF173B46,
                            ),
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),

                        const SizedBox(
                          height:
                              3,
                        ),

                        Text(
                          'Expected QR: SEAT:${widget.seatNumber.toUpperCase()}',
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF78868A,
                            ),
                            fontSize:
                                10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            const Text(
              'For testing, create a QR code containing the text shown above and scan it from another device.',
              textAlign:
                  TextAlign
                      .center,
              style:
                  TextStyle(
                color:
                    Color(
                  0xFF78868A,
                ),
                fontSize:
                    10,
                height:
                    1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
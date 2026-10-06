import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/seat_booking_api.dart';
import '../models/seat_booking_models.dart';
import 'booking_success_screen.dart';

class ReviewBookingScreen
    extends StatefulWidget {

  final SeatMapSeat seat;

  final String bookingDate;

  final String startTime;

  final String endTime;

  final String? userId;

  const ReviewBookingScreen({
    super.key,
    required this.seat,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.userId,
  });

  @override
  State<ReviewBookingScreen>
  createState() =>
      _ReviewBookingScreenState();
}

class _ReviewBookingScreenState
    extends State<
      ReviewBookingScreen
    > {

  static const _green =
      Color(0xFF005F4B);

  final SeatBookingApi _api =
      SeatBookingApi();

  bool _saving = false;

  String _prettyDate(
    String value,
  ) {

    final parsed =
        DateTime.tryParse(
      value,
    );

    return parsed == null
        ? value
        : DateFormat(
            'dd MMMM yyyy',
          ).format(
            parsed,
          );
  }

  String _prettyTime(
    String value,
  ) {

    try {

      return DateFormat(
        'h:mm a',
      ).format(

        DateFormat(
          'HH:mm:ss',
        ).parse(
          value,
        ),
      );

    } catch (_) {

      return value;
    }
  }

  String get _durationLabel {

    try {

      final start =
          DateFormat(
        'HH:mm:ss',
      ).parse(
        widget.startTime,
      );

      final end =
          DateFormat(
        'HH:mm:ss',
      ).parse(
        widget.endTime,
      );

      final minutes =
          end
              .difference(
                start,
              )
              .inMinutes;

      final hours =
          minutes ~/ 60;

      final remainder =
          minutes % 60;

      if (
        remainder == 0
      ) {

        return '$hours ${hours == 1 ? 'Hour' : 'Hours'}';
      }

      return '$hours h $remainder min';

    } catch (_) {

      return 'Selected duration';
    }
  }

  Future<void>
  _confirm() async {

    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {

      final booking =
          await _api
              .createBooking(

        seatCode:
            widget
                .seat
                .seatCode,

        bookingDate:
            widget
                .bookingDate,

        startTime:
            widget
                .startTime,

        endTime:
            widget
                .endTime,

        userId:
            widget.userId,
      );

      if (!mounted) {
        return;
      }

      Navigator
          .of(context)
          .pushReplacement(

        MaterialPageRoute(
          builder:
              (_) =>
                  BookingSuccessScreen(

            booking:
                booking,

            seat:
                widget.seat,
          ),
        ),
      );

    } catch (e) {

      if (!mounted) {
        return;
      }

      ScaffoldMessenger
          .of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text(
            e.toString(),
          ),
          backgroundColor:
              Colors.red,
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          _saving = false;
        });
      }
    }
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
          'Review Booking',
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
              'Review Booking',
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
              height: 5,
            ),

            const Text(
              'Check the reservation details before confirming.',
              style:
                  TextStyle(
                color:
                    Color(
                  0xFF78868A,
                ),
                fontSize:
                    12,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Container(

              padding:
                  const EdgeInsets
                      .all(
                18,
              ),

              decoration:
                  BoxDecoration(

                gradient:
                    const LinearGradient(
                  colors: [
                    Color(
                      0xFF087E6A,
                    ),
                    Color(
                      0xFF00A087,
                    ),
                  ],
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  18,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const Text(
                    'SELECTED SEAT',
                    style:
                        TextStyle(
                      color:
                          Colors
                              .white70,
                      fontSize:
                          10,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                        5,
                  ),

                  Text(
                    widget
                        .seat
                        .seatCode,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          34,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  Text(
                    '${widget.seat.floor} ${widget.seat.zone}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Container(

              padding:
                  const EdgeInsets
                      .all(
                16,
              ),

              decoration:
                  BoxDecoration(

                color:
                    Colors.white,

                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE1E8E7,
                  ),
                ),
              ),

              child: Column(
                children: [

                  _detail(
                    Icons
                        .calendar_today_outlined,
                    'Date',
                    _prettyDate(
                      widget
                          .bookingDate,
                    ),
                  ),

                  const Divider(
                    height: 26,
                  ),

                  _detail(
                    Icons
                        .access_time,
                    'Time',
                    '${_prettyTime(widget.startTime)} – '
                    '${_prettyTime(widget.endTime)}',
                  ),

                  const Divider(
                    height: 26,
                  ),

                  _detail(
                    Icons
                        .timelapse,
                    'Duration',
                    _durationLabel,
                  ),

                  const Divider(
                    height: 26,
                  ),

                  _detail(
                    Icons
                        .location_on_outlined,
                    'Location',
                    '${widget.seat.floor} ${widget.seat.zone}',
                  ),

                  const Divider(
                    height: 26,
                  ),

                  _detail(
                    Icons
                        .chair_alt_outlined,
                    'Seat',
                    widget
                        .seat
                        .seatCode,
                  ),

                  const Divider(
                    height: 26,
                  ),

                  _detail(
                    Icons
                        .power_outlined,
                    'Facilities',
                    widget
                            .seat
                            .features
                            .isEmpty
                        ? widget
                                .seat
                                .hasPowerOutlet
                            ? 'Power Outlet'
                            : 'Standard desk'
                        : widget
                            .seat
                            .features
                            .join(
                              ' • ',
                            ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
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
                  0xFFEAF7F3,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),

              child:
                  const Row(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Icon(
                    Icons
                        .info_outline,
                    color:
                        _green,
                  ),

                  SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        Text(
                      'After booking, scan the QR code attached to the reserved desk to check in.',
                      style:
                          TextStyle(
                        fontSize:
                            11,
                        height:
                            1.4,
                        color:
                            Color(
                          0xFF31545C,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              height: 52,

              child:
                  FilledButton(

                onPressed:
                    _saving
                        ? null
                        : _confirm,

                style:
                    FilledButton
                        .styleFrom(

                  backgroundColor:
                      _green,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),

                child:
                    _saving

                    ? const SizedBox.square(
                        dimension:
                            20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )

                    : const Text(
                        'Confirm Booking',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(

              height: 46,

              child:
                  OutlinedButton(

                onPressed:
                    _saving
                        ? null
                        : () =>
                            Navigator.pop(
                              context,
                            ),

                child:
                    const Text(
                  'Change Seat',
                ),
              ),
            ),
          ],
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

          decoration:
              BoxDecoration(

            color:
                const Color(
              0xFFEAF7F3,
            ),

            borderRadius:
                BorderRadius
                    .circular(
              10,
            ),
          ),

          child: Icon(
            icon,
            color:
                _green,
            size:
                19,
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
                title,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF809094,
                  ),
                  fontSize:
                      10,
                ),
              ),

              const SizedBox(
                height:
                    3,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF173B46,
                  ),
                  fontSize:
                      13,
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
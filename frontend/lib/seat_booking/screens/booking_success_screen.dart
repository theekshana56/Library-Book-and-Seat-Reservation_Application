import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/seat_booking_models.dart';
import 'active_booking_screen.dart';

class BookingSuccessScreen
    extends StatelessWidget {

  final SeatBookingRecord booking;

  final SeatMapSeat seat;

  const BookingSuccessScreen({
    super.key,
    required this.booking,
    required this.seat,
  });

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
          'Booking Confirmed',
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
            24,
            18,
            30,
          ),

          children: [

            const Icon(
              Icons
                  .check_circle,
              color:
                  Color(
                0xFF005F4B,
              ),
              size:
                  82,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Seat Reserved Successfully!',
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
                    23,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            const Text(
              'Your reservation has been saved.',
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
              ),
            ),

            const SizedBox(
              height: 22,
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
                  18,
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

                  Container(

                    width: 72,
                    height: 72,

                    alignment:
                        Alignment
                            .center,

                    decoration:
                        BoxDecoration(

                      color:
                          const Color(
                        0xFF005F4B,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),

                    child: Text(

                      booking
                          .seatCode,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            20,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Text(
                    '${seat.floor} ${seat.zone}',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF173B46,
                      ),
                      fontSize:
                          16,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _row(
                    'Date',
                    _prettyDate(
                      booking
                          .bookingDate,
                    ),
                  ),

                  const Divider(
                    height: 25,
                  ),

                  _row(
                    'Time',
                    '${_prettyTime(booking.startTime)} – '
                    '${_prettyTime(booking.endTime)}',
                  ),

                  const Divider(
                    height: 25,
                  ),

                  _row(
                    'Status',
                    booking.status,
                  ),

                  const Divider(
                    height: 25,
                  ),

                  _row(
                    'Booking ID',
                    booking.id,
                  ),
                ],
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
                  0xFFEAF7F3,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),

              child:
                  const Text(

                'Go to your reserved desk and use its QR code when you are ready to check in.',

                textAlign:
                    TextAlign
                        .center,

                style:
                    TextStyle(
                  color:
                      Color(
                    0xFF31545C,
                  ),
                  fontSize:
                      11,
                  height:
                      1.4,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              height: 52,

              child:
                  FilledButton(

                onPressed: () {

                  Navigator
                      .of(context)
                      .pushReplacement(

                    MaterialPageRoute(
                      builder:
                          (_) =>
                              ActiveBookingScreen(

                        bookingId:
                            booking.id,

                        seat:
                            seat,
                      ),
                    ),
                  );
                },

                style:
                    FilledButton
                        .styleFrom(

                  backgroundColor:
                      const Color(
                    0xFF005F4B,
                  ),

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
                    const Text(
                  'View Booking',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String title,
    String value,
  ) {

    return Row(

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
                11,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Text(
            value,
            textAlign:
                TextAlign
                    .right,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF173B46,
              ),
              fontWeight:
                  FontWeight
                      .w600,
              fontSize:
                  12,
            ),
          ),
        ),
      ],
    );
  }
}
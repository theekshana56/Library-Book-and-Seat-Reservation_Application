import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/seat_booking_api.dart';
import '../models/seat_booking_models.dart';
import 'qr_scanner_screen.dart';

class ActiveBookingScreen
    extends StatefulWidget {

  final String bookingId;

  final SeatMapSeat seat;

  const ActiveBookingScreen({
    super.key,
    required this.bookingId,
    required this.seat,
  });

  @override
  State<ActiveBookingScreen>
  createState() =>
      _ActiveBookingScreenState();
}

class _ActiveBookingScreenState
    extends State<
      ActiveBookingScreen
    > {

  static const _green =
      Color(0xFF008C72);

  final SeatBookingApi _api =
      SeatBookingApi();

  SeatBookingRecord? _booking;

  bool _loading = true;

  bool _actionLoading =
      false;

  String? _error;

  @override
  void initState() {

    super.initState();

    _load();
  }

  Future<void> _load() async {

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      final booking =
          await _api
              .getBooking(
        widget.bookingId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _booking =
            booking;
      });

    } catch (e) {

      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            e.toString();
      });

    } finally {

      if (mounted) {

        setState(() {
          _loading =
              false;
        });
      }
    }
  }

  Future<void>
  _scanQr() async {

    final booking =
        _booking;

    if (booking == null) {
      return;
    }

    await Navigator
        .of(context)
        .push(

      MaterialPageRoute(
        builder:
            (_) =>
                QRScannerScreen(

          bookingId:
              booking.id,

          seatNumber:
              booking
                  .seatCode,
        ),
      ),
    );

    if (mounted) {

      await _load();
    }
  }

  Future<void>
  _cancel() async {

    final booking =
        _booking;

    if (booking == null) {
      return;
    }

    final yes =
        await showDialog<
          bool
        >(

      context:
          context,

      builder:
          (context) =>
              AlertDialog(

        title:
            const Text(
          'Cancel Booking?',
        ),

        content:
            Text(
          'Cancel the reservation for seat ${booking.seatCode}?',
        ),

        actions: [

          TextButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              false,
            ),
            child:
                const Text(
              'Keep Booking',
            ),
          ),

          FilledButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              true,
            ),
            child:
                const Text(
              'Cancel Booking',
            ),
          ),
        ],
      ),
    );

    if (yes != true) {
      return;
    }

    setState(() {
      _actionLoading =
          true;
    });

    try {

      final updated =
          await _api
              .cancelBooking(
        booking.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _booking =
            updated;
      });

      ScaffoldMessenger
          .of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text(
            'Booking cancelled.',
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
          _actionLoading =
              false;
        });
      }
    }
  }

  Future<void>
  _delete() async {

    final booking =
        _booking;

    if (booking == null) {
      return;
    }

    final yes =
        await showDialog<
          bool
        >(

      context:
          context,

      builder:
          (context) =>
              AlertDialog(

        title:
            const Text(
          'Remove Booking Record?',
        ),

        content:
            const Text(
          'This removes this cancelled booking record from the database.',
        ),

        actions: [

          TextButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              false,
            ),
            child:
                const Text(
              'No',
            ),
          ),

          FilledButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              true,
            ),
            child:
                const Text(
              'Remove',
            ),
          ),
        ],
      ),
    );

    if (yes != true) {
      return;
    }

    setState(() {
      _actionLoading =
          true;
    });

    try {

      await _api
          .deleteBooking(
        booking.id,
      );

      if (!mounted) {
        return;
      }

      Navigator
          .of(context)
          .popUntil(
        (route) =>
            route.isFirst,
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
          _actionLoading =
              false;
        });
      }
    }
  }

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
            'dd MMM yyyy',
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

  Color _statusColor(
    String status,
  ) {

    switch (
      status.toUpperCase()
    ) {

      case 'CHECKED_IN':

        return const Color(
          0xFF0A7B61,
        );

      case 'CANCELLED':

        return Colors.redAccent;

      default:

        return _green;
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
          'My Seat Booking',
          style:
              TextStyle(
            fontWeight:
                FontWeight
                    .w800,
          ),
        ),

        actions: [

          IconButton(
            onPressed:
                _loading
                    ? null
                    : _load,
            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body:
          SafeArea(
        child:
            _body(),
      ),
    );
  }

  Widget _body() {

    if (_loading) {

      return const Center(
        child:
            CircularProgressIndicator(
          color:
              _green,
        ),
      );
    }

    if (
      _error != null ||
          _booking == null
    ) {

      return Center(

        child: Padding(

          padding:
              const EdgeInsets
                  .all(
            24,
          ),

          child: Column(

            mainAxisSize:
                MainAxisSize
                    .min,

            children: [

              const Icon(
                Icons
                    .error_outline,
                color:
                    Colors
                        .redAccent,
                size:
                    42,
              ),

              const SizedBox(
                height:
                    10,
              ),

              Text(
                _error ??
                    'Booking not found.',
                textAlign:
                    TextAlign
                        .center,
              ),

              const SizedBox(
                height:
                    14,
              ),

              OutlinedButton(
                onPressed:
                    _load,
                child:
                    const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final booking =
        _booking!;

    final status =
        booking.status
            .toUpperCase();

    final canCheckIn =
        status ==
        'RESERVED';

    final canCancel =
        status ==
        'RESERVED';

    final canDelete =
        status ==
        'CANCELLED';

    return ListView(

      padding:
          const EdgeInsets
              .fromLTRB(
        18,
        20,
        18,
        30,
      ),

      children: [

        Row(
          children: [

            const Expanded(
              child:
                  Text(
                'Active Booking',
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
            ),

            Container(

              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal:
                    10,
                vertical:
                    6,
              ),

              decoration:
                  BoxDecoration(

                color:
                    _statusColor(
                      status,
                    ).withValues(
                      alpha:
                          0.10,
                    ),

                borderRadius:
                    BorderRadius
                        .circular(
                  20,
                ),
              ),

              child: Text(

                status.replaceAll(
                  '_',
                  ' ',
                ),

                style:
                    TextStyle(
                  color:
                      _statusColor(
                    status,
                  ),
                  fontSize:
                      10,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 18,
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
                          58,
                      height:
                          58,

                      alignment:
                          Alignment
                              .center,

                      decoration:
                          BoxDecoration(

                        color:
                            _green,

                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),

                      child: Text(

                        booking
                            .seatCode,

                        style:
                            const TextStyle(
                          color:
                              Colors
                                  .white,
                          fontSize:
                              17,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width:
                          13,
                    ),

                    Expanded(
                      child:
                          Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(
                            '${widget.seat.floor} ${widget.seat.zone}',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF173B46,
                              ),
                              fontSize:
                                  15,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                          const SizedBox(
                            height:
                                4,
                          ),

                          Text(
                            widget
                                    .seat
                                    .features
                                    .isEmpty
                                ? 'Reading room seat'
                                : widget
                                    .seat
                                    .features
                                    .join(
                                      ' • ',
                                    ),
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
                height:
                    18,
              ),

              _row(
                Icons
                    .calendar_today_outlined,
                'Date',
                _prettyDate(
                  booking
                      .bookingDate,
                ),
              ),

              const Divider(
                height:
                    26,
              ),

              _row(
                Icons
                    .access_time,
                'Time',
                '${_prettyTime(booking.startTime)} – '
                '${_prettyTime(booking.endTime)}',
              ),

              const Divider(
                height:
                    26,
              ),

              _row(
                Icons
                    .confirmation_number_outlined,
                'Booking ID',
                booking.id,
              ),

              if (
                booking
                        .checkInTime !=
                    null
              ) ...[

                const Divider(
                  height:
                      26,
                ),

                _row(
                  Icons.login,
                  'Checked in',
                  booking
                      .checkInTime!,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        if (
          status ==
              'CHECKED_IN'
        )

          _message(
            icon:
                Icons
                    .check_circle_outline,
            text:
                'Check-in completed successfully. Your study session is active.',
            color:
                const Color(
              0xFFEAF7F3,
            ),
          )

        else if (
          status ==
              'CANCELLED'
        )

          _message(
            icon:
                Icons
                    .cancel_outlined,
            text:
                'This booking has been cancelled and the seat is available again.',
            color:
                const Color(
              0xFFFDECEC,
            ),
          )

        else

          _message(
            icon:
                Icons
                    .qr_code_scanner,
            text:
                'Scan the QR code attached to your reserved desk to complete check-in.',
            color:
                const Color(
              0xFFEAF7F3,
            ),
          ),

        const SizedBox(
          height: 20,
        ),

        if (canCheckIn)

          SizedBox(

            height: 52,

            child:
                FilledButton
                    .icon(

              onPressed:
                  _actionLoading
                      ? null
                      : _scanQr,

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

              icon:
                  const Icon(
                Icons
                    .qr_code_scanner,
              ),

              label:
                  const Text(
                'Check in via Desk QR',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ),
          ),

        if (canCancel) ...[

          const SizedBox(
            height: 10,
          ),

          SizedBox(

            height: 46,

            child:
                OutlinedButton(

              onPressed:
                  _actionLoading
                      ? null
                      : _cancel,

              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    Colors
                        .redAccent,
              ),

              child:
                  const Text(
                'Cancel Booking',
              ),
            ),
          ),
        ],

        if (canDelete) ...[

          const SizedBox(
            height: 10,
          ),

          SizedBox(

            height: 46,

            child:
                OutlinedButton
                    .icon(

              onPressed:
                  _actionLoading
                      ? null
                      : _delete,

              icon:
                  const Icon(
                Icons
                    .delete_outline,
              ),

              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    Colors
                        .redAccent,
              ),

              label:
                  const Text(
                'Remove Cancelled Booking',
              ),
            ),
          ),
        ],

        if (_actionLoading) ...[

          const SizedBox(
            height: 18,
          ),

          const Center(
            child:
                CircularProgressIndicator(
              color:
                  _green,
            ),
          ),
        ],
      ],
    );
  }

  Widget _message({

    required IconData icon,

    required String text,

    required Color color,

  }) {

    return Container(

      padding:
          const EdgeInsets
              .all(
        14,
      ),

      decoration:
          BoxDecoration(

        color:
            color,

        borderRadius:
            BorderRadius
                .circular(
          14,
        ),
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Icon(
            icon,
            color:
                _green,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
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
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String title,
    String value,
  ) {

    return Row(
      children: [

        Icon(
          icon,
          color:
              _green,
          size:
              20,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Text(
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
        ),

        Flexible(
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
                  11,
            ),
          ),
        ),
      ],
    );
  }
}
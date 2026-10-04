import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/seat_booking_api.dart';
import '../models/seat_booking_models.dart';
import 'review_booking_screen.dart';

class SeatMapScreen
    extends StatefulWidget {

  const SeatMapScreen({
    super.key,
  });

  @override
  State<SeatMapScreen>
  createState() =>
      _SeatMapScreenState();
}

class _SeatMapScreenState
    extends State<SeatMapScreen> {

  static const _navy =
      Color(0xFF073342);

  static const _green =
      Color(0xFF008C72);

  static const _page =
      Color(0xFFF8FAFA);

  final SeatBookingApi _api =
      SeatBookingApi();

  late DateTime _date;

  TimeOfDay _start =
      const TimeOfDay(
    hour: 10,
    minute: 0,
  );

  TimeOfDay _end =
      const TimeOfDay(
    hour: 12,
    minute: 0,
  );

  List<SeatMapSeat> _seats =
      const [];

  SeatMapSeat? _selected;

  bool _loading = true;

  String? _error;

  @override
  void initState() {

    super.initState();

    final now =
        DateTime.now();

    _date =
        DateTime(
          now.year,
          now.month,
          now.day,
        ).add(
          const Duration(
            days: 1,
          ),
        );

    _loadSeats();
  }

  String get _dateApi =>
      DateFormat(
        'yyyy-MM-dd',
      ).format(
        _date,
      );

  String _timeApi(
    TimeOfDay value,
  ) {

    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:00';
  }

  String _timeLabel(
    TimeOfDay value,
  ) {

    final hour =
        value.hourOfPeriod ==
                0
            ? 12
            : value
                .hourOfPeriod;

    final minute =
        value.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final period =
        value.period ==
                DayPeriod.am
            ? 'AM'
            : 'PM';

    return '$hour:$minute $period';
  }

  Future<void>
  _loadSeats() async {

    setState(() {
      _loading = true;
      _error = null;
      _selected = null;
    });

    try {

      final seats =
          await _api
              .getSeatMap(

        date: _dateApi,

        startTime:
            _timeApi(
          _start,
        ),

        endTime:
            _timeApi(
          _end,
        ),
      );

      if (!mounted) {
        return;
      }

      SeatMapSeat?
      firstAvailable;

      for (
        final seat in seats
      ) {

        if (seat.available) {

          firstAvailable =
              seat;

          break;
        }
      }

      setState(() {

        _seats = seats;

        _selected =
            firstAvailable;
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
  _pickDate() async {

    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final chosen =
        await showDatePicker(

      context: context,

      initialDate:
          _date.isBefore(
            today,
          )
          ? today
          : _date,

      firstDate:
          today,

      lastDate:
          today.add(
        const Duration(
          days: 30,
        ),
      ),
    );

    if (chosen == null) {
      return;
    }

    setState(() {

      _date =
          chosen;
    });

    await _loadSeats();
  }

  Future<void>
  _pickStartTime() async {

    final chosen =
        await showTimePicker(

      context: context,

      initialTime:
          _start,
    );

    if (chosen == null) {
      return;
    }

    final startMinutes =
        chosen.hour * 60 +
        chosen.minute;

    final endMinutes =
        _end.hour * 60 +
        _end.minute;

    if (
      endMinutes <=
          startMinutes
    ) {

      if (!mounted) {
        return;
      }

      ScaffoldMessenger
          .of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            'Start time must be before end time.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _start = chosen;
    });

    await _loadSeats();
  }

  Future<void>
  _pickEndTime() async {

    final chosen =
        await showTimePicker(

      context: context,

      initialTime:
          _end,
    );

    if (chosen == null) {
      return;
    }

    final startMinutes =
        _start.hour * 60 +
        _start.minute;

    final endMinutes =
        chosen.hour * 60 +
        chosen.minute;

    if (
      endMinutes <=
          startMinutes
    ) {

      if (!mounted) {
        return;
      }

      ScaffoldMessenger
          .of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            'End time must be after start time.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _end = chosen;
    });

    await _loadSeats();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          _page,

      appBar: AppBar(

        backgroundColor:
            _navy,

        foregroundColor:
            Colors.white,

        title:
            const Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Text(
              'Biblione',
              style: TextStyle(
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),

            Text(
              'SMART LIBRARY',
              style: TextStyle(
                fontSize: 9,
                letterSpacing:
                    1.4,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(

        child:
            RefreshIndicator(

          onRefresh:
              _loadSeats,

          child: ListView(

            physics:
                const AlwaysScrollableScrollPhysics(),

            padding:
                const EdgeInsets
                    .fromLTRB(
              18,
              18,
              18,
              28,
            ),

            children: [

              const Text(
                'Quiet Zone – Seat Map',
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
                'Choose a date, time and an available desk.',
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
                height: 16,
              ),

              _pickerCard(
                icon:
                    Icons
                        .calendar_today_outlined,
                title:
                    'Date',
                value:
                    DateFormat(
                  'dd MMM yyyy',
                ).format(
                  _date,
                ),
                onTap:
                    _pickDate,
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [

                  Expanded(
                    child:
                        _pickerCard(
                      icon:
                          Icons
                              .access_time,
                      title:
                          'Start Time',
                      value:
                          _timeLabel(
                        _start,
                      ),
                      onTap:
                          _pickStartTime,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        _pickerCard(
                      icon:
                          Icons
                              .schedule,
                      title:
                          'End Time',
                      value:
                          _timeLabel(
                        _end,
                      ),
                      onTap:
                          _pickEndTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [

                  _legend(
                    const Color(
                      0xFFF0F4F4,
                    ),
                    'Available',
                  ),

                  _legend(
                    const Color(
                      0xFFB8C1C5,
                    ),
                    'Occupied',
                  ),

                  _legend(
                    _green,
                    'Selected',
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              _seatArea(),

              const SizedBox(
                height: 18,
              ),

              if (
                _selected !=
                    null
              )
                _selectedCard(
                  _selected!,
                ),

              const SizedBox(
                height: 18,
              ),

              SizedBox(

                height: 52,

                child:
                    FilledButton(

                  onPressed:
                      _selected ==
                              null
                          ? null
                          : () {

                              Navigator
                                  .of(
                                    context,
                                  )
                                  .push(

                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          ReviewBookingScreen(

                                    seat:
                                        _selected!,

                                    bookingDate:
                                        _dateApi,

                                    startTime:
                                        _timeApi(
                                      _start,
                                    ),

                                    endTime:
                                        _timeApi(
                                      _end,
                                    ),
                                  ),
                                ),
                              );
                            },

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

                  child: Text(

                    _selected ==
                            null
                        ? 'Select an Available Seat'
                        : 'Continue with ${_selected!.seatCode}',

                    style:
                        const TextStyle(
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
      ),
    );
  }

  Widget _seatArea() {

    if (_loading) {

      return const SizedBox(
        height: 260,
        child: Center(
          child:
              CircularProgressIndicator(
            color:
                _green,
          ),
        ),
      );
    }

    if (_error != null) {

      return Container(

        padding:
            const EdgeInsets
                .all(18),

        decoration:
            BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius
                  .circular(16),
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

            const Icon(
              Icons
                  .cloud_off_outlined,
              size: 38,
              color:
                  Colors.redAccent,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              _error!,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton(
              onPressed:
                  _loadSeats,
              child:
                  const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      );
    }

    if (_seats.isEmpty) {

      return const Center(
        child: Text(
          'No seats found.',
        ),
      );
    }

    return Container(

      padding:
          const EdgeInsets
              .all(16),

      decoration:
          BoxDecoration(

        color:
            Colors.white,

        borderRadius:
            BorderRadius
                .circular(18),

        border:
            Border.all(
          color:
              const Color(
            0xFFE1E8E7,
          ),
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          const Row(
            children: [

              Icon(
                Icons
                    .window_outlined,
                color:
                    _green,
                size: 19,
              ),

              SizedBox(
                width: 7,
              ),

              Text(
                'ROW A – WINDOW SIDE',
                style:
                    TextStyle(
                  color:
                      Color(
                    0xFF153A45,
                  ),
                  fontSize:
                      12,
                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          GridView.builder(

            shrinkWrap:
                true,

            physics:
                const NeverScrollableScrollPhysics(),

            itemCount:
                _seats.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount:
                  3,

              crossAxisSpacing:
                  10,

              mainAxisSpacing:
                  10,

              childAspectRatio:
                  1.12,
            ),

            itemBuilder:
                (
              context,
              index,
            ) {

              final seat =
                  _seats[
                    index
                  ];

              final selected =
                  _selected
                          ?.seatCode ==
                      seat
                          .seatCode;

              final background =
                  selected
                      ? _green
                      : seat.available
                      ? const Color(
                          0xFFF0F4F4,
                        )
                      : const Color(
                          0xFFB8C1C5,
                        );

              final foreground =
                  selected ||
                          !seat
                              .available
                      ? Colors
                          .white
                      : const Color(
                          0xFF123642,
                        );

              return InkWell(

                onTap:
                    seat.available
                        ? () {

                            setState(
                              () {

                                _selected =
                                    seat;
                              },
                            );
                          }
                        : null,

                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),

                child:
                    AnimatedContainer(

                  duration:
                      const Duration(
                    milliseconds:
                        160,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        background,

                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),

                    border:
                        Border.all(
                      color:
                          selected
                              ? _green
                              : const Color(
                                  0xFFDCE5E4,
                                ),
                      width:
                          1.4,
                    ),
                  ),

                  child:
                      Column(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [

                      Icon(
                        Icons
                            .chair_alt_outlined,
                        color:
                            foreground,
                        size:
                            24,
                      ),

                      const SizedBox(
                        height:
                            4,
                      ),

                      Text(
                        seat
                            .seatCode,
                        style:
                            TextStyle(
                          color:
                              foreground,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      Text(
                        seat.available
                            ? 'Available'
                            : 'Occupied',
                        style:
                            TextStyle(
                          color:
                              foreground
                                  .withValues(
                            alpha:
                                0.85,
                          ),
                          fontSize:
                              9,
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
    );
  }

  Widget _selectedCard(
    SeatMapSeat seat,
  ) {

    return Container(

      padding:
          const EdgeInsets
              .all(14),

      decoration:
          BoxDecoration(

        color:
            const Color(
          0xFFEDF8F4,
        ),

        borderRadius:
            BorderRadius
                .circular(14),
      ),

      child: Row(
        children: [

          Container(
            width: 56,
            height: 56,
            alignment:
                Alignment.center,
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
              seat.seatCode,
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
                  '${seat.floor} ${seat.zone}',
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
                  height: 4,
                ),

                Text(
                  '${seat.hasPowerOutlet ? 'Power outlet' : 'No power outlet'}'
                  '${seat.features.isEmpty ? '' : ' • ${seat.features.join(' • ')}'}',
                  maxLines:
                      2,
                  overflow:
                      TextOverflow
                          .ellipsis,
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
    );
  }

  Widget _pickerCard({

    required IconData icon,

    required String title,

    required String value,

    required VoidCallback onTap,

  }) {

    return InkWell(

      onTap:
          onTap,

      borderRadius:
          BorderRadius
              .circular(12),

      child: Container(

        padding:
            const EdgeInsets
                .all(12),

        decoration:
            BoxDecoration(

          color:
              Colors.white,

          borderRadius:
              BorderRadius
                  .circular(12),

          border:
              Border.all(
            color:
                const Color(
              0xFFE1E8E7,
            ),
          ),
        ),

        child: Row(
          children: [

            Icon(
              icon,
              color:
                  _green,
              size:
                  19,
            ),

            const SizedBox(
              width: 8,
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
                      fontSize:
                          9,
                      color:
                          Color(
                        0xFF809094,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        2,
                  ),

                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize:
                          11,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(
    Color color,
    String label,
  ) {

    return Expanded(
      child: Row(
        children: [

          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(
              color:
                  color,
              borderRadius:
                  BorderRadius
                      .circular(
                3,
              ),
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          Flexible(
            child: Text(
              label,
              style:
                  const TextStyle(
                fontSize:
                    9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
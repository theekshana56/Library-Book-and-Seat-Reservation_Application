import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../seat_booking/screens/seat_map_screen.dart';
import '../../theme/app_colors.dart';
import '../api/seat_recommender_api.dart';
import '../models/seat_recommendation.dart';
import 'empty_state_screen.dart';
import 'ranked_results_screen.dart';

class FindSeatScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? userId;

  const FindSeatScreen({
    super.key,
    this.onBack,
    this.userId,
  });

  @override
  State<FindSeatScreen> createState() =>
      _FindSeatScreenState();
}

class _FindSeatScreenState extends State<FindSeatScreen> {
  static const _horizontalInset = 18.0;

  static const _times = [
    '08:00:00',
    '09:00:00',
    '10:00:00',
    '11:00:00',
    '13:00:00',
    '14:00:00',
  ];

  static const _durations = [
    60,
    150,
    240,
    360,
  ];

  final _api = SeatRecommenderApi();

  DateTime _date =
      DateUtils.dateOnly(DateTime.now());

  String _zone = 'Quiet Zone';

  String _startTime = '09:00:00';

  int _duration = 150;

  bool? _powerRequired;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _syncSelectedTime();
  }

  Future<void> _selectDate() async {
    final today =
        DateUtils.dateOnly(
      DateTime.now(),
    );

    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          _date.isBefore(today)
              ? today
              : _date,
      firstDate: today,
      lastDate:
          today.add(
        const Duration(
          days: 14,
        ),
      ),
      builder:
          (context, child) =>
              Theme(
        data:
            Theme.of(context)
                .copyWith(
          colorScheme:
              Theme.of(context)
                  .colorScheme
                  .copyWith(
            primary:
                AppColors.emerald,
          ),
        ),
        child: child!,
      ),
    );

    if (selected != null) {
      setState(() {
        _date = selected;
        _syncSelectedTime();
      });
    }
  }

  void _syncSelectedTime() {
    if (_isTimeSelectable(
      _startTime,
    )) {
      return;
    }

    final available =
        _times.where(
      _isTimeSelectable,
    );

    _startTime =
        available.isEmpty
            ? ''
            : available.first;
  }

  bool _isTimeSelectable(
    String time,
  ) {
    if (time.isEmpty) {
      return false;
    }

    final now =
        DateTime.now();

    final today =
        DateUtils.dateOnly(
      now,
    );

    final selectedDate =
        DateUtils.dateOnly(
      _date,
    );

    if (selectedDate.isBefore(
      today,
    )) {
      return false;
    }

    if (selectedDate.isAfter(
      today,
    )) {
      return true;
    }

    final parsed =
        DateFormat(
      'HH:mm:ss',
    ).parse(
      time,
    );

    final start =
        DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    );

    return !start.isBefore(
      now.add(
        const Duration(
          hours: 2,
        ),
      ),
    );
  }

  Future<void> _search() async {
    if (!_isTimeSelectable(
      _startTime,
    )) {
      ScaffoldMessenger
          .of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Choose a start time at least 2 hours from now.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    final request =
        SeatSearchRequest(
      date: _date,
      startTime: _startTime,
      durationMinutes:
          _duration,
      zonePreference:
          _zone,
      powerRequired:
          _powerRequired,
    );

    try {
      final response =
          await _api.recommend(
        request,
      );

      if (!mounted) {
        return;
      }

      final screen =
          response
                  .exactMatches
                  .isNotEmpty
              ? RankedResultsScreen(
                  response:
                      response,
                  request:
                      request,
                  userId:
                      widget.userId,
                )
              : EmptyStateScreen(
                  response:
                      response,
                  request:
                      request,
                );

      await Navigator
          .of(context)
          .push(
        MaterialPageRoute<void>(
          builder:
              (_) => screen,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openSeatMap() async {
    await Navigator
        .of(context)
        .push<void>(
      MaterialPageRoute(
        builder:
            (_) =>
                const SeatMapScreen(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.pageBg,

      bottomNavigationBar:
          SafeArea(
        top: false,
        child: Container(
          padding:
              const EdgeInsets
                  .fromLTRB(
            _horizontalInset,
            12,
            _horizontalInset,
            14,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color:
                    Color(
                  0xFFE5EAF0,
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize
                    .min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons
                        .event_seat_outlined,
                    color:
                        AppColors
                            .emerald,
                    size: 19,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      'Matches Found',
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          _labelStyle(),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      _isTimeSelectable(
                        _startTime,
                      )
                          ? '${_times.where(_isTimeSelectable).length} times available'
                          : 'No times available today',
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      textAlign:
                          TextAlign
                              .end,
                      style:
                          _mutedStyle(
                        10,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    FilledButton
                        .icon(
                  onPressed:
                      _loading ||
                              !_isTimeSelectable(
                                _startTime,
                              )
                          ? null
                          : _search,
                  icon:
                      _loading
                          ? const SizedBox
                              .square(
                              dimension:
                                  18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .auto_awesome,
                              size:
                                  18,
                            ),
                  label: Text(
                    _loading
                        ? 'Finding seats...'
                        : 'Find My Seat',
                  ),
                  style:
                      FilledButton
                          .styleFrom(
                    backgroundColor:
                        AppColors
                            .emerald,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    textStyle:
                        GoogleFonts
                            .plusJakartaSans(
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 44,
                child:
                    OutlinedButton
                        .icon(
                  onPressed:
                      _loading
                          ? null
                          : _openSeatMap,
                  icon:
                      const Icon(
                    Icons
                        .grid_view_rounded,
                    size: 18,
                  ),
                  label:
                      const Text(
                    'Browse Seat Map',
                  ),
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        AppColors
                            .emerald,
                    side:
                        const BorderSide(
                      color:
                          AppColors
                              .emerald,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    textStyle:
                        GoogleFonts
                            .plusJakartaSans(
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

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(
              context,
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  _horizontalInset,
                  16,
                  _horizontalInset,
                  22,
                ),
                children: [
                  _hero(),

                  const SizedBox(
                    height: 22,
                  ),

                  _sectionTitle(
                    'When do you need a seat?',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _dateSelector(),

                  const SizedBox(
                    height: 22,
                  ),

                  _sectionTitle(
                    'Zone preference',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _segmented<String>(
                    values:
                        const [
                      'Quiet Zone',
                      'Social Zone',
                    ],
                    selected:
                        _zone,
                    label:
                        (value) =>
                            value,
                    onSelected:
                        (value) {
                      setState(() {
                        _zone =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _sectionTitle(
                    'Power outlet required',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _segmented<bool?>(
                    values:
                        const [
                      true,
                      false,
                      null,
                    ],
                    selected:
                        _powerRequired,
                    label:
                        (value) {
                      if (value ==
                          null) {
                        return 'Any';
                      }

                      return value
                          ? 'Yes'
                          : 'No';
                    },
                    onSelected:
                        (value) {
                      setState(() {
                        _powerRequired =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _sectionTitle(
                    'Start time',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    DateUtils.isSameDay(
                      _date,
                      DateTime.now(),
                    )
                        ? "Today's starts require at least 2 hours' notice."
                        : "Start times use the library's local time.",
                    style:
                        _mutedStyle(
                      10,
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  LayoutBuilder(
                    builder:
                        (
                      context,
                      constraints,
                    ) {
                      const spacing =
                          8.0;

                      final tileWidth =
                          (constraints
                                      .maxWidth -
                                  spacing *
                                      2) /
                              3;

                      return Wrap(
                        spacing:
                            spacing,
                        runSpacing:
                            spacing,
                        children:
                            _times
                                .map(
                          (time) {
                            final available =
                                _isTimeSelectable(
                              time,
                            );

                            final selected =
                                time ==
                                    _startTime;

                            return _choiceTile(
                              width:
                                  tileWidth,
                              selected:
                                  selected,
                              enabled:
                                  available,
                              label:
                                  DateFormat(
                                'h:mm a',
                              ).format(
                                DateFormat(
                                  'HH:mm:ss',
                                ).parse(
                                  time,
                                ),
                              ),
                              onTap:
                                  () {
                                setState(
                                  () {
                                    _startTime =
                                        time;
                                  },
                                );
                              },
                            );
                          },
                        ).toList(),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _sectionTitle(
                    'How long?',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _segmented<int>(
                    values:
                        _durations,
                    selected:
                        _duration,
                    label:
                        _durationLabel,
                    onSelected:
                        (value) {
                      setState(() {
                        _duration =
                            value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
  ) =>
      Container(
        color:
            AppColors.navy,
        padding:
            const EdgeInsets
                .fromLTRB(
          10,
          6,
          20,
          16,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed:
                  widget.onBack ??
                      () =>
                          Navigator
                              .maybePop(
                                context,
                              ),
              icon:
                  const Icon(
                Icons.arrow_back,
                color:
                    Colors.white,
              ),
              tooltip: 'Back',
            ),

            const SizedBox(
              width: 2,
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'SMART ASSISTANT',
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    color:
                        const Color(
                      0xFF9DB3C7,
                    ),
                    fontSize:
                        9,
                    fontWeight:
                        FontWeight
                            .w800,
                    letterSpacing:
                        0.8,
                  ),
                ),

                Text(
                  'Find My Seat',
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    color:
                        Colors.white,
                    fontSize:
                        20,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _hero() =>
      Container(
        padding:
            const EdgeInsets
                .all(
          18,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.navy,
          borderRadius:
              BorderRadius
                  .circular(
            16,
          ),
          gradient:
              const LinearGradient(
            begin:
                Alignment.topLeft,
            end:
                Alignment
                    .bottomRight,
            colors: [
              AppColors.navy,
              Color(
                0xFF17384A,
              ),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withValues(
                  alpha: 0.1,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
              child:
                  const Icon(
                Icons.auto_awesome,
                color:
                    Color(
                  0xFFB9F5DC,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Smart Seat Matching',
                    style:
                        GoogleFonts
                            .plusJakartaSans(
                      color:
                          Colors.white,
                      fontSize:
                          15,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'A quieter, better-fit spot is a few taps away.',
                    style:
                        _mutedStyle(
                      11,
                    ).copyWith(
                      color:
                          const Color(
                        0xFFCAD6E1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors
                        .mintBg,
                borderRadius:
                    BorderRadius
                        .circular(
                  20,
                ),
              ),
              child: Text(
                'AI ACTIVE',
                style:
                    GoogleFonts
                        .plusJakartaSans(
                  color:
                      AppColors
                          .mintText,
                  fontSize: 9,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _dateSelector() =>
      InkWell(
        onTap:
            _selectDate,
        borderRadius:
            BorderRadius
                .circular(
          12,
        ),
        child: Container(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white,
            border:
                Border.all(
              color:
                  const Color(
                0xFFE1E7EE,
              ),
            ),
            borderRadius:
                BorderRadius
                    .circular(
              12,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons
                    .calendar_month_outlined,
                color:
                    AppColors
                        .emerald,
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Text(
                  DateFormat(
                    'EEEE, MMM d, yyyy',
                  ).format(
                    _date,
                  ),
                  style:
                      _labelStyle(),
                ),
              ),

              const Icon(
                Icons
                    .keyboard_arrow_down,
                color:
                    AppColors
                        .textMuted,
              ),
            ],
          ),
        ),
      );

  Widget _sectionTitle(
    String value,
  ) =>
      Text(
        value,
        style:
            GoogleFonts
                .plusJakartaSans(
          color:
              AppColors
                  .textPrimary,
          fontSize: 14,
          fontWeight:
              FontWeight
                  .w800,
        ),
      );

  Widget _segmented<T>({
    required List<T> values,
    required T selected,
    required String Function(
      T,
    ) label,
    required ValueChanged<T>
        onSelected,
  }) =>
      Row(
        children:
            values.map(
          (value) {
            final isSelected =
                value ==
                    selected;

            return Expanded(
              child: Padding(
                padding:
                    EdgeInsets
                        .only(
                  right:
                      value ==
                              values
                                  .last
                          ? 0
                          : 8,
                ),
                child: InkWell(
                  onTap:
                      () =>
                          onSelected(
                            value,
                          ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                  child:
                      AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds:
                          150,
                    ),
                    alignment:
                        Alignment
                            .center,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal:
                          6,
                      vertical:
                          12,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          isSelected
                              ? AppColors
                                  .emerald
                              : Colors
                                  .white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                      border:
                          Border.all(
                        color:
                            isSelected
                                ? AppColors
                                    .emerald
                                : const Color(
                                    0xFFE1E7EE,
                                  ),
                      ),
                    ),
                    child: Text(
                      label(
                        value,
                      ),
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts
                              .plusJakartaSans(
                        fontSize:
                            11,
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            isSelected
                                ? Colors
                                    .white
                                : AppColors
                                    .textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      );

  Widget _choiceTile({
    required double width,
    required bool selected,
    required bool enabled,
    required String label,
    required VoidCallback
        onTap,
  }) =>
      InkWell(
        onTap:
            enabled
                ? onTap
                : null,
        borderRadius:
            BorderRadius
                .circular(
          10,
        ),
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                150,
          ),
          width: width,
          padding:
              const EdgeInsets
                  .symmetric(
            vertical: 12,
          ),
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color:
                !enabled
                    ? const Color(
                        0xFFEDF0F3,
                      )
                    : selected
                        ? AppColors
                            .mintBg
                        : Colors
                            .white,
            borderRadius:
                BorderRadius
                    .circular(
              10,
            ),
            border:
                Border.all(
              color:
                  !enabled
                      ? const Color(
                          0xFFD8DEE5,
                        )
                      : selected
                          ? AppColors
                              .emerald
                          : const Color(
                              0xFFE1E7EE,
                            ),
            ),
          ),
          child: Text(
            label,
            style:
                GoogleFonts
                    .plusJakartaSans(
              color:
                  !enabled
                      ? const Color(
                          0xFF98A2AD,
                        )
                      : selected
                          ? AppColors
                              .emerald
                          : AppColors
                              .textMuted,
              fontWeight:
                  FontWeight
                      .w700,
              fontSize: 11,
            ),
          ),
        ),
      );

  String _durationLabel(
    int minutes,
  ) {
    final hours =
        (minutes / 60)
            .toStringAsFixed(
              1,
            )
            .replaceAll(
              '.0',
              '',
            );

    return '$hours hr${minutes == 60 ? '' : 's'}';
  }

  TextStyle _labelStyle() =>
      GoogleFonts
          .plusJakartaSans(
        color:
            AppColors
                .textPrimary,
        fontSize: 12,
        fontWeight:
            FontWeight
                .w700,
      );

  TextStyle _mutedStyle(
    double size,
  ) =>
      GoogleFonts
          .plusJakartaSans(
        color:
            AppColors
                .textMuted,
        fontSize: size,
        fontWeight:
            FontWeight
                .w500,
      );
}
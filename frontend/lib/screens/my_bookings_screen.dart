import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/book.dart';
import '../models/models.dart';
import '../seat_booking/widgets/integrated_seat_hold_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class MyBookingsScreen extends StatefulWidget {
  final String? userId;
  final String? alternateUserId;

  const MyBookingsScreen({
    super.key,
    this.userId,
    this.alternateUserId,
  });

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _api = ApiClient();

  UserBookings? _data;
  String? _error;

  bool _loading = true;
  String _tab = 'All';

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    _load();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final primaryUserId =
          widget.userId ?? ApiClient.demoUserId;

      final alternateUserId =
          widget.alternateUserId?.trim();

      var data =
          await _api.getBookings(
        primaryUserId,
      );

      if (_hasNoBookings(data) &&
          alternateUserId != null &&
          alternateUserId.isNotEmpty &&
          alternateUserId != primaryUserId) {
        data =
            await _api.getBookings(
          alternateUserId,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _hasNoBookings(
    UserBookings data,
  ) {
    return data.reservations.isEmpty &&
        data.seatHolds.isEmpty &&
        data.loans.isEmpty;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final data = _data;

    /*
     * Backend activeCount already includes
     * active book reservations + active seat holds.
     *
     * Do not add SeatBooking count again.
     */
    final active =
        data?.activeCount ?? 0;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding:
              EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(
                      context,
                    ).top +
                12,
            16,
            12,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BiblioneLogoMark(
                    size: 30,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biblione',
                        style:
                            GoogleFonts
                                .plusJakartaSans(
                          fontWeight:
                              FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'UNIVERSITY LIBRARY',
                        style:
                            GoogleFonts
                                .plusJakartaSans(
                          fontSize: 8,
                          letterSpacing: 0.7,
                          color:
                              AppColors
                                  .textMuted,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        AppColors.navy,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Text(
                    'My Bookings',
                    style:
                        GoogleFonts
                            .plusJakartaSans(
                      fontWeight:
                          FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .mintBg,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    child: Text(
                      '$active Active',
                      style:
                          GoogleFonts
                              .plusJakartaSans(
                        color:
                            AppColors
                                .mintText,
                        fontWeight:
                            FontWeight
                                .w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.ice,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .badge_outlined,
                          size: 14,
                          color:
                              AppColors
                                  .emerald,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          data?.userId ??
                              widget.userId ??
                              ApiClient
                                  .demoUserId,
                          style:
                              GoogleFonts
                                  .plusJakartaSans(
                            fontWeight:
                                FontWeight
                                    .w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                'Track pickup-ready materials, confirmed quiet seats, and active student loans.',
                style:
                    GoogleFonts
                        .plusJakartaSans(
                  color:
                      AppColors
                          .textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding:
              const EdgeInsets
                  .fromLTRB(
            16,
            12,
            16,
            0,
          ),
          child:
              SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: [
                _tabChip(
                  'All',
                  extra:
                      '($active)',
                ),
                _tabChip(
                  'Books',
                  extra:
                      '(${data?.reservations.length ?? 0})',
                ),
                _tabChip(
                  'Desks & Seats',
                  extra:
                      '(${data?.seatHolds.length ?? 0})',
                ),
                _tabChip(
                  'History',
                  extra:
                      '(${data?.historyCount ?? 4})',
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      16,
                      12,
                      16,
                      24,
                    ),
                    children: [
                      if (_error !=
                          null)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom:
                                12,
                          ),
                          child:
                              Text(
                            _error!,
                            style:
                                const TextStyle(
                              color:
                                  Colors
                                      .redAccent,
                              fontSize:
                                  12,
                            ),
                          ),
                        ),

                      if (_showBooks)
                        ...?data
                            ?.reservations
                            .map(
                              _reservationCard,
                            ),

                      /*
                       * Seat bookings are shown only from
                       * UserBookings.seatHolds.
                       *
                       * SeatBookingService already mirrors
                       * the booking as a SeatHold.
                       *
                       * Rendering getUserSeatBookings()
                       * separately caused the duplicate card.
                       */
                      if (_showSeats)
                        ...?data
                            ?.seatHolds
                            .map(
                              _seatCard,
                            ),

                      if (_showBooks &&
                          (data?.loans
                                  .isNotEmpty ??
                              false)) ...[
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Active Loan in Hand',
                          style:
                              GoogleFonts
                                  .plusJakartaSans(
                            fontWeight:
                                FontWeight
                                    .w800,
                            fontSize:
                                16,
                          ),
                        ),
                        Align(
                          alignment:
                              Alignment
                                  .centerRight,
                          child: Text(
                            '1 of ${data?.loanLimit ?? 5} limit',
                            style:
                                GoogleFonts
                                    .plusJakartaSans(
                              fontSize:
                                  12,
                              color:
                                  AppColors
                                      .textMuted,
                            ),
                          ),
                        ),
                        ...data!.loans
                            .map(
                              _loanCard,
                            ),
                      ],

                      const SizedBox(
                        height: 16,
                      ),

                      Text(
                        'Questions about holds or reservations? Reach out to the Circulation Desk at ext. 4410.',
                        style:
                            GoogleFonts
                                .plusJakartaSans(
                          fontSize: 12,
                          color:
                              AppColors
                                  .textMuted,
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  bool get _showBooks =>
      _tab == 'All' ||
      _tab == 'Books';

  bool get _showSeats =>
      _tab == 'All' ||
      _tab == 'Desks & Seats';

  Widget _tabChip(
    String label, {
    String extra = '',
  }) {
    final selected =
        _tab == label;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        selected: selected,
        label: Text(
          '$label $extra',
        ),
        selectedColor:
            AppColors.navy,
        backgroundColor:
            Colors.white,
        labelStyle:
            GoogleFonts
                .plusJakartaSans(
          color: selected
              ? Colors.white
              : AppColors
                  .textPrimary,
          fontWeight:
              FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(
          color: selected
              ? AppColors.navy
              : const Color(
                  0xFFD5DEE8,
                ),
        ),
        showCheckmark: false,
        onSelected: (_) {
          setState(() {
            _tab = label;
          });
        },
      ),
    );
  }

  Widget _reservationCard(
    Reservation r,
  ) {
    final deadline =
        _reservationManagementDeadline(
      r,
    );

    final holdRemaining =
        deadline.difference(
      DateTime.now(),
    );

    final loan = _data?.loans
        .where(
          (candidate) =>
              candidate.bookId ==
              r.bookId,
        )
        .cast<Loan?>()
        .firstWhere(
          (candidate) =>
              candidate != null,
          orElse: () => null,
        );

    final canManage =
        DateTime.now()
                .isBefore(
          deadline,
        ) &&
            (r.status ==
                    'READY_FOR_PICKUP' ||
                r.status ==
                    'CONFIRMED');

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                AppColors
                    .cardShadow,
            blurRadius: 14,
            offset:
                Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              StatusPill(
                label:
                    'Ready for Pickup',
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _bookingTimeInfo(
                  icon: Icons
                      .hourglass_bottom_rounded,
                  label:
                      'Book hold time',
                  value:
                      holdRemaining
                              .isNegative
                          ? 'Hold expired'
                          : '${_formatDuration(holdRemaining)} remaining',
                  color:
                      holdRemaining
                              .isNegative
                          ? const Color(
                              0xFFB42318,
                            )
                          : const Color(
                              0xFFC2410C,
                            ),
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                    _bookingTimeInfo(
                  icon: Icons
                      .calendar_month_outlined,
                  label:
                      'Loan period',
                  value:
                      '${r.loanPeriodDays} days',
                  color:
                      AppColors
                          .emerald,
                ),
              ),
            ],
          ),

          if (loan != null) ...[
            const SizedBox(
              height: 8,
            ),
            _bookingTimeInfo(
              icon: Icons
                  .assignment_return_outlined,
              label:
                  'Return countdown',
              value:
                  _loanCountdownLabel(
                loan,
              ),
              color: loan.dueDate
                      .isBefore(
                DateTime.now(),
              )
                  ? const Color(
                      0xFFB42318,
                    )
                  : AppColors
                      .mintText,
            ),
          ],

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              BookCover(
                url:
                    r.coverImageUrl,
                width: 62,
                height: 84,
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
                    Row(
                      children: [
                        Text(
                          'Print Copy',
                          style:
                              GoogleFonts
                                  .plusJakartaSans(
                            fontSize:
                                11,
                            color:
                                AppColors
                                    .textMuted,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                8,
                            vertical:
                                3,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFE8F1FF,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                          ),
                          child:
                              Text(
                            'Priority Hold',
                            style:
                                GoogleFonts
                                    .plusJakartaSans(
                              fontSize:
                                  10,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  const Color(
                                0xFF3B6EA8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      r.title,
                      style:
                          AppTheme
                              .serifTitle
                              .copyWith(
                        fontSize: 18,
                      ),
                    ),

                    Text(
                      r.author,
                      style:
                          GoogleFonts
                              .plusJakartaSans(
                        fontSize: 12,
                        color:
                            AppColors
                                .textMuted,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors
                                .searchFill,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Text(
                        'Shelf ${r.shelfCode}${r.shelfDetail.isEmpty ? '' : ' | ${r.shelfDetail}'}',
                        style:
                            GoogleFonts
                                .plusJakartaSans(
                          fontSize:
                              11,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets
                    .all(
              12,
            ),
            decoration:
                BoxDecoration(
              color:
                  AppColors
                      .wayfinding,
              borderRadius:
                  BorderRadius
                      .circular(
                14,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .near_me_outlined,
                  color:
                      AppColors
                          .emerald,
                  size: 18,
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        r.pickupDesk,
                        style:
                            GoogleFonts
                                .plusJakartaSans(
                          fontWeight:
                              FontWeight
                                  .w800,
                          fontSize:
                              13,
                        ),
                      ),
                      Text(
                        r.pickupDeskDetail
                            .replaceAll(
                          ',',
                          ' •',
                        ),
                        style:
                            GoogleFonts
                                .plusJakartaSans(
                          fontSize:
                              12,
                          color:
                              AppColors
                                  .textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons
                      .directions_walk,
                  color:
                      AppColors
                          .emerald,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    PrimaryButton(
                  label:
                      'Show Hold Barcode',
                  icon:
                      Icons.qr_code_2,
                  onPressed:
                      () =>
                          _showBarcode(
                            r,
                          ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            children: [
              Expanded(
                child: SoftButton(
                  label:
                      'Change Book',
                  icon: Icons
                      .menu_book_outlined,
                  onPressed:
                      canManage
                          ? () =>
                              _changeReservationBook(
                                r,
                              )
                          : null,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: SoftButton(
                  label: 'Cancel',
                  icon:
                      Icons.close,
                  foreground:
                      const Color(
                    0xFFB42318,
                  ),
                  onPressed:
                      canManage
                          ? () =>
                              _deleteReservation(
                                r,
                              )
                          : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookingTimeInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        10,
      ),
      decoration:
          BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: color,
          ),
          const SizedBox(
            width: 6,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  label,
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    fontSize: 10,
                    color:
                        AppColors
                            .textMuted,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
                Text(
                  value,
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    fontSize: 11,
                    color: color,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(
    Duration duration,
  ) {
    final safeDuration =
        duration.isNegative
            ? Duration.zero
            : duration;

    final days =
        safeDuration.inDays;

    final hours =
        safeDuration.inHours
            .remainder(24);

    final minutes =
        safeDuration.inMinutes
            .remainder(60);

    return '${days}d ${hours}h ${minutes}m';
  }

  String _loanCountdownLabel(
    Loan loan,
  ) {
    final remaining =
        loan.dueDate.difference(
      DateTime.now(),
    );

    final countdown =
        _formatDuration(
      remaining,
    );

    return remaining.isNegative
        ? 'Overdue by $countdown'
        : '$countdown remaining';
  }

  DateTime
      _reservationManagementDeadline(
    Reservation reservation,
  ) {
    final policyDeadline =
        reservation.createdAt.add(
      const Duration(
        hours: 24,
      ),
    );

    return reservation.expiresAt
            .isBefore(
      policyDeadline,
    )
        ? reservation.expiresAt
        : policyDeadline;
  }

  Future<void>
      _changeReservationBook(
    Reservation reservation,
  ) async {
    try {
      final booksFuture =
          _api.searchBooks();

      final selectedBook =
          await showDialog<Book>(
        context: context,
        builder:
            (dialogContext) {
          var query = '';

          return StatefulBuilder(
            builder:
                (
              context,
              setDialogState,
            ) =>
                    AlertDialog(
              title:
                  const Text(
                'Choose another book',
              ),
              content:
                  SizedBox(
                width: 420,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(
                        prefixIcon:
                            Icon(
                          Icons
                              .search,
                        ),
                        hintText:
                            'Search available books',
                      ),
                      onChanged:
                          (value) {
                        setDialogState(
                          () {
                            query =
                                value
                                    .trim();
                          },
                        );
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Expanded(
                      child:
                          FutureBuilder<
                              List<
                                  Book>>(
                        future:
                            booksFuture,
                        builder:
                            (
                          context,
                          snapshot,
                        ) {
                          if (snapshot
                                  .connectionState ==
                              ConnectionState
                                  .waiting) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(),
                            );
                          }

                          if (snapshot
                              .hasError) {
                            return Center(
                              child:
                                  Text(
                                snapshot
                                    .error
                                    .toString(),
                              ),
                            );
                          }

                          final availableBooks =
                              (snapshot.data ??
                                      [])
                                  .where(
                            (book) =>
                                book.id !=
                                    reservation
                                        .bookId &&
                                book.isAvailable &&
                                (query.isEmpty ||
                                    book.title
                                        .toLowerCase()
                                        .contains(
                                          query.toLowerCase(),
                                        ) ||
                                    book.author
                                        .toLowerCase()
                                        .contains(
                                          query.toLowerCase(),
                                        )),
                          ).toList();

                          if (availableBooks
                              .isEmpty) {
                            return const Center(
                              child:
                                  Text(
                                'No other available books found.',
                              ),
                            );
                          }

                          return ListView
                              .builder(
                            itemCount:
                                availableBooks
                                    .length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final book =
                                  availableBooks[
                                      index];

                              return ListTile(
                                contentPadding:
                                    EdgeInsets
                                        .zero,
                                leading:
                                    BookCover(
                                  url: book
                                      .coverImageUrl,
                                  width:
                                      38,
                                  height:
                                      52,
                                ),
                                title:
                                    Text(
                                  book.title,
                                  maxLines:
                                      2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                                subtitle:
                                    Text(
                                  '${book.author} · ${book.copiesLabel}',
                                  maxLines:
                                      1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                                onTap:
                                    () =>
                                        Navigator
                                            .pop(
                                  dialogContext,
                                  book,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      () =>
                          Navigator
                              .pop(
                    dialogContext,
                  ),
                  child:
                      const Text(
                    'Keep current book',
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (selectedBook ==
              null ||
          !mounted) {
        return;
      }

      final confirmed =
          await showDialog<bool>(
        context: context,
        builder:
            (dialogContext) =>
                AlertDialog(
          title:
              const Text(
            'Change reserved book?',
          ),
          content: Text(
            'Replace "${reservation.title}" with "${selectedBook.title}"?',
          ),
          actions: [
            TextButton(
              onPressed:
                  () =>
                      Navigator
                          .pop(
                dialogContext,
                false,
              ),
              child:
                  const Text(
                'Keep current',
              ),
            ),
            FilledButton(
              onPressed:
                  () =>
                      Navigator
                          .pop(
                dialogContext,
                true,
              ),
              child:
                  const Text(
                'Change book',
              ),
            ),
          ],
        ),
      );

      if (confirmed !=
              true ||
          !mounted) {
        return;
      }

      await _api
          .updateReservation(
        reservation.id,
        bookId:
            selectedBook.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Book changed to "${selectedBook.title}".',
          ),
        ),
      );

      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  Future<void>
      _deleteReservation(
    Reservation reservation,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) =>
              AlertDialog(
        title:
            const Text(
          'Cancel book hold?',
        ),
        content: Text(
          'Cancel the hold for "${reservation.title}"?',
        ),
        actions: [
          TextButton(
            onPressed:
                () =>
                    Navigator.pop(
              dialogContext,
              false,
            ),
            child:
                const Text(
              'Keep hold',
            ),
          ),
          FilledButton(
            onPressed:
                () =>
                    Navigator.pop(
              dialogContext,
              true,
            ),
            child:
                const Text(
              'Cancel hold',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _api
          .deleteReservation(
        reservation.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Book hold cancelled.',
          ),
        ),
      );

      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  /*
   * This is the only seat card rendered in
   * My Bookings.
   *
   * IntegratedSeatHoldCard already provides:
   * - Check In via Scanner
   * - Manage
   * - checked-in state
   */
  Widget _seatCard(
    SeatHold seatHold,
  ) {
    return IntegratedSeatHoldCard(
      seatHold: seatHold,
      onChanged: _load,
    );
  }

  Widget _loanCard(
    Loan loan,
  ) {
    final remaining =
        loan.dueDate.difference(
      DateTime.now(),
    );

    final isOverdue =
        remaining.isNegative;

    final absoluteRemaining =
        remaining.abs();

    final days =
        absoluteRemaining.inDays;

    final hours =
        absoluteRemaining.inHours
            .remainder(
      24,
    );

    final minutes =
        absoluteRemaining.inMinutes
            .remainder(
      60,
    );

    final countdown =
        '$days d $hours h $minutes m';

    return Container(
      margin:
          const EdgeInsets.only(
        top: 8,
      ),
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Row(
        children: [
          BookCover(
            url:
                loan.coverImageUrl,
            width: 48,
            height: 64,
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
                  loan.title,
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                Text(
                  isOverdue
                      ? 'Overdue by $countdown (${DateFormat('MMM d').format(loan.dueDate.toLocal())})'
                      : 'Returns in $countdown (${DateFormat('MMM d').format(loan.dueDate.toLocal())})',
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    fontSize: 12,
                    color:
                        isOverdue
                            ? Colors
                                .redAccent
                            : AppColors
                                .textMuted,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                ClipRRect(
                  borderRadius:
                      BorderRadius
                          .circular(
                    6,
                  ),
                  child:
                      LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 6,
                    color:
                        const Color(
                      0xFF22C55E,
                    ),
                    backgroundColor:
                        AppColors.ice,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          TextButton(
            onPressed:
                () async {
              await _api
                  .renewLoan(
                loan.id,
              );

              await _load();
            },
            style:
                TextButton
                    .styleFrom(
              backgroundColor:
                  AppColors
                      .cyanAlert,
              foregroundColor:
                  AppColors
                      .mintText,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  20,
                ),
              ),
            ),
            child:
                const Text(
              'Renew',
            ),
          ),
        ],
      ),
    );
  }

  void _showBarcode(
    Reservation reservation,
  ) {
    showModalBottomSheet(
      context: context,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(
            24,
          ),
        ),
      ),
      builder: (_) =>
          Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            BarcodeWidget(
              barcode:
                  Barcode.code128(),
              data: reservation
                  .holdIdCode,
              height: 90,
              drawText: false,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'HOLD ID: ${reservation.holdIdCode}',
              style:
                  GoogleFonts
                      .plusJakartaSans(
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
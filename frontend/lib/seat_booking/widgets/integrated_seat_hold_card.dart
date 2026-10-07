import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../api/seat_booking_api.dart';
import '../models/seat_booking_models.dart';
import '../screens/active_booking_screen.dart';
import '../screens/qr_scanner_screen.dart';

class IntegratedSeatHoldCard extends StatelessWidget {
  final SeatHold seatHold;

  final Future<void> Function()?
      onChanged;

  const IntegratedSeatHoldCard({
    super.key,
    required this.seatHold,
    this.onChanged,
  });

  bool get _checkedIn =>
      seatHold.status
          .toUpperCase() ==
      'CHECKED_IN';

  SeatMapSeat get _seat =>
      SeatMapSeat(
        id: seatHold.id,
        seatCode:
            seatHold.seatCode,
        hallCode: '',
        floor: '',
        zone: seatHold.zone,
        hasPowerOutlet:
            seatHold.amenities
                .contains(
                  'power',
                ),
        acousticsDb: 0,
        features:
            seatHold.amenities,
        available: false,
      );

  Future<bool>
  _hasLinkedBooking(
    BuildContext context,
  ) async {
    try {
      await SeatBookingApi()
          .getBooking(
        seatHold.id,
      );

      return true;
    } catch (_) {
      if (!context.mounted) {
        return false;
      }

      ScaffoldMessenger
          .of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'QR check-in could not find a linked seat booking. Create a new booking through the seat booking flow.',
          ),
        ),
      );

      return false;
    }
  }

  Future<void> _openScanner(
    BuildContext context,
  ) async {
    final exists =
        await _hasLinkedBooking(
      context,
    );

    if (
      !exists ||
          !context.mounted
    ) {
      return;
    }

    await Navigator
        .of(context)
        .push<void>(
      MaterialPageRoute(
        builder: (_) =>
            QRScannerScreen(
          bookingId:
              seatHold.id,
          seatNumber:
              seatHold.seatCode,
          seat: _seat,
        ),
      ),
    );

    if (onChanged != null) {
      await onChanged!();
    }
  }

  Future<void> _openManage(
    BuildContext context,
  ) async {
    final exists =
        await _hasLinkedBooking(
      context,
    );

    if (
      !exists ||
          !context.mounted
    ) {
      return;
    }

    await Navigator
        .of(context)
        .push<void>(
      MaterialPageRoute(
        builder: (_) =>
            ActiveBookingScreen(
          bookingId:
              seatHold.id,
          seat: _seat,
        ),
      ),
    );

    if (onChanged != null) {
      await onChanged!();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final statusLabel =
        _checkedIn
            ? 'Checked In'
            : 'Confirmed Hold';

    final statusColor =
        _checkedIn
            ? const Color(
                0xFF0A7B61,
              )
            : AppColors.emerald;

    final now =
        DateTime.now();

    final remaining =
        seatHold.checkInBy
            .difference(now);

    final checkInText =
        _checkedIn
            ? 'Session active'
            : remaining.isNegative
                ? 'Check-in window open'
                : 'Check in by ${DateFormat('h:mm a').format(seatHold.checkInBy.toLocal())}';

    return Container(
      margin:
          const EdgeInsets
              .only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets
              .all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius
                .circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE2E9E8,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      9,
                  vertical:
                      5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      statusColor
                          .withValues(
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
                  statusLabel,
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    color:
                        statusColor,
                    fontSize:
                        10,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                _checkedIn
                    ? Icons
                        .check_circle_outline
                    : Icons
                        .timer_outlined,
                size: 16,
                color:
                    statusColor,
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  checkInText,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    fontSize:
                        10,
                    fontWeight:
                        FontWeight
                            .w700,
                    color:
                        statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .cyanAlert,
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child:
                    const Icon(
                  Icons.event_seat,
                  color:
                      AppColors
                          .emerald,
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
                      seatHold
                              .seatName
                              .isEmpty
                          ? 'Seat - ${seatHold.seatCode}'
                          : seatHold
                              .seatName,
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
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      seatHold.zone,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts
                              .plusJakartaSans(
                        fontSize:
                            11,
                        color:
                            AppColors
                                .textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'SEAT CODE',
                    style:
                        GoogleFonts
                            .plusJakartaSans(
                      fontSize: 9,
                      color:
                          AppColors
                              .textMuted,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  Text(
                    '#${seatHold.seatCode}',
                    style:
                        GoogleFonts
                            .plusJakartaSans(
                      fontWeight:
                          FontWeight
                              .w800,
                      fontSize:
                          17,
                      color:
                          AppColors
                              .emerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reserved Slot\n${seatHold.slotLabel}',
                  style:
                      GoogleFonts
                          .plusJakartaSans(
                    fontSize:
                        11,
                    height:
                        1.35,
                  ),
                ),
              ),
              ...seatHold
                  .amenities
                  .take(3)
                  .map(
                    (
                      amenity,
                    ) =>
                        Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        left: 8,
                      ),
                      child: Icon(
                        amenity ==
                                'power'
                            ? Icons
                                .power_outlined
                            : amenity ==
                                    'wifi'
                                ? Icons
                                    .wifi
                                : Icons
                                    .volume_off_outlined,
                        size: 18,
                        color:
                            AppColors
                                .checkedText,
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              Expanded(
                child:
                    ElevatedButton
                        .icon(
                  onPressed:
                      _checkedIn
                          ? () =>
                              _openManage(
                                context,
                              )
                          : () =>
                              _openScanner(
                                context,
                              ),
                  icon: Icon(
                    _checkedIn
                        ? Icons
                            .event_available
                        : Icons
                            .qr_code_scanner,
                    size: 18,
                  ),
                  label: Text(
                    _checkedIn
                        ? 'View Session'
                        : 'Check In via Scanner',
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        AppColors
                            .navy,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical:
                          14,
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
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              OutlinedButton
                  .icon(
                onPressed: () =>
                    _openManage(
                  context,
                ),
                icon:
                    const Icon(
                  Icons
                      .settings_outlined,
                  size: 17,
                ),
                label:
                    const Text(
                  'Manage',
                ),
                style:
                    OutlinedButton
                        .styleFrom(
                  foregroundColor:
                      AppColors
                          .emerald,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        12,
                    vertical:
                        14,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
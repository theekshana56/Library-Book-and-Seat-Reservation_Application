import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../models/seat_booking.dart';
import 'qr_scanner_screen.dart';

class ActiveBookingScreen extends StatefulWidget {
  final String seatNumber;

  const ActiveBookingScreen({
    super.key,
    required this.seatNumber,
  });

  @override
  State<ActiveBookingScreen> createState() => _ActiveBookingScreenState();
}

class _ActiveBookingScreenState extends State<ActiveBookingScreen> {
  final ApiClient _apiClient = ApiClient();

  SeatBooking? _booking;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    try {
      final bookings = await _apiClient.getUserSeatBookings();

      SeatBooking? matchingBooking;

      for (final booking in bookings.reversed) {
        if (booking.seatCode.toUpperCase() ==
            widget.seatNumber.toUpperCase() &&
            booking.status.toUpperCase() != 'CANCELLED') {
          matchingBooking = booking;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _booking = matchingBooking;
        _isLoading = false;

        if (matchingBooking == null) {
          _errorMessage = 'No active booking found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final booking = _booking;

    if (booking == null) return;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: Text(
            'Are you sure you want to cancel your reservation for seat ${booking.seatCode}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    try {
      await _apiClient.cancelSeatBooking(booking.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully.'),
        ),
      );

      Navigator.popUntil(
        context,
            (route) => route.isFirst,
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);

      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _formatTime(String value) {
    try {
      final parts = value.split(':');

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF073342),
        foregroundColor: Colors.white,
        title: const Text(
          'My Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF008C72),
        ),
      );
    }

    if (_errorMessage != null || _booking == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'No active booking found.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _loadBooking();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final booking = _booking!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Booking',
                style: TextStyle(
                  color: Color(0xFF0A3443),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status,
                  style: const TextStyle(
                    color: Color(0xFF008C72),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE1E8E7),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF8F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF008C72),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking.seatCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level 2 Quiet Zone',
                              style: TextStyle(
                                color: Color(0xFF173B46),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Window Side • Power Outlet',
                              style: TextStyle(
                                color: Color(0xFF78868A),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(booking.startTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(booking.endTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(
                  value: 0.15,
                  minHeight: 7,
                  backgroundColor: Color(0xFFE3EBEA),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF008C72),
                  ),
                ),
                const SizedBox(height: 18),
                _row(
                  Icons.calendar_today_outlined,
                  'Date',
                  _formatDate(booking.bookingDate),
                ),
                const Divider(height: 26),
                _row(
                  Icons.confirmation_number_outlined,
                  'Booking ID',
                  booking.id,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFF008C72),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Scan the QR code attached to your reserved desk to complete check-in.',
                    style: TextStyle(
                      color: Color(0xFF31545C),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008C72),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QRScannerScreen(
                      seatNumber: booking.seatCode,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.qr_code_scanner,
              ),
              label: const Text(
                'Check in via Desk QR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                _cancelBooking(context);
              },
              child: const Text(
                'Cancel Booking',
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          color: const Color(0xFF008C72),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
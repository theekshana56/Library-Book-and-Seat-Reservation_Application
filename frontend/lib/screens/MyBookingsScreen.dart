import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _api = ApiClient();
  UserBookings? _data;
  String? _error;
  bool _loading = true;
  String _tab = 'All';

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
      final data = await _api.getBookings();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final active = data?.activeCount ?? 0;
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + 12,
            16,
            12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BiblioneLogoMark(size: 30),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biblione',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'UNIVERSITY LIBRARY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          letterSpacing: 0.7,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.navy,
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'My Bookings',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$active Active',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.mintText,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ice,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ApiClient.demoUserId,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Track pickup-ready materials, confirmed quiet seats, and active student loans.',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tabChip('All', extra: '($active)'),
                _tabChip('Books', extra: '(${data?.reservations.length ?? 0})'),
                _tabChip(
                  'Desks & Seats',
                  extra: '(${data?.seatHolds.length ?? 0})',
                ),
                _tabChip('History', extra: '(${data?.historyCount ?? 4})'),
              ],
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (_showBooks)
                        ...?data?.reservations.map(_reservationCard),
                      if (_showSeats) ...?data?.seatHolds.map(_seatCard),
                      if (_showBooks && (data?.loans.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Active Loan in Hand',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '1 of ${data?.loanLimit ?? 5} limit',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        ...data!.loans.map(_loanCard),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Questions about holds or reservations? Reach out to the Circulation Desk at ext. 4410.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  bool get _showBooks => _tab == 'All' || _tab == 'Books';
  bool get _showSeats => _tab == 'All' || _tab == 'Desks & Seats';

  Widget _tabChip(String label, {String extra = ''}) {
    final selected = _tab == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text('$label $extra'),
        selectedColor: AppColors.navy,
        backgroundColor: Colors.white,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(
          color: selected ? AppColors.navy : const Color(0xFFD5DEE8),
        ),
        showCheckmark: false,
        onSelected: (_) => setState(() => _tab = label),
      ),
    );
  }

  Widget _reservationCard(Reservation r) {
    final deadline = _reservationManagementDeadline(r);
    final canManage =
        DateTime.now().isBefore(deadline) &&
        (r.status == 'READY_FOR_PICKUP' || r.status == 'CONFIRMED');
    final remaining = deadline.difference(DateTime.now());
    final windowLabel = canManage
        ? 'Editable for ${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m'
        : 'Change window closed';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const StatusPill(label: 'Ready for Pickup'),
              const Spacer(),
              const Icon(
                Icons.hourglass_bottom,
                size: 16,
                color: Color(0xFFC2410C),
              ),
              const SizedBox(width: 4),
              Text(
                windowLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC2410C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              BookCover(url: r.coverImageUrl, width: 62, height: 84),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Print Copy',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Priority Hold',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3B6EA8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.title,
                      style: AppTheme.serifTitle.copyWith(fontSize: 18),
                    ),
                    Text(
                      r.author,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.searchFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CS-${r.shelfCode.contains('-') ? r.shelfCode.split('-').last : r.shelfCode} · L2 Stacks 8',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.wayfinding,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.near_me_outlined,
                  color: AppColors.emerald,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.pickupDesk,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        r.pickupDeskDetail.replaceAll(',', ' •'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.directions_walk, color: AppColors.emerald),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Show Hold Barcode',
                  icon: Icons.qr_code_2,
                  onPressed: () => _showBarcode(r),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SoftButton(
                  label: 'Edit Pickup',
                  icon: Icons.edit_outlined,
                  onPressed: canManage ? () => _editReservation(r) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SoftButton(
                  label: 'Cancel',
                  icon: Icons.close,
                  foreground: const Color(0xFFB42318),
                  onPressed: canManage ? () => _deleteReservation(r) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime _reservationManagementDeadline(Reservation reservation) {
    final policyDeadline = reservation.createdAt.add(const Duration(hours: 24));
    return reservation.expiresAt.isBefore(policyDeadline)
        ? reservation.expiresAt
        : policyDeadline;
  }

  Future<void> _editReservation(Reservation reservation) async {
    final deskController = TextEditingController(text: reservation.pickupDesk);
    final detailController = TextEditingController(
      text: reservation.pickupDeskDetail,
    );
    final formKey = GlobalKey<FormState>();
    try {
      final pickupDetails = await showDialog<(String, String)>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Edit pickup details'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: deskController,
                  decoration: const InputDecoration(labelText: 'Pickup desk'),
                  textCapitalization: TextCapitalization.words,
                  validator: _requiredPickupValue,
                ),
                TextFormField(
                  controller: detailController,
                  decoration: const InputDecoration(
                    labelText: 'Pickup location details',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: _requiredPickupValue,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep current'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, (
                    deskController.text.trim(),
                    detailController.text.trim(),
                  ));
                }
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      );
      if (pickupDetails == null || !mounted) return;

      await _api.updateReservation(
        reservation.id,
        pickupDesk: pickupDetails.$1,
        pickupDeskDetail: pickupDetails.$2,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pickup details updated.')));
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      deskController.dispose();
      detailController.dispose();
    }
  }

  String? _requiredPickupValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  Future<void> _deleteReservation(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel book hold?'),
        content: Text('Cancel the hold for "${reservation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep hold'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel hold'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deleteReservation(reservation.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Book hold cancelled.')));
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _seatCard(SeatHold s) {
    final remaining = s.checkInBy.difference(DateTime.now());
    final mins = remaining.isNegative ? 0 : remaining.inMinutes;
    final secs = remaining.isNegative ? 0 : remaining.inSeconds.remainder(60);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const StatusPill(label: 'Confirmed Hold'),
              const Spacer(),
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: AppColors.checkedText,
              ),
              const SizedBox(width: 4),
              Text(
                '$mins:${secs.toString().padLeft(2, '0')} mins to check in',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.checkedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cyanAlert,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event_seat, color: AppColors.emerald),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.seatName}  Silent Pod',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      s.zone,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'SEAT CODE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '#${s.seatCode}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Reserved Slot\n${s.slotLabel}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.3),
              ),
              const Spacer(),
              ...s.amenities.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    a == 'power'
                        ? Icons.power_outlined
                        : a == 'wifi'
                        ? Icons.wifi
                        : Icons.volume_off_outlined,
                    size: 18,
                    color: AppColors.checkedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Check In via Scanner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SoftButton(
                label: 'Modify',
                icon: Icons.edit_calendar_outlined,
                expanded: false,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanCard(Loan loan) {
    final days = loan.dueDate.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          BookCover(url: loan.coverImageUrl, width: 48, height: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Due in ${days.abs()} days (${DateFormat('MMM d').format(loan.dueDate.toLocal())})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 6,
                    color: const Color(0xFF22C55E),
                    backgroundColor: AppColors.ice,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              await _api.renewLoan(loan.id);
              _load();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.cyanAlert,
              foregroundColor: AppColors.mintText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('↻  Renew'),
          ),
        ],
      ),
    );
  }

  void _showBarcode(Reservation r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BarcodeWidget(
              barcode: Barcode.code128(),
              data: r.holdIdCode,
              height: 90,
              drawText: false,
            ),
            const SizedBox(height: 12),
            Text(
              'HOLD ID: ${r.holdIdCode}',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

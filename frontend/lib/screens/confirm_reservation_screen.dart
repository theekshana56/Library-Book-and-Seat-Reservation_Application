import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_client.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import 'reservation_receipt_screen.dart';

class ConfirmReservationScreen extends StatefulWidget {
  final Book book;
  const ConfirmReservationScreen({super.key, required this.book});

  @override
  State<ConfirmReservationScreen> createState() => _ConfirmReservationScreenState();
}

class _ConfirmReservationScreenState extends State<ConfirmReservationScreen> {
  final _api = ApiClient();
  bool _notify = true;
  bool _submitting = false;

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      final reservation = await _api.reserveBook(widget.book.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ReservationReceiptScreen(reservation: reservation)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          LightSubHeader(
            title: 'Confirm Reservation',
            subtitle: 'Step 2 of 2  •  Final Review',
            trailing: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD5DEE8)),
                color: Colors.white,
              ),
              child: Text('2/2',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cyanAlert,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.mintText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pickup Hold Policy',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(
                              'Physical copies are kept at the circulation desk for 24 hours once confirmed ready.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      BookCover(url: book.coverImageUrl, width: 54, height: 74),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StatusPill(label: 'Ready for Staging'),
                            const SizedBox(height: 6),
                            Text(book.title, style: AppTheme.serifTitle.copyWith(fontSize: 18)),
                            Text(book.author,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
                            Text("O'Reilly Media • 1st Ed. ${book.year == 0 ? 2017 : book.year}",
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.emerald),
                    const SizedBox(width: 4),
                    Text('Shelf ${book.shelfCode} • ${book.shelfDetail}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Hold Specifications',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
                    const Spacer(),
                    Text('AUTOMATED DISPATCH',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mintText,
                          letterSpacing: 0.6,
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      _row(Icons.location_on_outlined, 'DESIGNATED PICKUP DESK',
                          book.pickupDesk, book.pickupDeskDetail),
                      const Divider(height: 22),
                      Row(
                        children: [
                          Expanded(child: _mini(Icons.schedule, 'Hold Window', '24 Hours', 'Post desk arrival')),
                          const SizedBox(width: 10),
                          Expanded(child: _mini(Icons.event_available_outlined, 'Loan Duration', '${book.loanPeriodDays} Days', 'Standard student tier')),
                        ],
                      ),
                      const Divider(height: 22),
                      _row(Icons.badge_outlined, 'Borrower ID', 'RW - 20248839', 'CS Dept', trailingChip: true),
                      const Divider(height: 22),
                      Row(
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: AppColors.emerald),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ready Notification',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                                Text('Email & Push Alert',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _notify,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.emerald,
                            onChanged: (v) => setState(() => _notify = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Uncollected books after 24h are returned to open circulation and hold priority is transferred to the next waitlisted student.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: _submitting ? 'Placing hold...' : 'Confirm & Place Hold',
                  trailing: Icons.arrow_forward_rounded,
                  onPressed: _submitting ? null : _confirm,
                ),
                const SizedBox(height: 10),
                SoftButton(
                  label: 'Cancel & Return to Search',
                  icon: Icons.close,
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String title, String subtitle, {bool trailingChip = false}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.emerald),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  )),
              Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        if (trailingChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.ice, borderRadius: BorderRadius.circular(20)),
            child: Text('CS Dept', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 11)),
          ),
      ],
    );
  }

  Widget _mini(IconData icon, String label, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.emerald),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

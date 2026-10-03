import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class ReservationReceiptScreen extends StatelessWidget {
  final Reservation reservation;
  const ReservationReceiptScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final titleTail = reservation.title.contains(' ')
        ? '-${reservation.title.split(' ').skip(1).join(' ')}'
        : reservation.title;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          LightSubHeader(
            title: 'Reservation Receipt',
            subtitle: 'CIRCULATION RECEIPT',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.successBanner,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.mintText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 13, height: 1.35),
                            children: [
                              TextSpan(
                                  text: 'Success! Shelf hold placed.\n',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.mintText)),
                              TextSpan(text: 'Assigned to your student card (ID ${reservation.studentCardId}).'),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Text('Ready',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.mintText,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 18, offset: Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 22),
                      Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(color: AppColors.mintBg, shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: AppColors.mintText, size: 42),
                      ),
                      const SizedBox(height: 12),
                      Text('ORDER CONFIRMED',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: AppColors.mintText,
                          )),
                      Text('Book Reserved!', style: AppTheme.serifTitle.copyWith(fontSize: 26)),
                      Text('Item is currently on hold for pickup.',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            BookCover(url: reservation.coverImageUrl, width: 58, height: 78),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(8)),
                                      child: Text('Priority Hold',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF3B6EA8))),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('Print Copy',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(reservation.title, style: AppTheme.serifTitle.copyWith(fontSize: 16)),
                                  Text(reservation.author,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _TicketDash(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                        child: Column(
                          children: [
                            _kv('Title', titleTail),
                            _kv('Author', reservation.author),
                            _kv('Shelf Code', reservation.shelfCode, chip: true),
                            _kv('Hold Window', '●  24 Hours Remaining', mint: true),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppColors.emerald),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pickup Location',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
                                    Text(reservation.pickupDesk,
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                                    Text(reservation.pickupDeskDetail,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.directions_walk_rounded, color: AppColors.emerald),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.barcodeBox,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: reservation.holdIdCode,
                                height: 64,
                                drawText: false,
                                color: AppColors.navy,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.qr_code_2, size: 16, color: AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text('HOLD ID: ${reservation.holdIdCode}',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12)),
                                ],
                              ),
                              Text('Scan kiosk screen or show to circulation assistant',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Done',
                  icon: Icons.check,
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.emerald),
                  label: Text('View in My Bookings',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.emerald, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Need to extend your hold? Contact Desk at ext. 4410.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _kv(String k, String v, {bool chip = false, bool mint = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(_icon(k), size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(k, style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13)),
          const Spacer(),
          if (chip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.ice, borderRadius: BorderRadius.circular(8)),
              child: Text(v, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            )
          else
            Text(v,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: mint ? AppColors.mintText : AppColors.textPrimary,
                )),
        ],
      ),
    );
  }

  static IconData _icon(String k) {
    switch (k) {
      case 'Title':
        return Icons.menu_book_outlined;
      case 'Author':
        return Icons.person_outline;
      case 'Shelf Code':
        return Icons.layers_outlined;
      default:
        return Icons.schedule;
    }
  }
}

class _TicketDash extends StatelessWidget {
  const _TicketDash();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: List.generate(
              28,
              (i) => Expanded(
                child: Container(
                  height: 1.4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: i.isEven ? const Color(0xFFD5DEE8) : Colors.transparent,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.pageBg,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 16,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.pageBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

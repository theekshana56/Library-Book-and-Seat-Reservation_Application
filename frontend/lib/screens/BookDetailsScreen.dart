import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import 'ConfirmReservationScreen.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;
  final Book? book;
  const BookDetailsScreen({super.key, required this.bookId, this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final _api = ApiClient();
  Book? _book;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _load();
  }

  Future<void> _load() async {
    try {
      final book = await _api.getBook(widget.bookId);
      setState(() {
        _book = book;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = _book;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          const LightSubHeader(title: 'Book Details'),
          if (_loading && book == null)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (book == null)
            const Expanded(child: Center(child: Text('Book not found')))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _hero(book),
                  const SizedBox(height: 14),
                  _stock(book),
                  const SizedBox(height: 12),
                  _infoGrid(book),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: book.isAvailable ? 'Reserve Book' : 'Not Available',
                    trailing: book.isAvailable
                        ? Icons.arrow_forward_rounded
                        : Icons.lock_outline,
                    onPressed: book.isAvailable
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ConfirmReservationScreen(book: book),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _wayfinding(book),
                  const SizedBox(height: 22),
                  Center(
                    child: Text(
                      'STATE VARIATIONS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _altState(book),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _hero(Book book) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            url: book.coverImageUrl,
            badge: book.publisher,
            width: 92,
            height: 124,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_stories_outlined,
                      size: 16,
                      color: AppColors.emerald,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      book.category.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  style: AppTheme.serifTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  '${book.author}  •  ${book.edition}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.emerald,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        book.shelfLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stock(Book book) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.mintBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              book.isAvailable ? '●  AVAILABLE NOW' : '●  IN CIRCULATION',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.mintText,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          book.isAvailable
              ? '${book.availableCopies} Copies in Stacks'
              : '0 Copies in Stacks',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _infoGrid(Book book) {
    Widget cell(String k, String v) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4EAF1)),
        ),
        child: Column(
          children: [
            Text(
              k,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              v,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
    return Row(
      children: [
        cell('CALL NO.', book.callNumber),
        cell('LOAN PERIOD', '${book.loanPeriodDays} Days'),
        cell('FORMAT', book.format),
      ],
    );
  }

  Widget _wayfinding(Book book) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.wayfinding,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map_outlined, color: AppColors.emerald),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wayfinding & Stacks',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  book.wayfinding.isEmpty
                      ? 'Level 2 • East Wing Aisle 8'
                      : book.wayfinding,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'View Map',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.emerald,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _altState(Book book) {
    final due = book.nextReturnDate ?? DateTime(2025, 5, 18);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Text(
                'Alternative State',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ice,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'IF CHECKED OUT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.checkedText,
                  ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.checkedText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'All Copies Currently in Circulation',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Next estimated return: ${DateFormat('MMMM d, y').format(due)}\n(Borrower:\n${book.currentBorrower ?? 'Department of CS'})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.groups_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${book.waitlistCount == 0 ? 4 : book.waitlistCount} patrons waiting on hold list',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Est. wait: ~2 weeks',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.checkedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SoftButton(
            label: 'Not Available (Due ${DateFormat('MMM d').format(due)})',
            icon: Icons.lock_outline,
            onPressed: null,
          ),
          const SizedBox(height: 8),
          SoftButton(
            label: 'Join Waitlist & Notify Me',
            icon: Icons.notifications_active_outlined,
            foreground: AppColors.emerald,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

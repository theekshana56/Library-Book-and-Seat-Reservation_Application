import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_client.dart';
import '../admin/controllers/admin_api_client.dart';
import '../admin/models/admin_models.dart';
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
  final _adminApi = AdminApiClient();
  Book? _book;
  List<LibraryShelf> _shelves = [];
  bool _loading = true;
  bool _summaryExpanded = false;
  bool _joiningWaitlist = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _load();
  }

  Future<void> _load() async {
    try {
      final book = await _api.getBook(widget.bookId);
      var shelves = <LibraryShelf>[];
      try {
        shelves = await _adminApi.getShelves();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _book = book;
        _shelves = shelves;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  LibraryShelf? _assignedShelf(Book book) {
    for (final shelf in _shelves) {
      if (shelf.shelfCode.trim().toLowerCase() ==
          book.shelfCode.trim().toLowerCase()) {
        return shelf;
      }
    }
    return null;
  }

  Future<void> _joinWaitlist(Book book) async {
    setState(() => _joiningWaitlist = true);
    try {
      final position = await _api.joinWaitlist(book.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You joined the waitlist at position $position.'),
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _joiningWaitlist = false);
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
                  _bookSummary(book),
                  const SizedBox(height: 14),
                  _stock(book),
                  const SizedBox(height: 12),
                  _infoGrid(book),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: _joiningWaitlist
                        ? 'Joining Waitlist...'
                        : book.isAvailable
                        ? 'Reserve Book'
                        : 'Join Waitlist',
                    trailing: book.isAvailable
                        ? Icons.arrow_forward_rounded
                        : Icons.notifications_active_outlined,
                    onPressed: book.isAvailable
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ConfirmReservationScreen(book: book),
                            ),
                          )
                        : _joiningWaitlist
                        ? null
                        : () => _joinWaitlist(book),
                  ),
                  const SizedBox(height: 14),
                  _wayfinding(book),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bookSummary(Book book) {
    final summary = book.description?.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notes_rounded,
                size: 18,
                color: AppColors.emerald,
              ),
              const SizedBox(width: 8),
              Text(
                'BOOK SUMMARY',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (summary == null || summary.isEmpty)
            Text(
              'A summary is not available for this title yet.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            )
          else ...[
            Text(
              summary,
              maxLines: _summaryExpanded ? null : 5,
              overflow: _summaryExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.55,
                color: AppColors.textPrimary,
              ),
            ),
            if (summary.length > 260)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () =>
                      setState(() => _summaryExpanded = !_summaryExpanded),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(top: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _summaryExpanded ? 'Show less' : 'Read more',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _hero(Book book) {
    final shelf = _assignedShelf(book);
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
                        shelf == null
                            ? 'Shelf assignment pending'
                            : 'Shelf ${shelf.shelfCode} • ${shelf.level}, ${shelf.zone}',
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
              book.isAvailable
                  ? '●  AVAILABLE NOW'
                  : book.inventoryStatus == 'PENDING_SHELVING' ||
                        book.shelfCode.trim().isEmpty
                  ? '●  AWAITING SHELVING'
                  : '●  IN CIRCULATION',
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
    final shelf = _assignedShelf(book);
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
                  shelf == null
                      ? 'Location will appear once a shelf is assigned.'
                      : '${shelf.level} • ${shelf.zone}',
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
}

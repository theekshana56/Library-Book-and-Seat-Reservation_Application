import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../debug_agent_log.dart';
import '../api/api_client.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import 'BookDetailsScreen.dart';

class SearchCatalogScreen extends StatefulWidget {
  const SearchCatalogScreen({super.key});

  @override
  State<SearchCatalogScreen> createState() => _SearchCatalogScreenState();
}

class _SearchCatalogScreenState extends State<SearchCatalogScreen> {
  final _api = ApiClient();
  final _controller = TextEditingController();
  Timer? _searchDebounce;
  int _searchRequestId = 0;
  List<String> _categories = const ['All Topics'];
  String _category = 'All Topics';
  String _availabilityFilter = 'All';
  List<Book> _books = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final books = await _api.searchBooks();
      final categories =
          books
              .map((book) => book.category.trim())
              .where((category) => category.isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _categories = ['All Topics', ...categories];
        if (!_categories.contains(_category)) _category = 'All Topics';
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _controller.dispose();
    // #region agent log
    agentDebugLog(
      location: 'SearchCatalogScreen.dart:dispose',
      message: 'search catalog state disposing',
      hypothesisId: 'D',
      data: {'controllerListeners': _controller.hasListeners},
    );
    // #endregion
    super.dispose();
  }

  Future<void> _load() async {
    _searchDebounce?.cancel();
    _searchDebounce = null;
    final requestId = ++_searchRequestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await _api.searchBooks(
        query: _controller.text,
        category: _category,
      );
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _books = books;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleBooks = _books.where((book) {
      if (_availabilityFilter == 'Available') return book.isAvailable;
      if (_availabilityFilter == 'Checked out') return !book.isAvailable;
      return true;
    }).toList();

    return Column(
      children: [
        NavyAppHeader(
          eyebrow: 'CATALOG DIRECTORY',
          title: 'Search Catalog',
          extra: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                _headerChip('Term 2025'),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF1A9B84),
                  child: Text(
                    'RW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _searchBar(),
              const SizedBox(height: 14),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final selected = _categories[i] == _category;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(_categories[i]),
                      avatar: selected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                      selectedColor: AppColors.tealChip,
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppColors.tealChip
                            : const Color(0xFFD5DEE8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() => _category = _categories[i]);
                        _load();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '${visibleBooks.length} RESULTS',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.textMuted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            ' in Main Science Library',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Filter by availability',
                    initialValue: _availabilityFilter,
                    onSelected: (filter) =>
                        setState(() => _availabilityFilter = filter),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'All', child: Text('All books')),
                      PopupMenuItem(
                        value: 'Available',
                        child: Text('Available now'),
                      ),
                      PopupMenuItem(
                        value: 'Checked out',
                        child: Text('Checked out'),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Filters',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
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
              if (!_loading && _error == null && visibleBooks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: Text('No books match these filters.')),
                ),
              ...visibleBooks.map(_bookCard),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2C40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B425C)),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (_) {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 300), _load);
        },
        onSubmitted: (_) => _load(),
        decoration: InputDecoration(
          hintText: 'Search catalog',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
          ),
          filled: true,
          fillColor: AppColors.searchFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _bookCard(Book book) {
    final available = book.isAvailable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: AppColors.cardShadow,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookDetailsScreen(bookId: book.id, book: book),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(
                      url: book.coverImageUrl,
                      badge: book.publisher,
                      width: 70,
                      height: 96,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusPill(
                                label: available ? 'Available' : 'Checked Out',
                                success: available,
                              ),
                              const Spacer(),
                              Text(
                                available
                                    ? (book.availableCopies == 1
                                          ? '1 Copy on Shelf'
                                          : '${book.availableCopies} Copies')
                                    : 'Due ${_fmt(book.nextReturnDate)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: available
                                      ? AppColors.mintText
                                      : const Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            _highlightPrefix(book.title),
                            style: AppTheme.serifTitle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                _highlightPrefix(book.author),
                                TextSpan(text: '  •  ${book.edition}'),
                              ],
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.searchFill,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColors.emerald,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    book.shelfLabel,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!available)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9AA8B5),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (available)
                      Icon(
                        book.expressHoldHours == 2
                            ? Icons.lock_outline
                            : Icons.verified_outlined,
                        size: 16,
                        color: AppColors.mintText,
                      ),
                    if (!available)
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.checkedText,
                      ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        available
                            ? (book.catalogNotice ??
                                  'Ready for express pickup today')
                            : 'Waitlist: ${book.waitlistCount} researchers queued',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (available)
                      PrimaryButton(
                        label: 'Reserve',
                        expanded: false,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                BookDetailsScreen(bookId: book.id, book: book),
                          ),
                        ),
                      )
                    else
                      SoftButton(
                        label: 'Join Waitlist',
                        expanded: false,
                        foreground: AppColors.emerald,
                        onPressed: () {},
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextSpan _highlightPrefix(String value) {
    final query = _controller.text.trim();
    if (query.isEmpty || !value.toLowerCase().startsWith(query.toLowerCase())) {
      return TextSpan(text: value);
    }

    return TextSpan(
      children: [
        TextSpan(
          text: value.substring(0, query.length),
          style: const TextStyle(
            color: AppColors.emerald,
            fontWeight: FontWeight.w800,
            backgroundColor: Color(0xFFD7F2EA),
          ),
        ),
        TextSpan(text: value.substring(query.length)),
      ],
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Apr 22';
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}';
  }
}

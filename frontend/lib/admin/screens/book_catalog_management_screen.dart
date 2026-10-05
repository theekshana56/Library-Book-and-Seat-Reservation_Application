import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book.dart';
import '../../theme/app_colors.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class BookCatalogManagementScreen extends StatefulWidget {
  const BookCatalogManagementScreen({super.key});

  @override
  State<BookCatalogManagementScreen> createState() =>
      _BookCatalogManagementScreenState();
}

class _BookCatalogManagementScreenState
    extends State<BookCatalogManagementScreen> {
  final _api = AdminApiClient();
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _publisher = TextEditingController();
  final _edition = TextEditingController();
  final _year = TextEditingController();
  final _category = TextEditingController();
  final _callNumber = TextEditingController();
  final _format = TextEditingController(text: 'Print Copy');
  final _loanPeriod = TextEditingController(text: '14');
  final _copies = TextEditingController(text: '1');
  final _isbn = TextEditingController();
  final _coverUrl = TextEditingController();
  final _description = TextEditingController();
  List<Book> _books = [];
  List<LibraryShelf> _shelves = [];
  String? _selectedShelf;
  String? _editingId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _publisher.dispose();
    _edition.dispose();
    _year.dispose();
    _category.dispose();
    _callNumber.dispose();
    _format.dispose();
    _loanPeriod.dispose();
    _copies.dispose();
    _isbn.dispose();
    _coverUrl.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getBooks(),
        _api.getActiveShelves(),
      ]);
      if (!mounted) return;
      setState(() {
        _books = results[0] as List<Book>;
        _shelves = results[1] as List<LibraryShelf>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _edit(Book book) {
    setState(() {
      _editingId = book.id;
      _title.text = book.title;
      _author.text = book.author;
      _publisher.text = book.publisher;
      _edition.text = book.edition;
      _year.text = book.year == 0 ? '' : '${book.year}';
      _category.text = book.category;
      _callNumber.text = book.callNumber;
      _format.text = book.format;
      _loanPeriod.text = '${book.loanPeriodDays}';
      _copies.text = '${book.totalCopies}';
      _isbn.text = book.isbn ?? '';
      _coverUrl.text = book.coverImageUrl;
      _description.text = book.description ?? '';
      _selectedShelf = book.shelfCode.isEmpty ? null : book.shelfCode;
    });
  }

  void _clearForm() {
    _editingId = null;
    _title.clear();
    _author.clear();
    _publisher.clear();
    _edition.clear();
    _year.clear();
    _category.clear();
    _callNumber.clear();
    _format.text = 'Print Copy';
    _loanPeriod.text = '14';
    _copies.text = '1';
    _isbn.clear();
    _coverUrl.clear();
    _description.clear();
    _selectedShelf = null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final editing = _editingId;
    try {
      await _api.saveBook({
        'title': _title.text.trim(),
        'author': _author.text.trim(),
        'publisher': _publisher.text.trim(),
        'edition': _edition.text.trim(),
        'year': int.tryParse(_year.text) ?? 0,
        'category': _category.text.trim(),
        'callNumber': _callNumber.text.trim(),
        'format': _format.text.trim(),
        'shelfCode': _selectedShelf,
        'loanPeriodDays': int.parse(_loanPeriod.text),
        'totalCopies': int.parse(_copies.text),
        'coverImageUrl': _coverUrl.text.trim(),
        'description': _description.text.trim(),
        'isbn': _isbn.text.trim(),
      }, id: editing);
      if (!mounted) return;
      setState(_clearForm);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(editing == null ? 'Book added to catalog.' : 'Book updated.'),
        ),
      );
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _archive(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive book?'),
        content: Text(
          'Archive "${book.title}"? Active reservations and loans must be resolved first. The title history will be retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep book'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.archiveBook(book.id);
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AdminPageScaffold(
    title: 'Book catalog',
    subtitle: 'INVENTORY & CATALOG MANAGEMENT',
    child: _loading || _error != null
        ? AdminLoadingError(loading: _loading, error: _error, onRetry: _load)
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AdminCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminSectionTitle(
                        _editingId == null ? 'Add catalog title' : 'Edit catalog title',
                        trailing: _editingId == null ? null : 'INVENTORY PRESERVED',
                      ),
                      const SizedBox(height: 12),
                      AdminField(label: 'Title', controller: _title, validator: _required),
                      const SizedBox(height: 9),
                      AdminField(label: 'Author', controller: _author, validator: _required),
                      const SizedBox(height: 9),
                      Row(children: [
                        Expanded(child: AdminField(label: 'Publisher', controller: _publisher)),
                        const SizedBox(width: 9),
                        Expanded(child: AdminField(label: 'Category', controller: _category, validator: _required)),
                      ]),
                      const SizedBox(height: 9),
                      Row(children: [
                        Expanded(child: AdminField(label: 'Edition', controller: _edition)),
                        const SizedBox(width: 9),
                        Expanded(child: AdminField(label: 'Publication year', controller: _year, keyboardType: TextInputType.number, validator: _optionalNonNegative)),
                      ]),
                      const SizedBox(height: 9),
                      Row(children: [
                        Expanded(child: AdminField(label: 'Call number', controller: _callNumber)),
                        const SizedBox(width: 9),
                        Expanded(child: AdminField(label: 'Format', controller: _format, validator: _required)),
                      ]),
                      const SizedBox(height: 9),
                      Row(children: [
                        Expanded(child: AdminField(label: 'Loan days', controller: _loanPeriod, keyboardType: TextInputType.number, validator: _positiveInteger)),
                        const SizedBox(width: 9),
                        Expanded(child: AdminField(label: 'Total copies', controller: _copies, keyboardType: TextInputType.number, validator: _positiveInteger)),
                      ]),
                      const SizedBox(height: 9),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedShelf,
                        isExpanded: true,
                        decoration: _decoration('Shelf (leave blank to create a shelving task)'),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Pending shelving')),
                          ..._shelves.map((shelf) => DropdownMenuItem<String?>(
                                value: shelf.shelfCode,
                                child: Text('${shelf.shelfCode} · ${shelf.level} · ${shelf.zone}'),
                              )),
                        ],
                        onChanged: (value) => setState(() => _selectedShelf = value),
                      ),
                      const SizedBox(height: 9),
                      AdminField(label: 'ISBN', controller: _isbn),
                      const SizedBox(height: 9),
                      AdminField(label: 'Cover image URL', controller: _coverUrl, keyboardType: TextInputType.url),
                      const SizedBox(height: 9),
                      AdminField(label: 'Description', controller: _description, maxLines: 3),
                      const SizedBox(height: 12),
                      Row(children: [
                        if (_editingId != null) ...[
                          Expanded(child: OutlinedButton(onPressed: () => setState(_clearForm), child: const Text('Cancel edit'))),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(_editingId == null ? 'Add book' : 'Save changes'),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.emerald),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AdminSectionTitle('Catalog records', trailing: '${_books.length} TITLES'),
              const SizedBox(height: 9),
              if (_books.isEmpty)
                const AdminCard(child: Text('No catalog records yet.')),
              ..._books.map(_bookCard),
            ],
          ),
  );

  Widget _bookCard(Book book) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: AdminCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F2ED),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.emerald),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
                Text('${book.author} · ${book.category}', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 10)),
                Text(
                  book.shelfCode.isEmpty
                      ? 'Pending shelving · ${book.totalCopies} copies'
                      : '${book.shelfCode} · ${book.availableCopies}/${book.totalCopies} available',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          if (book.active) ...[
            IconButton(tooltip: 'Edit book', onPressed: () => _edit(book), icon: const Icon(Icons.edit_outlined, size: 19)),
            IconButton(tooltip: 'Archive book', onPressed: () => _archive(book), icon: const Icon(Icons.archive_outlined, size: 19)),
          ] else
            const AdminStatusPill('ARCHIVED'),
        ],
      ),
    ),
  );

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;

  String? _positiveInteger(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed != null && parsed > 0 ? null : 'Enter a positive number.';
  }

  String? _optionalNonNegative(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value);
    return parsed != null && parsed >= 0 ? null : 'Enter zero or a positive year.';
  }
}

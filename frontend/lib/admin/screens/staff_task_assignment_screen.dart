import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book.dart';
import '../../theme/app_colors.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class StaffTaskAssignmentScreen extends StatefulWidget {
  const StaffTaskAssignmentScreen({super.key});

  @override
  State<StaffTaskAssignmentScreen> createState() =>
      _StaffTaskAssignmentScreenState();
}

class _StaffTaskAssignmentScreenState extends State<StaffTaskAssignmentScreen> {
  final _api = AdminApiClient();
  final _description = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  List<AdminUser> _staff = [];
  List<Book> _books = [];
  List<LibraryShelf> _shelves = [];
  List<StaffTask> _tasks = [];
  String? _staffId;
  String? _bookId;
  String? _shelfCode;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _description.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final values = await Future.wait([
        _api.getUsers(role: 'LIBRARY_STAFF', active: true),
        _api.getPendingShelvingBooks(),
        _api.getActiveShelves(),
      ]);
      if (!mounted) return;
      _staff = values[0] as List<AdminUser>;
      _books = values[1] as List<Book>;
      _shelves = values[2] as List<LibraryShelf>;
      _staffId ??= _staff.isEmpty ? null : _staff.first.id;
      _shelfCode ??= _shelves.isEmpty ? null : _shelves.first.shelfCode;
      if (_staffId != null) _tasks = await _api.getStaffTasks(_staffId!);
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshStaffTasks() async {
    if (_staffId == null) return;
    try {
      final tasks = await _api.getStaffTasks(_staffId!);
      if (mounted) setState(() => _tasks = tasks);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _assign() async {
    if (_staffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create or activate a library staff account first.'),
        ),
      );
      return;
    }
    final quantity = int.tryParse(_quantity.text);
    if (quantity == null || quantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a quantity greater than zero.')),
      );
      return;
    }
    final selectedBook = _bookId == null
        ? null
        : _books.where((book) => book.id == _bookId).firstOrNull;
    setState(() => _saving = true);
    try {
      await _api.assignTask({
        'assignedStaffId': _staffId,
        if (selectedBook != null) 'bookId': selectedBook.id,
        if (selectedBook != null) 'bookTitle': selectedBook.title,
        'taskDescription': _description.text.trim().isNotEmpty
            ? _description.text.trim()
            : selectedBook == null
            ? 'Library maintenance'
            : 'Shelve ${selectedBook.title}',
        'targetShelfCode': _shelfCode,
        'quantity': quantity,
      });
      if (!mounted) return;
      _description.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task assigned to library staff.')),
      );
      await _refreshStaffTasks();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AdminPageScaffold(
    title: 'Staff assignments',
    subtitle: 'SHELVING & MAINTENANCE',
    child: _loading || _error != null
        ? AdminLoadingError(loading: _loading, error: _error, onRetry: _load)
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AdminCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminSectionTitle('Create staff task'),
                    const SizedBox(height: 12),
                    _selectStaff(),
                    const SizedBox(height: 10),
                    _selectBook(),
                    const SizedBox(height: 10),
                    AdminField(
                      label: 'Task instructions',
                      controller: _description,
                      hint: 'Catalog and shelve at Level 3, CS-301',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _selectShelf()),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 104,
                          child: AdminField(
                            label: 'Copies',
                            controller: _quantity,
                            keyboardType: TextInputType.number,
                            readOnly: _bookId != null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _assign,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 18,
                              ),
                        label: const Text('Assign task'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              AdminSectionTitle(
                'Selected staff tasks',
                trailing:
                    '${_tasks.where((task) => task.status != 'COMPLETED' && task.status != 'CANCELLED').length} OPEN',
              ),
              const SizedBox(height: 10),
              if (_staff.isEmpty)
                const AdminCard(
                  child: Text('No active library staff accounts.'),
                ),
              if (_staff.isNotEmpty && _tasks.isEmpty)
                const AdminCard(
                  child: Text('No assignments for this staff member.'),
                ),
              ..._tasks.map(_taskTile),
            ],
          ),
  );

  Widget _selectStaff() => DropdownButtonFormField<String>(
    key: ValueKey('staff-list-${_staff.length}'),
    isExpanded: true,
    initialValue: _staffId,
    decoration: _decoration('Assign to library staff'),
    items: _staff
        .map(
          (user) => DropdownMenuItem(
            value: user.id,
            child: Text(
              '${user.fullName} Â· ${user.department}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: _staff.isEmpty
        ? null
        : (id) async {
            if (id == null) return;
            setState(() => _staffId = id);
            await _refreshStaffTasks();
          },
  );

  Widget _selectBook() => DropdownButtonFormField<String?>(
    key: ValueKey('book-list-${_books.length}'),
    isExpanded: true,
    initialValue: _bookId,
    decoration: _decoration('Approved book awaiting shelving'),
    items: [
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('General library task'),
      ),
      ..._books.map(
        (book) => DropdownMenuItem<String?>(
          value: book.id,
          child: Text(
            '${book.title} Â· ${book.totalCopies} copies',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
    onChanged: (id) {
      setState(() {
        _bookId = id;
        final book = _books.where((item) => item.id == id).firstOrNull;
        if (book != null) _quantity.text = '${book.totalCopies}';
      });
    },
  );

  Widget _selectShelf() => DropdownButtonFormField<String>(
    key: ValueKey('shelf-list-${_shelves.length}'),
    isExpanded: true,
    initialValue: _shelves.any((shelf) => shelf.shelfCode == _shelfCode)
        ? _shelfCode
        : null,
    decoration: _decoration('Target shelf'),
    items: _shelves
        .map(
          (shelf) => DropdownMenuItem(
            value: shelf.shelfCode,
            child: Text(
              '${shelf.shelfCode} Â· ${shelf.level}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: (code) => setState(() => _shelfCode = code),
  );

  Widget _taskTile(StaffTask task) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AdminCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: AppColors.emerald,
            size: 20,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.bookTitle.isEmpty
                      ? task.taskDescription
                      : task.bookTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${task.assignedStaffName} Â· ${task.quantity} copies Â· ${task.targetShelfCode}',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF5B6B7C),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          AdminStatusPill(task.status),
          if (task.status != 'COMPLETED' && task.status != 'CANCELLED')
            PopupMenuButton<String>(
              tooltip: 'Task actions',
              onSelected: (action) {
                if (action == 'edit') _editTask(task);
                if (action == 'cancel') _cancelTask(task);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit task')),
                PopupMenuItem(value: 'cancel', child: Text('Cancel task')),
              ],
            ),
        ],
      ),
    ),
  );

  Future<void> _editTask(StaffTask task) async {
    final instructions = TextEditingController(text: task.taskDescription);
    final shelf = TextEditingController(text: task.targetShelfCode);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit staff task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: instructions,
              decoration: const InputDecoration(labelText: 'Instructions'),
              minLines: 2,
              maxLines: 4,
            ),
            TextField(
              controller: shelf,
              decoration: const InputDecoration(labelText: 'Target shelf'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) {
      try {
        await _api.editTask(task.id, {
          'assignedStaffId': task.assignedStaffId,
          'taskDescription': instructions.text.trim(),
          'targetShelfCode': shelf.text.trim(),
        });
        await _refreshStaffTasks();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }
      }
    }
    instructions.dispose();
    shelf.dispose();
  }

  Future<void> _cancelTask(StaffTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel task?'),
        content: const Text(
          'The task will remain in the record as cancelled and will no longer appear as open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep task'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel task'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.cancelTask(task.id);
      await _refreshStaffTasks();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDCE4EB)),
    ),
  );
}

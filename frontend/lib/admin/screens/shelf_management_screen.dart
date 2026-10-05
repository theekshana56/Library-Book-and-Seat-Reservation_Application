import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class ShelfManagementScreen extends StatefulWidget {
  const ShelfManagementScreen({super.key});

  @override
  State<ShelfManagementScreen> createState() => _ShelfManagementScreenState();
}

class _ShelfManagementScreenState extends State<ShelfManagementScreen> {
  final _api = AdminApiClient();
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _level = TextEditingController();
  final _zone = TextEditingController();
  final _capacity = TextEditingController();
  List<LibraryShelf> _shelves = [];
  String? _editingId;
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
    _code.dispose();
    _level.dispose();
    _zone.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final shelves = await _api.getShelves();
      if (!mounted) return;
      setState(() {
        _shelves = shelves;
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

  void _edit(LibraryShelf shelf) {
    setState(() {
      _editingId = shelf.id;
      _code.text = shelf.shelfCode;
      _level.text = shelf.level;
      _zone.text = shelf.zone;
      _capacity.text = '${shelf.maxCapacity}';
    });
  }

  void _clearForm() {
    _editingId = null;
    _code.clear();
    _level.clear();
    _zone.clear();
    _capacity.clear();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final isEditing = _editingId != null;
    setState(() => _saving = true);
    try {
      await _api.saveShelf({
        'shelfCode': _code.text.trim().toUpperCase(),
        'level': _level.text.trim(),
        'zone': _zone.text.trim(),
        'maxCapacity': int.parse(_capacity.text),
        if (_editingId == null) 'currentBookCount': 0,
      }, id: _editingId);
      if (!mounted) return;
      setState(_clearForm);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Shelf updated.' : 'Shelf created.'),
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

  Future<void> _archive(LibraryShelf shelf) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive shelf?'),
        content: Text(
          'Archive ${shelf.shelfCode}? Books and open tasks must be moved first. The record will be retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep shelf'),
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
      await _api.archiveShelf(shelf.id);
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
    title: 'Shelf inventory',
    subtitle: 'CAPACITY & WAYFINDING',
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
                        _editingId == null ? 'Add shelf' : 'Edit shelf',
                        trailing: _editingId == null
                            ? null
                            : 'CURRENT COUNT PRESERVED',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AdminField(
                              label: 'Shelf code',
                              controller: _code,
                              hint: 'CS-204',
                              validator: _required,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AdminField(
                              label: 'Floor level',
                              controller: _level,
                              hint: 'Level 2',
                              validator: _required,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AdminField(
                        label: 'Category zone',
                        controller: _zone,
                        hint: 'Quiet Zone - East Wing',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      AdminField(
                        label: 'Maximum capacity',
                        controller: _capacity,
                        keyboardType: TextInputType.number,
                        validator: _capacityValidator,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_editingId != null) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(_clearForm),
                                icon: const Icon(Icons.close_rounded, size: 17),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                          ],
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.emerald,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                              icon: const Icon(Icons.save_outlined, size: 17),
                              label: Text(
                                _editingId == null
                                    ? 'Add shelf'
                                    : 'Save changes',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AdminSectionTitle(
                'Library shelves',
                trailing: '${_shelves.length} SHELVES',
              ),
              const SizedBox(height: 10),
              if (_shelves.isEmpty)
                const AdminCard(child: Text('No shelf records yet.')),
              ..._shelves.map(_shelfCard),
            ],
          ),
  );

  Widget _shelfCard(LibraryShelf shelf) {
    final ratio = shelf.maxCapacity == 0
        ? 0.0
        : (shelf.currentBookCount / shelf.maxCapacity).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F2ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.emerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shelf.shelfCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${shelf.level} | ${shelf.zone}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFF5B6B7C),
                        ),
                      ),
                    ],
                  ),
                ),
                if (shelf.active) ...[
                  IconButton(
                    onPressed: () => _edit(shelf),
                    tooltip: 'Edit shelf',
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.emerald,
                      size: 19,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _archive(shelf),
                    tooltip: 'Archive shelf',
                    icon: const Icon(
                      Icons.archive_outlined,
                      color: Color(0xFFB45309),
                      size: 19,
                    ),
                  ),
                ] else
                  const AdminStatusPill('ARCHIVED'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE8EDF2),
                      color: percent >= 90
                          ? const Color(0xFFB45309)
                          : AppColors.emerald,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${shelf.currentBookCount} / ${shelf.maxCapacity}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF34495E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;
  String? _capacityValidator(String? value) {
    final count = int.tryParse(value ?? '');
    return count != null && count > 0 ? null : 'Enter a positive capacity.';
  }
}

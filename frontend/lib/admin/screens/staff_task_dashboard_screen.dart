import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class StaffTaskDashboardScreen extends StatefulWidget {
  final String? initialStaffId;
  const StaffTaskDashboardScreen({super.key, this.initialStaffId});

  @override
  State<StaffTaskDashboardScreen> createState() =>
      _StaffTaskDashboardScreenState();
}

class _StaffTaskDashboardScreenState extends State<StaffTaskDashboardScreen> {
  final _api = AdminApiClient();
  List<AdminUser> _staff = [];
  List<LibraryShelf> _shelves = [];
  List<StaffTask> _tasks = [];
  String? _staffId;
  String? _error;
  bool _loading = true;
  final Map<String, String?> _shelfCodes = {};

  @override
  void initState() {
    super.initState();
    _staffId = widget.initialStaffId;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final values = await Future.wait([
        _api.getUsers(role: 'LIBRARY_STAFF', active: true),
        _api.getShelves(),
      ]);
      if (!mounted) return;
      _staff = values[0] as List<AdminUser>;
      _shelves = values[1] as List<LibraryShelf>;
      if (_staffId == null || !_staff.any((user) => user.id == _staffId)) {
        _staffId = _staff.isEmpty ? null : _staff.first.id;
      }
      await _loadTasks();
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadTasks() async {
    if (_staffId == null) {
      _tasks = [];
      return;
    }
    _tasks = await _api.getStaffTasks(_staffId!);
  }

  Future<void> _changeStatus(StaffTask task, String status) async {
    final shelf = _shelfCodes[task.id] ?? task.targetShelfCode;
    if (status == 'COMPLETED' && shelf.isEmpty && task.bookId.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a shelf before completing this task.'),
        ),
      );
      return;
    }
    try {
      await _api.updateTask(
        task.id,
        status,
        shelfCode: shelf.isEmpty ? null : shelf,
      );
      await _loadTasks();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AdminPageScaffold(
    title: 'My library tasks',
    subtitle: 'STAFF WORKSPACE',
    actions: [
      IconButton(
        onPressed: _load,
        tooltip: 'Refresh tasks',
        icon: const Icon(Icons.refresh_rounded),
      ),
    ],
    child: _loading || _error != null
        ? AdminLoadingError(loading: _loading, error: _error, onRetry: _load)
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_staff.isNotEmpty) _selectStaff(),
              const SizedBox(height: 16),
              AdminSectionTitle(
                'Active assignments',
                trailing:
                    '${_tasks.where((task) => task.status != 'COMPLETED' && task.status != 'CANCELLED').length} OPEN',
              ),
              const SizedBox(height: 10),
              if (_staff.isEmpty)
                const AdminCard(
                  child: Text('No active library staff account found.'),
                ),
              if (_staff.isNotEmpty && _tasks.isEmpty)
                const AdminCard(child: Text('You have no assigned tasks.')),
              ..._tasks.map(_taskCard),
            ],
          ),
  );

  Widget _selectStaff() => DropdownButtonFormField<String>(
    key: ValueKey('staff-list-${_staff.length}'),
    isExpanded: true,
    initialValue: _staffId,
    decoration: const InputDecoration(
      labelText: 'Staff account',
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
    ),
    items: _staff
        .map(
          (user) =>
              DropdownMenuItem(value: user.id, child: Text(user.fullName)),
        )
        .toList(),
    onChanged: (id) async {
      if (id == null) return;
      setState(() {
        _staffId = id;
        _loading = true;
      });
      try {
        await _loadTasks();
        if (mounted) setState(() => _loading = false);
      } catch (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
            _loading = false;
          });
        }
      }
    },
  );

  Widget _taskCard(StaffTask task) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.bookTitle.isEmpty
                      ? task.taskDescription
                      : task.bookTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              AdminStatusPill(task.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.taskDescription,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF5B6B7C),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          if (task.bookId.isNotEmpty &&
              task.status != 'COMPLETED' &&
              task.status != 'CANCELLED')
            _shelfPicker(task),
          const SizedBox(height: 9),
          Row(
            children: [
              if (task.status == 'PENDING')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _changeStatus(task, 'IN_PROGRESS'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start task'),
                  ),
                ),
              if (task.status == 'IN_PROGRESS')
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _changeStatus(task, 'COMPLETED'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: const Text('Complete task'),
                  ),
                ),
              if (task.status == 'COMPLETED')
                const Icon(Icons.task_alt_rounded, color: AppColors.mintText),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _shelfPicker(StaffTask task) => DropdownButtonFormField<String>(
    key: ValueKey('task-shelf-${task.id}'),
    isExpanded: true,
    initialValue:
        _shelves.any(
          (shelf) =>
              shelf.shelfCode == (_shelfCodes[task.id] ?? task.targetShelfCode),
        )
        ? (_shelfCodes[task.id] ?? task.targetShelfCode)
        : null,
    decoration: InputDecoration(
      labelText: 'Physical shelf code',
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    items: _shelves
        .map(
          (shelf) => DropdownMenuItem(
            value: shelf.shelfCode,
            child: Text('${shelf.shelfCode} | ${shelf.level}'),
          ),
        )
        .toList(),
    onChanged: (code) => setState(() => _shelfCodes[task.id] = code),
  );
}

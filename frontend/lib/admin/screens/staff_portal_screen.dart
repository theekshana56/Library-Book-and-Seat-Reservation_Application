import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../user_management/controllers/auth_controller.dart';
import '../../user_management/models/user_profile.dart';
import '../../user_management/screens/change_password_screen.dart';
import '../../user_management/screens/edit_profile_screen.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class StaffPortalScreen extends StatefulWidget {
  final AuthController authController;
  final AdminApiClient? apiClient;

  const StaffPortalScreen({
    super.key,
    required this.authController,
    this.apiClient,
  });

  @override
  State<StaffPortalScreen> createState() => _StaffPortalScreenState();
}

class _StaffPortalScreenState extends State<StaffPortalScreen> {
  late final AdminApiClient _api = widget.apiClient ?? AdminApiClient();
  List<StaffTask> _tasks = [];
  List<LibraryShelf> _shelves = [];
  bool _loading = true;
  String? _error;
  int _selectedIndex = 0;

  UserProfile get _user => widget.authController.currentUser!;

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
      final values = await Future.wait([
        _api.getMyStaffTasks(),
        _api.getStaffShelves(),
      ]);
      if (!mounted) return;
      setState(() {
        _tasks = values[0] as List<StaffTask>;
        _shelves = values[1] as List<LibraryShelf>;
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

  Future<void> _setTaskStatus(StaffTask task, String status) async {
    String? shelfCode = task.targetShelfCode.isEmpty
        ? null
        : task.targetShelfCode;
    if (status == 'COMPLETED' && task.bookId.isNotEmpty) {
      shelfCode ??= await _chooseShelf();
      if (shelfCode == null) return;
    }

    try {
      await _api.updateMyTask(task.id, status, shelfCode: shelfCode);
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<String?> _chooseShelf() async {
    if (_shelves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No library shelves are available yet.')),
      );
      return null;
    }
    return showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select destination shelf'),
        children: [
          for (final shelf in _shelves)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(shelf.shelfCode),
              child: Text('${shelf.shelfCode} · ${shelf.level} · ${shelf.zone}'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageBg,
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: IndexedStack(
          index: _selectedIndex,
          children: [_tasksPage(), _todoPage(), _profilePage()],
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) =>
          setState(() => _selectedIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: 'My tasks',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_outlined),
          selectedIcon: Icon(Icons.checklist_rounded),
          label: 'To-dos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );

  Widget _tasksPage() => AdminPageScaffold(
    title: 'My tasks',
    subtitle: 'LIBRARY STAFF WORKSPACE',
    actions: [
      IconButton(
        onPressed: _loading ? null : _load,
        tooltip: 'Refresh tasks',
        icon: const Icon(Icons.refresh_rounded),
      ),
    ],
    child: _loading || _error != null
        ? AdminLoadingError(loading: _loading, error: _error, onRetry: _load)
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _welcomeCard(),
                const SizedBox(height: 16),
                AdminSectionTitle(
                  'Assigned work',
                  trailing:
                      '${_tasks.where((task) => task.status != 'COMPLETED').length} OPEN',
                ),
                const SizedBox(height: 10),
                if (_tasks.isEmpty)
                  const AdminCard(
                    child: Text('No tasks assigned yet. Check back later.'),
                  ),
                ..._tasks.map(_taskCard),
              ],
            ),
          ),
  );

  Widget _todoPage() {
    final openTasks = _tasks.where((task) => task.status != 'COMPLETED');
    return AdminPageScaffold(
      title: 'My to-dos',
      subtitle: 'YOUR OPEN CHECKLIST',
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          tooltip: 'Refresh to-dos',
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: _loading || _error != null
          ? AdminLoadingError(loading: _loading, error: _error, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AdminCard(
                    child: Text(
                      '${openTasks.length} items remain on your assigned checklist.',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (openTasks.isEmpty)
                    const AdminCard(
                      child: Text('You are all caught up. No open to-dos.'),
                    ),
                  ...openTasks.map(_todoCard),
                ],
              ),
            ),
    );
  }

  Widget _welcomeCard() => AdminCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${_user.fullName}',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'View your assignments and keep your library work up to date.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    ),
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
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              AdminStatusPill(task.status),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            task.taskDescription,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          if (task.bookId.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${task.quantity} copies · Shelf ${task.targetShelfCode.isEmpty ? 'not selected' : task.targetShelfCode}',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
          if (task.status != 'COMPLETED') ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: task.status == 'PENDING'
                  ? OutlinedButton(
                      onPressed: () => _setTaskStatus(task, 'IN_PROGRESS'),
                      child: const Text('Start task'),
                    )
                  : FilledButton.icon(
                      onPressed: () => _setTaskStatus(task, 'COMPLETED'),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Complete task'),
                    ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _todoCard(StaffTask task) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: false,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.emerald,
          title: Text(
            task.bookTitle.isEmpty ? task.taskDescription : task.bookTitle,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          subtitle: Text(
            '${task.status == 'PENDING' ? 'Not started' : 'In progress'} · ${task.taskDescription}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          onChanged: (_) => _setTaskStatus(
            task,
            task.status == 'PENDING' ? 'IN_PROGRESS' : 'COMPLETED',
          ),
        ),
      ),
    ),
  );

  Widget _profilePage() => AdminPageScaffold(
    title: 'Staff profile',
    subtitle: 'ACCOUNT DETAILS',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.navy,
                child: Text(
                  AuthController.getInitialsForName(_user.fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _user.fullName,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(_user.email),
              if (_user.department?.isNotEmpty == true)
                Text(_user.department!),
              const Divider(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        authController: widget.authController,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordScreen(
                        authController: widget.authController,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Change password'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.authController.logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

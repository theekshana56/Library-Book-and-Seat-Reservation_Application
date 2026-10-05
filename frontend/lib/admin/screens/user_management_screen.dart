import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  static const _roles = [
    'STUDENT',
    'UNDERGRADUATE_STUDENT',
    'POSTGRADUATE_STUDENT',
    'LIBRARY_STAFF',
    'ACADEMIC_STAFF',
    'IT_SUPPORT_STAFF',
    'LECTURER',
    'VENDOR',
    'MAINTENANCE_STAFF',
    'UNIVERSITY_MANAGEMENT',
    'ADMIN',
  ];
  final _api = AdminApiClient();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _department = TextEditingController();
  List<AdminUser> _users = [];
  String _role = _roles.first;
  bool _active = true;
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
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _api.getUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
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

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.createUser({
        'fullName': _name.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'role': _role,
        'department': _department.text.trim(),
        if (_role == 'VENDOR') 'vendorCompanyName': _department.text.trim(),
        'userCategory': _role,
        'active': _active,
      });
      if (!mounted) return;
      _name.clear();
      _email.clear();
      _password.clear();
      _department.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created.')));
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

  Future<void> _setActive(AdminUser user, bool active) async {
    try {
      await _api.setUserActive(user.id, active);
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _editUser(AdminUser user) async {
    final name = TextEditingController(text: user.fullName);
    final email = TextEditingController(text: user.email);
    final organization = TextEditingController(
      text: user.vendorCompanyName.isNotEmpty
          ? user.vendorCompanyName
          : user.department,
    );
    final formKey = GlobalKey<FormState>();
    var role = user.role;
    var active = user.active;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit account'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Enter a valid email.',
                  ),
                  TextFormField(
                    controller: organization,
                    decoration: const InputDecoration(
                      labelText: 'Department / organization',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _roles.contains(role) ? role : _roles.first,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: _roles
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.replaceAll('_', ' ')),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => role = value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Account active'),
                    value: active,
                    onChanged: (value) =>
                        setDialogState(() => active = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      try {
        await _api.updateUser(user.id, {
          'fullName': name.text.trim(),
          'email': email.text.trim(),
          'role': role,
          'department': organization.text.trim(),
          'vendorCompanyName': role == 'VENDOR'
              ? organization.text.trim()
              : null,
          'userCategory': role,
          'active': active,
        });
        await _load();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }
      }
    }
    name.dispose();
    email.dispose();
    organization.dispose();
  }

  @override
  Widget build(BuildContext context) => AdminPageScaffold(
    title: 'User accounts',
    subtitle: 'ROLE ASSIGNMENT & ACCESS',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSectionTitle('Register account'),
                const SizedBox(height: 14),
                AdminField(
                  label: 'Full name',
                  controller: _name,
                  validator: _required,
                ),
                const SizedBox(height: 10),
                AdminField(
                  label: 'University or vendor email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Enter a valid email.',
                ),
                const SizedBox(height: 10),
                AdminField(
                  label: 'Temporary password',
                  controller: _password,
                  obscureText: true,
                  validator: (value) => value != null && value.length >= 10
                      ? null
                      : 'Use at least 10 characters.',
                ),
                const SizedBox(height: 10),
                AdminField(
                  label: 'Department / organization',
                  controller: _department,
                  validator: _required,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: _decoration('Stakeholder role'),
                  items: _roles
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(
                            role.replaceAll('_', ' '),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (role) {
                    if (role != null) setState(() => _role = role);
                  },
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Account active',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    value: _active,
                    activeTrackColor: AppColors.emerald,
                    onChanged: (value) => setState(() => _active = value),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _create,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                        : const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text('Create account'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        AdminSectionTitle('Directory', trailing: '${_users.length} ACCOUNTS'),
        const SizedBox(height: 10),
        if (_loading || _error != null)
          SizedBox(
            height: 160,
            child: AdminLoadingError(
              loading: _loading,
              error: _error,
              onRetry: _load,
            ),
          ),
        if (!_loading && _error == null && _users.isEmpty)
          const AdminCard(child: Text('No user accounts yet.')),
        ..._users.map(_userTile),
      ],
    ),
  );

  Widget _userTile(AdminUser user) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE3F2EC),
            child: Text(
              user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.emerald,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${user.role.replaceAll('_', ' ')} · '
                  '${user.vendorCompanyName.isNotEmpty ? user.vendorCompanyName : user.department}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                if (user.role == 'VENDOR' && !user.active)
                  Text(
                    'INACTIVE / REVIEW',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFB45309),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Edit account',
            onPressed: () => _editUser(user),
            icon: const Icon(Icons.edit_outlined, size: 19),
          ),
          Switch.adaptive(
            value: user.active,
            activeTrackColor: AppColors.emerald,
            onChanged: (active) => _setActive(user, active),
          ),
        ],
      ),
    ),
  );

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDCE4EB)),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
}

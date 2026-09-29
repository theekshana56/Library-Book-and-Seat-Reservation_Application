import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';
import 'admin_proposal_review_screen.dart';
import 'publisher_proposal_form_screen.dart';
import 'shelf_management_screen.dart';
import 'staff_task_assignment_screen.dart';
import 'staff_task_dashboard_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = AdminApiClient();
  AdminStats? _stats;
  String? _error;
  bool _loading = true;

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
      final stats = await _api.getStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
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

  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) => AdminPageScaffold(
    title: 'Library Admin',
    subtitle: 'SYSTEM OVERVIEW',
    actions: [
      IconButton(
        onPressed: _load,
        tooltip: 'Refresh metrics',
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
                _welcomeBanner(_stats!),
                const SizedBox(height: 18),
                const AdminSectionTitle('Library at a glance'),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.68,
                  children: [
                    AdminMetricTile(
                      label: 'Registered users',
                      value: '${_stats!.totalRegisteredUsers}',
                      icon: Icons.groups_2_outlined,
                      accent: const Color(0xFF2878A5),
                    ),
                    AdminMetricTile(
                      label: 'Open staff tasks',
                      value: '${_stats!.activeStaffTasks}',
                      icon: Icons.assignment_outlined,
                      accent: const Color(0xFFB45309),
                    ),
                    AdminMetricTile(
                      label: 'Publisher offers',
                      value: '${_stats!.pendingPublisherProposals}',
                      icon: Icons.local_offer_outlined,
                      accent: const Color(0xFF8B5B2B),
                    ),
                    AdminMetricTile(
                      label: 'Shelf capacity',
                      value: '${_stats!.totalShelfCapacity}',
                      icon: Icons.shelves,
                      accent: const Color(0xFF005F4B),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const AdminSectionTitle(
                  'Workspaces',
                  trailing: 'MANAGE LIBRARY OPERATIONS',
                ),
                const SizedBox(height: 10),
                _navigationGrid(),
                const SizedBox(height: 20),
                AdminCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF005F4B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_stats!.activeUsers} accounts currently active',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const AdminStatusPill('SYSTEM LIVE'),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );

  Widget _welcomeBanner(AdminStats stats) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF0E1B2B),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BIBLIONE / ADMIN',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF5AD0B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Good morning, Administrator',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Operational overview · ${stats.activeUsers} active accounts',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFB8C7D5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(
          Icons.account_balance_rounded,
          size: 34,
          color: Color(0xFF4DB99E),
        ),
      ],
    ),
  );

  Widget _navigationGrid() {
    final items = [
      _WorkspaceItem(
        'User accounts',
        'Create and activate roles',
        Icons.manage_accounts_outlined,
        const UserManagementScreen(),
      ),
      _WorkspaceItem(
        'Publisher offers',
        'Review book proposals',
        Icons.fact_check_outlined,
        const AdminProposalReviewScreen(),
      ),
      _WorkspaceItem(
        'Staff assignments',
        'Dispatch library tasks',
        Icons.assignment_ind_outlined,
        const StaffTaskAssignmentScreen(),
      ),
      _WorkspaceItem(
        'Shelf inventory',
        'Organize capacity and zones',
        Icons.shelves,
        const ShelfManagementScreen(),
      ),
      _WorkspaceItem(
        'Vendor portal',
        'Submit offers and read responses',
        Icons.storefront_outlined,
        const PublisherProposalFormScreen(),
      ),
      _WorkspaceItem(
        'Staff task board',
        'Update shelving assignments',
        Icons.fact_check_outlined,
        const StaffTaskDashboardScreen(),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _open(item.screen),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, color: const Color(0xFF005F4B), size: 22),
                  const Spacer(),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF5B6B7C),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WorkspaceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;
  const _WorkspaceItem(this.title, this.subtitle, this.icon, this.screen);
}

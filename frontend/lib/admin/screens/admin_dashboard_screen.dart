import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';
import 'admin_proposal_review_screen.dart';
import 'book_catalog_management_screen.dart';
import 'shelf_management_screen.dart';
import 'space_management_screen.dart';
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
  List<AdminUser> _users = const [];
  List<PublisherProposal> _proposals = const [];
  List<Book> _books = const [];
  List<LibraryShelf> _shelves = const [];
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
      final results = await Future.wait<Object>([
        _api.getStats(),
        _api.getUsers(),
        _api.getProposals(),
        _api.getBooks(),
        _api.getShelves(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as AdminStats;
        _users = results[1] as List<AdminUser>;
        _proposals = results[2] as List<PublisherProposal>;
        _books = results[3] as List<Book>;
        _shelves = results[4] as List<LibraryShelf>;
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
                _chartsSection(),
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
                'Operational overview | ${stats.activeUsers} active accounts',
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
        'Book catalog',
        'Create, update and archive titles',
        Icons.menu_book_outlined,
        const BookCatalogManagementScreen(),
      ),
      _WorkspaceItem(
        'Seats & halls',
        'Register library spaces',
        Icons.event_seat_outlined,
        const SpaceManagementScreen(),
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

  Widget _chartsSection() {
    final roleCounts = <String, int>{};
    for (final user in _users) {
      roleCounts.update(user.role, (count) => count + 1, ifAbsent: () => 1);
    }

    final proposalCounts = <String, int>{};
    for (final proposal in _proposals) {
      proposalCounts.update(
        proposal.status,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final shelfValues = _shelves
        .where((shelf) => shelf.active && shelf.maxCapacity > 0)
        .take(8)
        .map(
          (shelf) => ChartValue(
            label: shelf.shelfCode,
            value: shelf.currentBookCount / shelf.maxCapacity,
            displayValue:
                '${shelf.currentBookCount}/${shelf.maxCapacity}',
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionTitle(
          'Activity insights',
          trailing: 'LIVE FROM ADMIN RECORDS',
        ),
        const SizedBox(height: 10),
        AdminChartCard(
          title: 'Users by role',
          subtitle: '${_users.length} registered accounts',
          child: DonutChart(
            values: roleCounts.entries
                .map((entry) => ChartValue(label: entry.key, value: entry.value.toDouble()))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        AdminChartCard(
          title: 'Publisher proposal pipeline',
          subtitle: '${_proposals.length} proposals received',
          child: BarChart(
            values: proposalCounts.entries
                .map((entry) => ChartValue(label: entry.key, value: entry.value.toDouble()))
                .toList(),
            color: const Color(0xFFB45309),
          ),
        ),
        if (shelfValues.isNotEmpty) ...[
          const SizedBox(height: 12),
          AdminChartCard(
            title: 'Shelf utilization',
            subtitle: 'Books stored versus maximum capacity',
            child: BarChart(
              values: shelfValues,
              color: const Color(0xFF005F4B),
              showPercent: true,
            ),
          ),
        ],
        if (_books.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_books.where((book) => book.active).length} active titles in the catalogue',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF5B6B7C),
              ),
            ),
          ),
      ],
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

class ChartValue {
  final String label;
  final double value;
  final String? displayValue;

  const ChartValue({
    required this.label,
    required this.value,
    this.displayValue,
  });
}

class DonutChart extends StatelessWidget {
  final List<ChartValue> values;

  const DonutChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No user data available')),
      );
    }
    final total = values.fold<double>(0, (sum, item) => sum + item.value);
    return Row(
      children: [
        SizedBox(
          width: 142,
          height: 142,
          child: CustomPaint(
            painter: _DonutPainter(values: values, total: total),
            child: Center(
              child: Text(
                '${total.toInt()}\nusers',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0E1B2B),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (var index = 0; index < values.length; index++)
                _ChartLegend(
                  label: values[index].label,
                  value: values[index].value.toInt().toString(),
                  color: _chartColors[index % _chartColors.length],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class BarChart extends StatelessWidget {
  final List<ChartValue> values;
  final Color color;
  final bool showPercent;

  const BarChart({
    super.key,
    required this.values,
    required this.color,
    this.showPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No data available')),
      );
    }
    final maxValue = values.fold<double>(
      0,
      (maximum, item) => item.value > maximum ? item.value : maximum,
    );
    return Column(
      children: [
        for (final item in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    item.label.replaceAll('_', ' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5B6B7C),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: (item.value / maxValue).clamp(0, 1),
                      backgroundColor: const Color(0xFFE8EEF2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: Text(
                    item.displayValue ??
                        (showPercent
                            ? '${(item.value * 100).round()}%'
                            : item.value.toInt().toString()),
                    textAlign: TextAlign.end,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0E1B2B),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ChartLegend({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        '${label.replaceAll('_', ' ')} ($value)',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5B6B7C),
        ),
      ),
    ],
  );
}

const _chartColors = [
  Color(0xFF2878A5),
  Color(0xFF005F4B),
  Color(0xFFB45309),
  Color(0xFF8B5B2B),
  Color(0xFF7C3AED),
];

class _DonutPainter extends CustomPainter {
  final List<ChartValue> values;
  final double total;

  const _DonutPainter({required this.values, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.butt;
    var start = -3.141592653589793 / 2;
    for (var index = 0; index < values.length; index++) {
      final sweep = values[index].value / total * 2 * 3.141592653589793;
      paint.color = _chartColors[index % _chartColors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 12),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.total != total;
}

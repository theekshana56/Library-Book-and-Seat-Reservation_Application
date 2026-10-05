import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../user_management/controllers/auth_controller.dart';
import '../../user_management/models/user_profile.dart';
import '../../user_management/screens/edit_profile_screen.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';
import 'publisher_proposal_form_screen.dart';

class VendorPortalScreen extends StatefulWidget {
  final AuthController authController;

  const VendorPortalScreen({super.key, required this.authController});

  @override
  State<VendorPortalScreen> createState() => _VendorPortalScreenState();
}

class _VendorPortalScreenState extends State<VendorPortalScreen> {
  final _api = AdminApiClient();
  int _selectedIndex = 0;
  List<PublisherProposal>? _proposals;
  String? _error;

  UserProfile get _user => widget.authController.currentUser!;

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    try {
      final proposals = await _api.getVendorProposals(_user.id);
      if (!mounted) return;
      setState(() {
        _proposals = proposals;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _homePage(),
              PublisherProposalFormScreen(
                vendorId: _user.id,
                apiClient: _api,
              ),
              _profilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Book offers',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _homePage() => AdminPageScaffold(
    title: 'Vendor home',
    subtitle: 'BIBLIONE PUBLISHER PORTAL',
    child: RefreshIndicator(
      onRefresh: _loadProposals,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminCard(
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
                const SizedBox(height: 6),
                Text(
                  _user.vendorCompanyName?.isNotEmpty == true
                      ? _user.vendorCompanyName!
                      : _user.email,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Submit or manage book offers'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: _loadProposals,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          else if (_proposals == null)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _ProposalCountCard(
                    label: 'Under review',
                    count: _count('PENDING_ADMIN_REVIEW'),
                    icon: Icons.hourglass_top_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProposalCountCard(
                    label: 'Approved',
                    count: _count('APPROVED'),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProposalCountCard(
                    label: 'Rejected',
                    count: _count('REJECTED'),
                    icon: Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Recent offers',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (_proposals!.isEmpty)
              const AdminCard(
                child: Text('Your submitted book offers will appear here.'),
              )
            else
              ..._proposals!.take(4).map(
                (proposal) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AdminCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        proposal.bookTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(proposal.status.replaceAll('_', ' ')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    ),
  );

  int _count(String status) =>
      _proposals?.where((proposal) => proposal.status == status).length ?? 0;

  Widget _profilePage() => AdminPageScaffold(
    title: 'Vendor profile',
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
              Text(_user.vendorCompanyName ?? 'Vendor account'),
              const Divider(height: 28),
              _ProfileDetail(label: 'Email', value: _user.email),
              _ProfileDetail(label: 'Account type', value: 'Approved vendor'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        authController: widget.authController,
                        isVendor: true,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit contact details'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
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

class _ProposalCountCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const _ProposalCountCard({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => AdminCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.emerald, size: 19),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class _ProfileDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

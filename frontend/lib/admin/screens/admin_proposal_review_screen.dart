import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../debug_agent_log.dart';
import '../../theme/app_colors.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class AdminProposalReviewScreen extends StatefulWidget {
  final AdminApiClient? apiClient;
  const AdminProposalReviewScreen({super.key, this.apiClient});

  @override
  State<AdminProposalReviewScreen> createState() =>
      _AdminProposalReviewScreenState();
}

class _AdminProposalReviewScreenState extends State<AdminProposalReviewScreen> {
  late final AdminApiClient _api;
  List<PublisherProposal> _proposals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.apiClient ?? AdminApiClient();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proposals = await _api.getProposals();
      if (!mounted) return;
      setState(() {
        _proposals = proposals;
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

  Future<void> _review(PublisherProposal proposal, bool approve) async {
    final result = await showDialog<(int?, String?)>(
      context: context,
      builder: (dialogContext) => _ProposalReviewDialog(
        approve: approve,
        maxQuantity: proposal.vendorSupplyQty,
      ),
    );
    // #region agent log
    agentDebugLog(
      location: 'admin_proposal_review_screen.dart:_review',
      message: 'dialog closed; parent does not own controllers',
      hypothesisId: 'A',
      runId: 'post-fix',
      data: {'resultNull': result == null, 'approve': approve},
    );
    // #endregion
    if (result == null) return;
    try {
      await _api.reviewProposal(
        proposal.id,
        approved: approve,
        quantity: result.$1,
        message: result.$2,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Offer approved; catalog shelving task can now be created.'
                : 'Offer rejected.',
          ),
        ),
      );
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
    title: 'Publisher offers',
    subtitle: 'PROCUREMENT REVIEW',
    actions: [
      IconButton(
        onPressed: _load,
        tooltip: 'Refresh proposals',
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
                AdminSectionTitle(
                  'Incoming proposals',
                  trailing: '${_proposals.length} TOTAL',
                ),
                const SizedBox(height: 10),
                if (_proposals.isEmpty)
                  const AdminCard(
                    child: Text('No publisher proposals to review.'),
                  ),
                ..._proposals.map(_proposalCard),
              ],
            ),
          ),
  );

  Widget _proposalCard(PublisherProposal proposal) {
    final pending = proposal.status == 'PENDING_ADMIN_REVIEW';
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEE9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: proposal.sampleCoverImageUrl.isEmpty
                      ? const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.emerald,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            proposal.sampleCoverImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.bookTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        proposal.author,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF5B6B7C),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        proposal.vendorName,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF5B6B7C),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                AdminStatusPill(proposal.status),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.mintBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                proposal.category,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.mintText,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Divider(height: 22),
            Wrap(
              spacing: 18,
              runSpacing: 6,
              children: [
                _detail(
                  'OFFER',
                  'Rs. ${proposal.proposedPrice.toStringAsFixed(2)} / copy',
                ),
                _detail('SUPPLY', '${proposal.vendorSupplyQty} copies'),
                if (proposal.isbn.isNotEmpty) _detail('ISBN', proposal.isbn),
              ],
            ),
            if (proposal.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                proposal.description,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF4B5F71),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
            if (!pending && proposal.adminMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'RESPONSE  ·  ${proposal.adminMessage}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.emerald,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (pending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _review(proposal, false),
                      icon: const Icon(Icons.close_rounded, size: 17),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9B2C2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _review(proposal, true),
                      icon: const Icon(Icons.check_rounded, size: 17),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF7C8B99),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF233547),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _ProposalReviewDialog extends StatefulWidget {
  final bool approve;
  final int maxQuantity;
  const _ProposalReviewDialog({
    required this.approve,
    required this.maxQuantity,
  });

  @override
  State<_ProposalReviewDialog> createState() => _ProposalReviewDialogState();
}

class _ProposalReviewDialogState extends State<_ProposalReviewDialog> {
  late final TextEditingController _quantity;
  late final TextEditingController _message;

  @override
  void initState() {
    super.initState();
    _quantity = TextEditingController(text: '${widget.maxQuantity}');
    _message = TextEditingController();
  }

  @override
  void dispose() {
    // #region agent log
    agentDebugLog(
      location: 'admin_proposal_review_screen.dart:dialog.dispose',
      message: 'dialog state disposing controllers',
      hypothesisId: 'A',
      runId: 'post-fix',
      data: {'controllersDisposed': true},
    );
    // #endregion
    _quantity.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.approve ? 'Approve book offer' : 'Reject book offer',
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        fontSize: 17,
      ),
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.approve) ...[
            TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Requested lot quantity',
              ),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _message,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: widget.approve
                  ? 'Confirmation message'
                  : 'Reason for rejection',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final requested = int.tryParse(_quantity.text);
          if (widget.approve &&
              (requested == null ||
                  requested < 1 ||
                  requested > widget.maxQuantity)) {
            return;
          }
          Navigator.pop(context, (requested, _message.text.trim()));
        },
        style: FilledButton.styleFrom(
          backgroundColor: widget.approve
              ? AppColors.emerald
              : const Color(0xFF9B2C2C),
        ),
        child: Text(widget.approve ? 'Approve offer' : 'Reject offer'),
      ),
    ],
  );
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../debug_agent_log.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

const _googleBooksApiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');

class PublisherProposalFormScreen extends StatefulWidget {
  final String initialVendorId;
  final AdminApiClient? apiClient;
  final http.Client? googleBooksClient;
  const PublisherProposalFormScreen({
    super.key,
    this.initialVendorId = 'seed-vendor',
    this.apiClient,
    this.googleBooksClient,
  });

  @override
  State<PublisherProposalFormScreen> createState() =>
      _PublisherProposalFormScreenState();
}

class _PublisherProposalFormScreenState
    extends State<PublisherProposalFormScreen> {
  late final AdminApiClient _api;
  late final http.Client _googleBooksClient;
  late final bool _ownsGoogleBooksClient;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vendorId;
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _isbn;
  late final TextEditingController _category;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _coverUrl;
  List<PublisherProposal> _proposals = [];
  bool _loading = true;
  bool _saving = false;
  bool _lookingUpIsbn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.apiClient ?? AdminApiClient();
    _ownsGoogleBooksClient = widget.googleBooksClient == null;
    _googleBooksClient = widget.googleBooksClient ?? http.Client();
    _vendorId = TextEditingController(text: widget.initialVendorId);
    _title = TextEditingController();
    _author = TextEditingController();
    _isbn = TextEditingController();
    _category = TextEditingController();
    _description = TextEditingController();
    _price = TextEditingController();
    _quantity = TextEditingController();
    _coverUrl = TextEditingController();
    _load(vendorId: widget.initialVendorId);
  }

  @override
  void dispose() {
    // #region agent log
    agentDebugLog(
      location: 'publisher_proposal_form_screen.dart:dispose',
      message: 'disposing publisher form controllers',
      hypothesisId: 'D',
      data: {'mounted': mounted, 'saving': _saving, 'lookingUp': _lookingUpIsbn},
    );
    // #endregion
    _vendorId.dispose();
    _title.dispose();
    _author.dispose();
    _isbn.dispose();
    _category.dispose();
    _description.dispose();
    _price.dispose();
    _quantity.dispose();
    _coverUrl.dispose();
    if (_ownsGoogleBooksClient) _googleBooksClient.close();
    super.dispose();
  }

  Future<void> _load({String? vendorId}) async {
    if (!mounted) return;
    final requestedVendorId = vendorId ?? _vendorId.text.trim();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proposals = await _api.getVendorProposals(requestedVendorId);
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

  Future<void> _submit() async {
    if (!mounted || _saving || _lookingUpIsbn) return;
    if (!_formKey.currentState!.validate()) return;
    final payload = <String, dynamic>{
      'vendorId': _vendorId.text.trim(),
      'bookTitle': _title.text.trim(),
      'author': _author.text.trim(),
      'isbn': _isbn.text.trim(),
      'category': _category.text.trim(),
      'description': _description.text.trim(),
      'proposedPrice': double.parse(_price.text),
      'vendorSupplyQty': int.parse(_quantity.text),
      'sampleCoverImageUrl': _coverUrl.text.trim(),
    };
    // #region agent log
    agentDebugLog(
      location: 'publisher_proposal_form_screen.dart:_submit',
      message: 'unfocus then submit',
      hypothesisId: 'B',
      data: {
        'mounted': mounted,
        'hasPrimaryFocus': FocusManager.instance.primaryFocus != null,
      },
    );
    // #endregion
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    try {
      await _api.submitProposal(payload);
      if (!mounted) return;
      _title.clear();
      _author.clear();
      _isbn.clear();
      _category.clear();
      _description.clear();
      _price.clear();
      _quantity.clear();
      _coverUrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer submitted for admin review.')),
      );
      await _load(vendorId: payload['vendorId'] as String);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _autoFillFromIsbn() async {
    if (!mounted || _lookingUpIsbn || _saving) return;
    final isbn = _isbn.text.trim().replaceAll(RegExp(r'[^0-9Xx]'), '');
    if (isbn.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter an ISBN first.')));
      return;
    }

    setState(() => _lookingUpIsbn = true);
    try {
      final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
        'q': 'isbn:$isbn',
        if (_googleBooksApiKey.isNotEmpty) 'key': _googleBooksApiKey,
      });
      final response = await _googleBooksClient
          .get(uri)
          .timeout(const Duration(seconds: 12));
      if (!mounted) return;
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_googleBooksFailureMessage(response))),
        );
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'];
      if (items is! List || items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Book not found in Google Books database. Please enter manually.',
            ),
          ),
        );
        return;
      }
      final firstItem = items.first;
      final volumeInfo = firstItem is Map ? firstItem['volumeInfo'] : null;
      if (volumeInfo is! Map) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Book not found in Google Books database. Please enter manually.',
            ),
          ),
        );
        return;
      }

      final title = volumeInfo['title']?.toString().trim() ?? '';
      final authors = volumeInfo['authors'];
      final author = authors is List && authors.isNotEmpty
          ? authors.first.toString().trim()
          : '';
      final categories = volumeInfo['categories'];
      final category = categories is List && categories.isNotEmpty
          ? categories.first.toString().trim()
          : '';
      final description = volumeInfo['description']?.toString().trim() ?? '';
      final imageLinks = volumeInfo['imageLinks'];
      final thumbnail = imageLinks is Map
          ? imageLinks['thumbnail']?.toString().trim() ?? ''
          : '';
      final secureThumbnail = thumbnail.replaceFirst(
        RegExp(r'^http:'),
        'https:',
      );

      if (!mounted) return;
      // #region agent log
      agentDebugLog(
        location: 'publisher_proposal_form_screen.dart:_autoFillFromIsbn',
        message: 'unfocus then write controllers',
        hypothesisId: 'B',
        data: {'mounted': mounted, 'titleLen': title.length},
      );
      // #endregion
      FocusManager.instance.primaryFocus?.unfocus();
      if (title.isNotEmpty) _title.text = title;
      if (author.isNotEmpty) _author.text = author;
      if (category.isNotEmpty) _category.text = category;
      if (description.isNotEmpty) _description.text = description;
      if (secureThumbnail.isNotEmpty) _coverUrl.text = secureThumbnail;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book details filled from Google Books.')),
      );
    } on FormatException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid response from Google Books.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to reach Google Books: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _lookingUpIsbn = false);
    }
  }

  String _googleBooksFailureMessage(http.Response response) {
    String? message;
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] is Map) {
        final error = body['error'] as Map;
        final value = error['message']?.toString().trim();
        if (value != null && value.isNotEmpty) message = value;
      }
    } on FormatException {
      // Use the HTTP status to report failures with non-JSON response bodies.
    }

    switch (response.statusCode) {
      case 400:
        return 'Google Books rejected the ISBN lookup. Check the ISBN and try again.';
      case 403:
        return 'Google Books denied the request. Check that the Books API is enabled and the API key restrictions allow this app.';
      case 429:
        return 'Google Books request limit reached. Check the API quota in Google Cloud or try again later.';
      default:
        return message == null
            ? 'Google Books lookup failed (HTTP ${response.statusCode}).'
            : 'Google Books lookup failed (HTTP ${response.statusCode}): $message';
    }
  }

  @override
  Widget build(BuildContext context) => AdminPageScaffold(
    title: 'Offer a title',
    subtitle: 'PUBLISHER & VENDOR PORTAL',
    child: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminSectionTitle('Book details'),
                  const SizedBox(height: 13),
                  AdminField(
                    label: 'Vendor account ID',
                    controller: _vendorId,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  AdminField(
                    label: 'Book title',
                    controller: _title,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  AdminField(
                    label: 'Author',
                    controller: _author,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AdminField(label: 'ISBN', controller: _isbn),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminField(
                          label: 'Category',
                          controller: _category,
                          validator: _required,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _lookingUpIsbn || _saving
                          ? null
                          : _autoFillFromIsbn,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF005F4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: _lookingUpIsbn
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 17),
                      label: Text(
                        _lookingUpIsbn
                            ? 'Looking up ISBN...'
                            : 'Auto-Fill from ISBN',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AdminField(
                    label: 'Description',
                    controller: _description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AdminField(
                          label: 'Proposed unit price (LKR / USD)',
                          controller: _price,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _positiveDecimal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminField(
                          label: 'Supply quantity',
                          controller: _quantity,
                          keyboardType: TextInputType.number,
                          validator: _positiveInteger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AdminField(
                    label: 'Sample cover image URL',
                    controller: _coverUrl,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF005F4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: _saving
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 17),
                      label: const Text('Submit Proposal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          AdminSectionTitle(
            'Your submissions',
            trailing: '${_proposals.length} OFFERS',
          ),
          const SizedBox(height: 10),
          if (_loading || _error != null)
            SizedBox(
              height: 140,
              child: AdminLoadingError(
                loading: _loading,
                error: _error,
                onRetry: _load,
              ),
            ),
          if (!_loading && _error == null && _proposals.isEmpty)
            const AdminCard(child: Text('No offers submitted yet.')),
          ..._proposals.map(_proposalTile),
        ],
      ),
    ),
  );

  Widget _proposalTile(PublisherProposal proposal) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  proposal.bookTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AdminStatusPill(proposal.status),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${proposal.author} · ${proposal.category} · ${proposal.vendorSupplyQty} copies',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF5B6B7C),
              fontSize: 11,
            ),
          ),
          if (proposal.adminMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                proposal.adminMessage,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF34495E),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;
  String? _positiveInteger(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed != null && parsed > 0
        ? null
        : 'Enter a quantity greater than zero.';
  }

  String? _positiveDecimal(String? value) {
    final parsed = double.tryParse(value ?? '');
    return parsed != null && parsed > 0
        ? null
        : 'Enter a price greater than zero.';
  }
}

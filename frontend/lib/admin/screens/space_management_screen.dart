import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../controllers/admin_api_client.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class SpaceManagementScreen extends StatefulWidget {
  const SpaceManagementScreen({super.key});

  @override
  State<SpaceManagementScreen> createState() => _SpaceManagementScreenState();
}

class _SpaceManagementScreenState extends State<SpaceManagementScreen> {
  final _api = AdminApiClient();
  final _hallFormKey = GlobalKey<FormState>();
  final _seatFormKey = GlobalKey<FormState>();
  final _hallCode = TextEditingController();
  final _hallName = TextEditingController();
  final _building = TextEditingController();
  final _floorCount = TextEditingController();
  final _description = TextEditingController();
  final _seatCode = TextEditingController();
  final _floor = TextEditingController();
  String _zone = 'Quiet Zone';
  final _acoustics = TextEditingController(text: '30');
  final _features = TextEditingController();
  List<LibraryHall> _halls = [];
  List<LibrarySeat> _seats = [];
  String? _selectedHallCode;
  String? _error;
  bool _loading = true;
  bool _saving = false;
  bool _hasPowerOutlet = false;
  int _section = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _hallCode.dispose();
    _hallName.dispose();
    _building.dispose();
    _floorCount.dispose();
    _description.dispose();
    _seatCode.dispose();
    _floor.dispose();
    _acoustics.dispose();
    _features.dispose();
    super.dispose();
  }

  Future<void> _load({String? preferredHallCode}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final halls = await _api.getHalls();
      final seats = await _api.getSeats();
      if (!mounted) return;
      setState(() {
        _halls = halls;
        _seats = seats;
        _selectedHallCode =
            preferredHallCode ??
            (halls.any((hall) => hall.hallCode == _selectedHallCode)
                ? _selectedHallCode
                : halls.firstOrNull?.hallCode);
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

  Future<void> _createHall() async {
    if (!_hallFormKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final hall = await _api.createHall({
        'hallCode': _hallCode.text.trim().toUpperCase(),
        'name': _hallName.text.trim(),
        'building': _building.text.trim(),
        'floorCount': int.parse(_floorCount.text),
        'description': _description.text.trim(),
      });
      _hallCode.clear();
      _hallName.clear();
      _building.clear();
      _floorCount.clear();
      _description.clear();
      if (!mounted) return;
      setState(() => _section = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hall.name} added. You can now add seats.')),
      );
      await _load(preferredHallCode: hall.hallCode);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _createSeat() async {
    if (!_seatFormKey.currentState!.validate()) return;
    final hallCode = _selectedHallCode;
    if (hallCode == null) return;
    setState(() => _saving = true);
    try {
      final seat = await _api.createSeat({
        'seatCode': _seatCode.text.trim().toUpperCase(),
        'hallCode': hallCode,
        'floor': _floor.text.trim(),
        'zone': _zone,
        'hasPowerOutlet': _hasPowerOutlet,
        'acousticsDb': int.parse(_acoustics.text),
        'features': _features.text
            .split(',')
            .map((feature) => feature.trim())
            .where((feature) => feature.isNotEmpty)
            .toSet()
            .toList(),
      });
      _seatCode.clear();
      _floor.clear();
      _features.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Seat ${seat.seatCode} added.')));
      await _load(preferredHallCode: hallCode);
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
    title: 'Seats & halls',
    subtitle: 'LIBRARY SPACES',
    actions: [
      IconButton(
        onPressed: _loading ? null : _load,
        tooltip: 'Refresh spaces',
        icon: const Icon(Icons.refresh_rounded),
      ),
    ],
    child: _loading || _error != null
        ? AdminLoadingError(loading: _loading, error: _error, onRetry: _load)
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionSelector(),
              const SizedBox(height: 14),
              if (_section == 0) _hallPanel() else _seatPanel(),
              const SizedBox(height: 22),
              AdminSectionTitle(
                _section == 0 ? 'Registered halls' : 'Registered seats',
                trailing: _section == 0
                    ? '${_halls.length} HALLS'
                    : '${_seats.length} SEATS',
              ),
              const SizedBox(height: 10),
              if (_section == 0)
                if (_halls.isEmpty)
                  const AdminCard(child: Text('No halls added yet.'))
                else
                  ..._halls.map(_hallCard)
              else if (_seats.isEmpty)
                const AdminCard(child: Text('No seats added yet.'))
              else
                ..._seats.map(_seatCard),
            ],
          ),
  );

  Widget _sectionSelector() => SegmentedButton<int>(
    segments: const [
      ButtonSegment(
        value: 0,
        label: Text('Halls'),
        icon: Icon(Icons.account_balance_outlined),
      ),
      ButtonSegment(
        value: 1,
        label: Text('Seats'),
        icon: Icon(Icons.event_seat_outlined),
      ),
    ],
    selected: {_section},
    onSelectionChanged: (selection) =>
        setState(() => _section = selection.first),
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textMuted,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.emerald
            : Colors.white,
      ),
    ),
  );

  Widget _hallPanel() => AdminCard(
    child: Form(
      key: _hallFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle('Add a hall'),
          const SizedBox(height: 12),
          AdminField(
            label: 'Hall code',
            controller: _hallCode,
            hint: 'NORTH',
            validator: _required,
          ),
          const SizedBox(height: 10),
          AdminField(
            label: 'Hall name',
            controller: _hallName,
            hint: 'North Library',
            validator: _required,
          ),
          const SizedBox(height: 10),
          AdminField(
            label: 'Building or campus',
            controller: _building,
            hint: 'Main Campus',
            validator: _required,
          ),
          const SizedBox(height: 10),
          AdminField(
            label: 'Number of floors',
            controller: _floorCount,
            keyboardType: TextInputType.number,
            validator: _positiveNumber,
          ),
          const SizedBox(height: 10),
          AdminField(
            label: 'Description (optional)',
            controller: _description,
            hint: 'Quiet study and reading rooms',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _createHall,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add hall'),
              style: _buttonStyle(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _seatPanel() => AdminCard(
    child: Form(
      key: _seatFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle('Add a seat'),
          const SizedBox(height: 12),
          if (_halls.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cyanAlert,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Add a hall before registering its seats.',
                style: _bodyStyle(),
              ),
            )
          else ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedHallCode,
              decoration: _dropdownDecoration('Hall'),
              items: _halls
                  .map(
                    (hall) => DropdownMenuItem(
                      value: hall.hallCode,
                      child: Text(
                        '${hall.name} Â· ${hall.hallCode}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedHallCode = value),
              validator: (value) => value == null ? 'Select a hall' : null,
            ),
            const SizedBox(height: 10),
            AdminField(
              label: 'Seat code',
              controller: _seatCode,
              hint: 'A04',
              validator: _required,
            ),
            const SizedBox(height: 10),
            AdminField(
              label: 'Floor',
              controller: _floor,
              hint: 'Level 2',
              validator: _required,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _zone,
              decoration: _dropdownDecoration('Zone'),
              items: const [
                DropdownMenuItem(
                  value: 'Quiet Zone',
                  child: Text('Quiet Zone'),
                ),
                DropdownMenuItem(
                  value: 'Social Zone',
                  child: Text('Social Zone'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _zone = value);
              },
              validator: (value) => value == null ? 'Select a zone' : null,
            ),
            const SizedBox(height: 10),
            AdminField(
              label: 'Acoustics (dB)',
              controller: _acoustics,
              keyboardType: TextInputType.number,
              validator: _nonNegativeNumber,
            ),
            const SizedBox(height: 4),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text('Power outlet available', style: _bodyStyle()),
              value: _hasPowerOutlet,
              activeTrackColor: AppColors.emerald,
              onChanged: (value) => setState(() => _hasPowerOutlet = value),
            ),
            AdminField(
              label: 'Features (comma separated)',
              controller: _features,
              hint: 'Window, adjustable desk',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving || _halls.isEmpty ? null : _createSeat,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add seat'),
                style: _buttonStyle(),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDCE4EB)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  );

  Widget _hallCard(LibraryHall hall) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: AdminCard(
      child: Row(
        children: [
          const Icon(Icons.account_balance_outlined, color: AppColors.emerald),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${hall.name} Â· ${hall.hallCode}', style: _titleStyle()),
                Text(
                  '${hall.building} Â· ${hall.floorCount} floors',
                  style: _bodyStyle(),
                ),
                if (hall.description.isNotEmpty)
                  Text(hall.description, style: _bodyStyle()),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _seatCard(LibrarySeat seat) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: AdminCard(
      child: Row(
        children: [
          const Icon(Icons.event_seat_outlined, color: AppColors.emerald),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${seat.seatCode} Â· ${seat.hallCode}',
                  style: _titleStyle(),
                ),
                Text('${seat.floor} Â· ${seat.zone}', style: _bodyStyle()),
                Text(
                  '${seat.acousticsDb} dB Â· ${seat.hasPowerOutlet ? 'Power outlet' : 'No outlet'}${seat.features.isEmpty ? '' : ' Â· ${seat.features.join(', ')}'}',
                  style: _bodyStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  ButtonStyle _buttonStyle() => FilledButton.styleFrom(
    backgroundColor: AppColors.emerald,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _positiveNumber(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number < 1
        ? 'Enter a number greater than zero'
        : null;
  }

  String? _nonNegativeNumber(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number < 0
        ? 'Enter zero or a positive number'
        : null;
  }

  TextStyle _titleStyle() => GoogleFonts.plusJakartaSans(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  TextStyle _bodyStyle() =>
      GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 11);
}

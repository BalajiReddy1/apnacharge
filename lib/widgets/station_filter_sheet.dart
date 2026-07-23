import 'package:ev_app/const/colors.dart';
import 'package:ev_app/models/station_filter.dart';
import 'package:flutter/material.dart';

/// Shows the filter sheet and returns the chosen [StationFilter], or null if
/// the user dismissed it without applying.
Future<StationFilter?> showStationFilterSheet(
  BuildContext context,
  StationFilter current,
) {
  return showModalBottomSheet<StationFilter>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _StationFilterSheet(initial: current),
  );
}

class _StationFilterSheet extends StatefulWidget {
  final StationFilter initial;
  const _StationFilterSheet({required this.initial});

  @override
  State<_StationFilterSheet> createState() => _StationFilterSheetState();
}

class _StationFilterSheetState extends State<_StationFilterSheet> {
  late Set<String> _connectors;
  late double _minPower;
  late bool _hideOutOfService;

  @override
  void initState() {
    super.initState();
    _connectors = {...widget.initial.connectors};
    _minPower = widget.initial.minPowerKW;
    _hideOutOfService = widget.initial.hideOutOfService;
  }

  void _reset() {
    setState(() {
      _connectors = {};
      _minPower = 0;
      _hideOutOfService = false;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      StationFilter(
        connectors: _connectors,
        minPowerKW: _minPower,
        hideOutOfService: _hideOutOfService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Connector type',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: StationFilter.connectorOptions.map((c) {
              final selected = _connectors.contains(c);
              return FilterChip(
                label: Text(c),
                selected: selected,
                selectedColor: AppColors.medgreen.withOpacity(0.2),
                checkmarkColor: AppColors.darkgreen,
                onSelected: (on) {
                  setState(() {
                    if (on) {
                      _connectors.add(c);
                    } else {
                      _connectors.remove(c);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Minimum power',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: StationFilter.powerOptions.entries.map((e) {
              final selected = _minPower == e.value;
              return ChoiceChip(
                label: Text(e.key),
                selected: selected,
                selectedColor: AppColors.medgreen.withOpacity(0.2),
                onSelected: (_) => setState(() => _minPower = e.value),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.medgreen,
            title: const Text('Hide out-of-service stations'),
            value: _hideOutOfService,
            onChanged: (v) => setState(() => _hideOutOfService = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              child: const Text('Apply filters'),
            ),
          ),
        ],
      ),
    );
  }
}

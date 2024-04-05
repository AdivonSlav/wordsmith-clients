import "dart:async";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/utils/reports_filter_values.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";
import "package:wordsmith_admin_panel/widgets/reports/reports_list.dart";

enum ReportType { user, ebook, app }

class ReportsScreenWidget extends StatefulWidget {
  const ReportsScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ReportsScreenWidgetState();
}

class _ReportsScreenWidgetState extends State<ReportsScreenWidget> {
  late ReportFilterValuesProvider _filterValuesProvider;

  final _reasonController = TextEditingController();
  Timer? _reasonDebounce;
  int _selectedSegment = 0;

  Widget _buildSegmentedMenu() {
    return SegmentedButton(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 0, label: Text("User reports")),
        ButtonSegment(value: 1, label: Text("Ebook reports")),
        ButtonSegment(value: 2, label: Text("App reports")),
      ],
      selected: <int>{_selectedSegment},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          _selectedSegment = newSelection.first;
        });
      },
    );
  }

  Widget _buildFilterControls() {
    var size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          children: [
            InputField(
              width: size.width * 0.2,
              labelText: "Reason",
              controller: _reasonController,
              onChanged: (value) {
                if (_reasonDebounce?.isActive ?? false) {
                  _reasonDebounce!.cancel();
                }

                _reasonDebounce = Timer(const Duration(milliseconds: 200), () {
                  _filterValuesProvider.updateFilterValueProperties(
                      reason: value);
                });
              },
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  if (_reasonController.text.isEmpty) return;
                  setState(() {
                    _reasonController.clear();
                    _filterValuesProvider.updateFilterValueProperties(
                        reason: null);
                  });
                },
              ),
            ),
            const SizedBox(width: 12.0),
            IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: () async => _pickDate(),
            ),
            const SizedBox(width: 12.0),
            Wrap(
              spacing: 5.0,
              children: [
                ChoiceChip(
                  label: const Text("Resolved"),
                  selected: _filterValuesProvider.filterValues.isClosed == true,
                  onSelected: (bool selected) {
                    setState(() {
                      _filterValuesProvider.updateFilterValueProperties(
                          isClosed: true);
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text("Unresolved"),
                  selected:
                      _filterValuesProvider.filterValues.isClosed == false,
                  onSelected: (bool selected) {
                    setState(() {
                      _filterValuesProvider.updateFilterValueProperties(
                          isClosed: false);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton.filled(
                    padding: EdgeInsets.zero,
                    onPressed: () => _filterValuesProvider
                        .updateFilterValues(_filterValuesProvider.filterValues),
                    icon: const Icon(
                      Icons.replay,
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filterValuesProvider.clearFilterValues();
                      _reasonController.clear();
                    });
                  },
                  child: const Text("Clear filters"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportList() {
    switch (_selectedSegment) {
      case 0:
        return const ReportsListWidget(type: ReportType.user);
      case 1:
        return const ReportsListWidget(type: ReportType.ebook);
      case 2:
        return const ReportsListWidget(type: ReportType.app);
      default:
        return const Placeholder();
    }
  }

  void _pickDate() async {
    var picked = await showDateRangePicker(
        context: context,
        currentDate: DateTime.now(),
        initialDateRange: _filterValuesProvider.filterValues.startDate != null
            ? DateTimeRange(
                start: _filterValuesProvider.filterValues.startDate!,
                end: _filterValuesProvider.filterValues.endDate!,
              )
            : null,
        firstDate: DateTime(2012),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450.0,
              ),
              child: child,
            ),
          );
        });

    setState(() {
      _filterValuesProvider.updateFilterValueProperties(
        startDate: picked?.start,
        endDate: picked?.end,
      );
    });
  }

  @override
  void initState() {
    _filterValuesProvider = context.read<ReportFilterValuesProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(builder: (context) => _buildSegmentedMenu()),
          const SizedBox(height: 15.0),
          Builder(builder: (context) => _buildFilterControls()),
          const SizedBox(height: 10.0),
          const Divider(),
          Expanded(
            child: Builder(
              builder: (context) => _buildReportList(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Filter Bottom Sheet Widget
///
/// Provides filtering options for analytics including:
/// - Program selection
/// - Date range picker
/// - Time period presets
/// - Question category filters
class FilterBottomSheetWidget extends StatefulWidget {
  final String selectedProgram;
  final DateTimeRange? selectedDateRange;
  final List<String> programs;
  final Function(String program, DateTimeRange dateRange) onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.selectedProgram,
    required this.selectedDateRange,
    required this.programs,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late String _selectedProgram;
  late DateTimeRange _selectedDateRange;
  String _selectedPreset = 'Custom';

  final List<String> _timePresets = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProgram = widget.selectedProgram;
    _selectedDateRange =
        widget.selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      final now = DateTime.now();

      switch (preset) {
        case 'Last 7 Days':
          _selectedDateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          );
          break;
        case 'Last 30 Days':
          _selectedDateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          );
          break;
        case 'Last 3 Months':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month - 3, now.day),
            end: now,
          );
          break;
        case 'Last 6 Months':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month - 6, now.day),
            end: now,
          );
          break;
        default:
          break;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    final theme = Theme.of(context);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedPreset = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(theme),
            _buildHeader(theme),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgramSection(theme),
                    SizedBox(height: 3.h),
                    _buildTimePresetSection(theme),
                    SizedBox(height: 3.h),
                    _buildDateRangeSection(theme),
                    SizedBox(height: 3.h),
                    _buildActionButtons(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filter Analytics', style: theme.textTheme.titleLarge),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Program', style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: widget.programs.map((program) {
            final isSelected = _selectedProgram == program;
            return FilterChip(
              label: Text(program),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedProgram = program);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimePresetSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time Period', style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        ...(_timePresets.map((preset) {
          final isSelected = _selectedPreset == preset;
          return RadioListTile<String>(
            value: preset,
            groupValue: _selectedPreset,
            onChanged: (value) {
              if (value != null) {
                if (value == 'Custom') {
                  _selectCustomDateRange();
                } else {
                  _applyPreset(value);
                }
              }
            },
            title: Text(
              preset,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            activeColor: theme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          );
        })),
      ],
    );
  }

  Widget _buildDateRangeSection(ThemeData theme) {
    final startDate = _selectedDateRange.start;
    final endDate = _selectedDateRange.end;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Date Range',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'calendar_today',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                '${startDate.month}/${startDate.day}/${startDate.year} - ${endDate.month}/${endDate.day}/${endDate.year}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(_selectedProgram, _selectedDateRange);
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}

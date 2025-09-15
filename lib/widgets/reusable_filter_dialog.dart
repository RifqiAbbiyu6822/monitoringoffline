import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme_constants.dart';

class ReusableFilterDialog extends StatefulWidget {
  final String filterJalur;
  final String filterLajur;
  final DateTime? filterDateFrom;
  final DateTime? filterDateTo;
  final Function(String, String, DateTime?, DateTime?) onApply;
  final VoidCallback onReset;

  const ReusableFilterDialog({
    super.key,
    required this.filterJalur,
    required this.filterLajur,
    required this.filterDateFrom,
    required this.filterDateTo,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ReusableFilterDialog> createState() => _ReusableFilterDialogState();
}

class _ReusableFilterDialogState extends State<ReusableFilterDialog> {
  late String _filterJalur;
  late String _filterLajur;
  late DateTime? _filterDateFrom;
  late DateTime? _filterDateTo;

  @override
  void initState() {
    super.initState();
    _filterJalur = widget.filterJalur;
    _filterLajur = widget.filterLajur;
    _filterDateFrom = widget.filterDateFrom;
    _filterDateTo = widget.filterDateTo;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeConstants.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
      ),
      title: const Text(
        'Filter Data',
        style: ThemeConstants.heading3,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Jalur Filter
            DropdownButtonFormField<String>(
              value: _filterJalur,
              decoration: ThemeConstants.inputDecoration('Jalur'),
              items: ['Semua', 'Jalur A', 'Jalur B'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: ThemeConstants.bodyMedium),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filterJalur = value!;
                });
              },
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Lajur Filter
            DropdownButtonFormField<String>(
              value: _filterLajur,
              decoration: ThemeConstants.inputDecoration('Lajur'),
              items: ['Semua', 'Lajur 1', 'Lajur 2', 'Bahu Dalam', 'Bahu Luar'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: ThemeConstants.bodyMedium),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filterLajur = value!;
                });
              },
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Date From
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _filterDateFrom ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _filterDateFrom = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.spacingM),
                decoration: BoxDecoration(
                  border: Border.all(color: ThemeConstants.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  color: ThemeConstants.backgroundWhite,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: ThemeConstants.primary.withOpacity(0.7)),
                    const SizedBox(width: ThemeConstants.spacingM),
                    Text(
                      _filterDateFrom != null
                          ? DateFormat('dd MMM yyyy').format(_filterDateFrom!)
                          : 'Tanggal Dari',
                      style: ThemeConstants.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Date To
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _filterDateTo ?? DateTime.now(),
                  firstDate: _filterDateFrom ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _filterDateTo = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.spacingM),
                decoration: BoxDecoration(
                  border: Border.all(color: ThemeConstants.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  color: ThemeConstants.backgroundWhite,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: ThemeConstants.primary.withOpacity(0.7)),
                    const SizedBox(width: ThemeConstants.spacingM),
                    Text(
                      _filterDateTo != null
                          ? DateFormat('dd MMM yyyy').format(_filterDateTo!)
                          : 'Tanggal Sampai',
                      style: ThemeConstants.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onReset();
            Navigator.of(context).pop();
          },
          child: Text(
            'Reset',
            style: TextStyle(color: ThemeConstants.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_filterJalur, _filterLajur, _filterDateFrom, _filterDateTo);
            Navigator.of(context).pop();
          },
          style: ThemeConstants.primaryButtonStyle,
          child: const Text('Terapkan'),
        ),
      ],
    );
  }
}

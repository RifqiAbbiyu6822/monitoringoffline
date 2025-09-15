import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class ReusableSortDialog extends StatefulWidget {
  final String sortBy;
  final bool sortAscending;
  final bool isPerbaikanTab;
  final Function(String, bool) onApply;

  const ReusableSortDialog({
    super.key,
    required this.sortBy,
    required this.sortAscending,
    required this.isPerbaikanTab,
    required this.onApply,
  });

  @override
  State<ReusableSortDialog> createState() => _ReusableSortDialogState();
}

class _ReusableSortDialogState extends State<ReusableSortDialog> {
  late String _sortBy;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.sortBy;
    _sortAscending = widget.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeConstants.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
      ),
      title: const Text(
        'Urutkan Data',
        style: ThemeConstants.heading3,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('Tanggal', style: ThemeConstants.bodyMedium),
            value: 'tanggal',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
            activeColor: ThemeConstants.primary,
          ),
          RadioListTile<String>(
            title: const Text('Jenis', style: ThemeConstants.bodyMedium),
            value: 'jenis',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
            activeColor: ThemeConstants.primary,
          ),
          RadioListTile<String>(
            title: const Text('Jalur', style: ThemeConstants.bodyMedium),
            value: 'jalur',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
            activeColor: ThemeConstants.primary,
          ),
          RadioListTile<String>(
            title: const Text('Lajur', style: ThemeConstants.bodyMedium),
            value: 'lajur',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
            activeColor: ThemeConstants.primary,
          ),
          RadioListTile<String>(
            title: const Text('Kilometer', style: ThemeConstants.bodyMedium),
            value: 'kilometer',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
            activeColor: ThemeConstants.primary,
          ),
          if (widget.isPerbaikanTab) // Perbaikan tab
            RadioListTile<String>(
              title: const Text('Status', style: ThemeConstants.bodyMedium),
              value: 'status',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
          const Divider(),
          SwitchListTile(
            title: const Text('Urutan Naik', style: ThemeConstants.bodyMedium),
            value: _sortAscending,
            onChanged: (value) {
              setState(() {
                _sortAscending = value;
              });
            },
            activeColor: ThemeConstants.primary,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Batal',
            style: TextStyle(color: ThemeConstants.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_sortBy, _sortAscending);
            Navigator.of(context).pop();
          },
          style: ThemeConstants.primaryButtonStyle,
          child: const Text('Terapkan'),
        ),
      ],
    );
  }
}

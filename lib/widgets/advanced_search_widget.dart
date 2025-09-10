import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/date_utils.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function({
    String? searchQuery,
    String? jalur,
    String? lajur,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortBy,
    bool? sortAscending,
  }) onSearchChanged;

  const AdvancedSearchWidget({
    super.key,
    required this.onSearchChanged,
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterJalur = 'Semua';
  String _filterLajur = 'Semua';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  String _sortBy = 'tanggal';
  bool _sortAscending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    widget.onSearchChanged(
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      jalur: _filterJalur == 'Semua' ? null : _filterJalur,
      lajur: _filterLajur == 'Semua' ? null : _filterLajur,
      dateFrom: _filterDateFrom,
      dateTo: _filterDateTo,
      sortBy: _sortBy,
      sortAscending: _sortAscending,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _filterJalur = 'Semua';
      _filterLajur = 'Semua';
      _filterDateFrom = null;
      _filterDateTo = null;
      _sortBy = 'tanggal';
      _sortAscending = false;
    });
    _searchController.clear();
    _applySearch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Pencarian & Filter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan jenis, deskripsi, jalur, lajur, atau kilometer...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _applySearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applySearch();
            },
          ),
          const SizedBox(height: 16),
          
          // Filter Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterJalur,
                  decoration: const InputDecoration(
                    labelText: 'Jalur',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Semua', ...AppConstants.jalurOptions].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterJalur = value!;
                    });
                    _applySearch();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterLajur,
                  decoration: const InputDecoration(
                    labelText: 'Lajur',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Semua', ...AppConstants.lajurOptions].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterLajur = value!;
                    });
                    _applySearch();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date Range
          Row(
            children: [
              Expanded(
                child: InkWell(
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
                      _applySearch();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _filterDateFrom != null
                                ? AppDateUtils.formatDisplayDate(_filterDateFrom!)
                                : 'Tanggal Dari',
                            style: TextStyle(
                              color: _filterDateFrom != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (_filterDateFrom != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              setState(() {
                                _filterDateFrom = null;
                              });
                              _applySearch();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
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
                      _applySearch();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _filterDateTo != null
                                ? AppDateUtils.formatDisplayDate(_filterDateTo!)
                                : 'Tanggal Sampai',
                            style: TextStyle(
                              color: _filterDateTo != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (_filterDateTo != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              setState(() {
                                _filterDateTo = null;
                              });
                              _applySearch();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sort Options
          Row(
            children: [
              const Icon(Icons.sort, size: 16),
              const SizedBox(width: 8),
              const Text('Urutkan berdasarkan:'),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'tanggal', child: Text('Tanggal')),
                    DropdownMenuItem(value: 'jalur', child: Text('Jalur')),
                    DropdownMenuItem(value: 'lajur', child: Text('Lajur')),
                    DropdownMenuItem(value: 'kilometer', child: Text('Kilometer')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _applySearch();
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                  _applySearch();
                },
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                tooltip: _sortAscending ? 'Urutan Naik' : 'Urutan Turun',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

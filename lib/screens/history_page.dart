import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../database/database_helper.dart';
import '../utils/error_handler.dart';
import '../widgets/export_dialog.dart';
import '../widgets/pdf_config_dialog.dart';
import '../services/pdf_service.dart';
import '../constants/theme_constants.dart';
import 'date_history_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Temuan> _temuanList = [];
  List<Perbaikan> _perbaikanList = [];
  List<Temuan> _filteredTemuanList = [];
  List<Perbaikan> _filteredPerbaikanList = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'tanggal';
  bool _sortAscending = false;
  String _filterJalur = 'Semua';
  String _filterLajur = 'Semua';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final temuanList = await DatabaseHelper().getAllTemuan();
      final perbaikanList = await DatabaseHelper().getAllPerbaikan();
      
      setState(() {
        _temuanList = temuanList;
        _perbaikanList = perbaikanList;
        _applyFilters();
      });
    } catch (e) {
      ErrorHandler.handleError(context, e, customMessage: 'Gagal memuat data history');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Group data by date
  Map<String, List<Temuan>> _groupTemuanByDate(List<Temuan> temuanList) {
    Map<String, List<Temuan>> grouped = {};
    for (var temuan in temuanList) {
      String dateKey = DateFormat('yyyy-MM-dd').format(temuan.tanggal);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(temuan);
    }
    return grouped;
  }

  Map<String, List<Perbaikan>> _groupPerbaikanByDate(List<Perbaikan> perbaikanList) {
    Map<String, List<Perbaikan>> grouped = {};
    for (var perbaikan in perbaikanList) {
      String dateKey = DateFormat('yyyy-MM-dd').format(perbaikan.tanggal);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(perbaikan);
    }
    return grouped;
  }

  void _applyFilters() {
    List<Temuan> filteredTemuan = List.from(_temuanList);
    List<Perbaikan> filteredPerbaikan = List.from(_perbaikanList);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredTemuan = filteredTemuan.where((temuan) {
        return temuan.jenisTemuan.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               temuan.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               temuan.jalur.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               temuan.lajur.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               temuan.kilometer.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      filteredPerbaikan = filteredPerbaikan.where((perbaikan) {
        return perbaikan.jenisPerbaikan.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               perbaikan.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               perbaikan.jalur.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               perbaikan.lajur.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               perbaikan.kilometer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               perbaikan.statusPerbaikan.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply jalur filter
    if (_filterJalur != 'Semua') {
      filteredTemuan = filteredTemuan.where((temuan) => temuan.jalur == _filterJalur).toList();
      filteredPerbaikan = filteredPerbaikan.where((perbaikan) => perbaikan.jalur == _filterJalur).toList();
    }

    // Apply lajur filter
    if (_filterLajur != 'Semua') {
      filteredTemuan = filteredTemuan.where((temuan) => temuan.lajur == _filterLajur).toList();
      filteredPerbaikan = filteredPerbaikan.where((perbaikan) => perbaikan.lajur == _filterLajur).toList();
    }

    // Apply date range filter
    if (_filterDateFrom != null) {
      filteredTemuan = filteredTemuan.where((temuan) => 
        temuan.tanggal.isAfter(_filterDateFrom!) || temuan.tanggal.isAtSameMomentAs(_filterDateFrom!)).toList();
      filteredPerbaikan = filteredPerbaikan.where((perbaikan) => 
        perbaikan.tanggal.isAfter(_filterDateFrom!) || perbaikan.tanggal.isAtSameMomentAs(_filterDateFrom!)).toList();
    }

    if (_filterDateTo != null) {
      filteredTemuan = filteredTemuan.where((temuan) => 
        temuan.tanggal.isBefore(_filterDateTo!) || temuan.tanggal.isAtSameMomentAs(_filterDateTo!)).toList();
      filteredPerbaikan = filteredPerbaikan.where((perbaikan) => 
        perbaikan.tanggal.isBefore(_filterDateTo!) || perbaikan.tanggal.isAtSameMomentAs(_filterDateTo!)).toList();
    }

    // Apply sorting
    filteredTemuan.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'tanggal':
          comparison = a.tanggal.compareTo(b.tanggal);
          break;
        case 'jenis':
          comparison = a.jenisTemuan.compareTo(b.jenisTemuan);
          break;
        case 'jalur':
          comparison = a.jalur.compareTo(b.jalur);
          break;
        case 'lajur':
          comparison = a.lajur.compareTo(b.lajur);
          break;
        case 'kilometer':
          comparison = a.kilometer.compareTo(b.kilometer);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    filteredPerbaikan.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'tanggal':
          comparison = a.tanggal.compareTo(b.tanggal);
          break;
        case 'jenis':
          comparison = a.jenisPerbaikan.compareTo(b.jenisPerbaikan);
          break;
        case 'jalur':
          comparison = a.jalur.compareTo(b.jalur);
          break;
        case 'lajur':
          comparison = a.lajur.compareTo(b.lajur);
          break;
        case 'kilometer':
          comparison = a.kilometer.compareTo(b.kilometer);
          break;
        case 'status':
          comparison = a.statusPerbaikan.compareTo(b.statusPerbaikan);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredTemuanList = filteredTemuan;
      _filteredPerbaikanList = filteredPerbaikan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/logoJJCWhite.png',
                height: 24,
                width: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'History Data',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ThemeConstants.backgroundWhite,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          backgroundColor: ThemeConstants.primaryBlue,
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: ThemeConstants.backgroundWhite),
              onPressed: _exportToPdf,
              tooltip: 'Export PDF',
            ),
            IconButton(
              icon: const Icon(Icons.file_download, color: ThemeConstants.backgroundWhite),
              onPressed: _showExportDialog,
              tooltip: 'Export Data',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: ThemeConstants.backgroundWhite),
              onPressed: _showFilterDialog,
              tooltip: 'Filter',
            ),
            IconButton(
              icon: const Icon(Icons.sort, color: ThemeConstants.backgroundWhite),
              onPressed: _showSortDialog,
              tooltip: 'Sort',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: ThemeConstants.backgroundWhite,
            indicatorWeight: 3,
            labelColor: ThemeConstants.backgroundWhite,
            unselectedLabelColor: ThemeConstants.backgroundWhite.withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Temuan'),
              Tab(text: 'Perbaikan'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            color: ThemeConstants.surfaceGrey,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Cari data...',
                hintStyle: TextStyle(color: ThemeConstants.textSecondary),
                prefixIcon: Icon(Icons.search, color: ThemeConstants.primaryBlue),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: ThemeConstants.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  borderSide: BorderSide(color: ThemeConstants.primaryBlue.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  borderSide: BorderSide(color: ThemeConstants.primaryBlue.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  borderSide: const BorderSide(color: ThemeConstants.primaryBlue, width: 2),
                ),
                filled: true,
                fillColor: ThemeConstants.backgroundWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingM),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemuanList(),
                _buildPerbaikanList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemuanList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConstants.primaryBlue),
      );
    }

    if (_filteredTemuanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: ThemeConstants.textSecondary,
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            Text(
              _searchQuery.isNotEmpty || _filterJalur != 'Semua' || _filterLajur != 'Semua' || _filterDateFrom != null || _filterDateTo != null
                  ? 'Tidak ada data yang sesuai dengan filter'
                  : 'Belum ada data temuan',
              style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group temuan by date
    final groupedTemuan = _groupTemuanByDate(_filteredTemuanList);
    final sortedDates = groupedTemuan.keys.toList()..sort((a, b) => b.compareTo(a)); // Sort descending

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final temuanList = groupedTemuan[dateKey]!;
        final date = DateTime.parse(dateKey);
        
        return _buildDateCard(date, temuanList.length, 'temuan');
      },
    );
  }

  Widget _buildPerbaikanList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConstants.primaryBlue),
      );
    }

    if (_filteredPerbaikanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: ThemeConstants.textSecondary,
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            Text(
              _searchQuery.isNotEmpty || _filterJalur != 'Semua' || _filterLajur != 'Semua' || _filterDateFrom != null || _filterDateTo != null
                  ? 'Tidak ada data yang sesuai dengan filter'
                  : 'Belum ada data perbaikan',
              style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group perbaikan by date
    final groupedPerbaikan = _groupPerbaikanByDate(_filteredPerbaikanList);
    final sortedDates = groupedPerbaikan.keys.toList()..sort((a, b) => b.compareTo(a)); // Sort descending

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final perbaikanList = groupedPerbaikan[dateKey]!;
        final date = DateTime.parse(dateKey);
        
        return _buildDateCard(date, perbaikanList.length, 'perbaikan');
      },
    );
  }

  Widget _buildDateCard(DateTime date, int count, String type) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isYesterday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
    
    String dateText;
    if (isToday) {
      dateText = 'Hari Ini';
    } else if (isYesterday) {
      dateText = 'Kemarin';
    } else {
      dateText = dateFormat.format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: ThemeConstants.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DateHistoryPage(
                  selectedDate: date,
                  type: type,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacingM),
                  decoration: BoxDecoration(
                    color: type == 'temuan' 
                        ? ThemeConstants.primaryBlue.withOpacity(0.1)
                        : ThemeConstants.secondaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  ),
                  child: Icon(
                    type == 'temuan' ? Icons.search_outlined : Icons.build_outlined,
                    color: type == 'temuan' ? ThemeConstants.primaryBlue : ThemeConstants.secondaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: type == 'temuan' ? ThemeConstants.primaryBlue : ThemeConstants.secondaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count ${type == 'temuan' ? 'temuan' : 'perbaikan'} ditemukan',
                        style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: type == 'temuan' ? ThemeConstants.primaryBlue : ThemeConstants.secondaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacingS),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: ThemeConstants.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        temuanList: _filteredTemuanList,
        perbaikanList: _filteredPerbaikanList,
      ),
    );
  }

  Future<void> _exportToPdf() async {
    final config = await showDialog<pdf_config.PdfConfig>(
      context: context,
      builder: (context) => const PdfConfigDialog(),
    );

    if (config != null) {
      try {
        // Buat informasi tanggal dan filter
        final dateRange = _getDateRangeInfo();
        final filterInfo = _getFilterInfo();
        
        // Export data sesuai dengan tab yang sedang aktif
        if (_tabController.index == 0) {
          // Tab Temuan
          if (_filteredTemuanList.isNotEmpty) {
            await PdfService().generateTemuanPdf(_filteredTemuanList, config, dateRange: dateRange, filterInfo: filterInfo);
          } else {
            _showNoDataMessage('Tidak ada data temuan untuk diekspor');
            return;
          }
        } else {
          // Tab Perbaikan
          if (_filteredPerbaikanList.isNotEmpty) {
            await PdfService().generatePerbaikanPdf(_filteredPerbaikanList, config, dateRange: dateRange, filterInfo: filterInfo);
          } else {
            _showNoDataMessage('Tidak ada data perbaikan untuk diekspor');
            return;
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF berhasil diekspor'),
              backgroundColor: ThemeConstants.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(ThemeConstants.radiusM)),
              ),
            ),
          );
        }
      } catch (e) {
        ErrorHandler.handleError(context, e, customMessage: 'Gagal membuat PDF');
      }
    }
  }

  String? _getDateRangeInfo() {
    if (_tabController.index == 0) {
      // Tab Temuan
      if (_filteredTemuanList.isEmpty) return null;
      final dates = _filteredTemuanList.map((item) => item.tanggal).toList();
      dates.sort();
      
      final startDate = DateFormat('dd/MM/yyyy').format(dates.first);
      final endDate = DateFormat('dd/MM/yyyy').format(dates.last);
      
      if (startDate == endDate) {
        return startDate;
      } else {
        return '$startDate - $endDate';
      }
    } else {
      // Tab Perbaikan
      if (_filteredPerbaikanList.isEmpty) return null;
      final dates = _filteredPerbaikanList.map((item) => item.tanggal).toList();
      dates.sort();
      
      final startDate = DateFormat('dd/MM/yyyy').format(dates.first);
      final endDate = DateFormat('dd/MM/yyyy').format(dates.last);
      
      if (startDate == endDate) {
        return startDate;
      } else {
        return '$startDate - $endDate';
      }
    }
  }

  String? _getFilterInfo() {
    final List<String> filters = [];
    
    if (_searchQuery.isNotEmpty) {
      filters.add('Pencarian: "$_searchQuery"');
    }
    
    if (_sortBy != 'tanggal') {
      filters.add('Urutkan: $_sortBy');
    }
    
    if (!_sortAscending) {
      filters.add('Urutan: Menurun');
    }
    
    return filters.isNotEmpty ? filters.join(', ') : null;
  }

  void _showNoDataMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.warningOrange,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ThemeConstants.radiusM)),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                    border: Border.all(color: ThemeConstants.primaryBlue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                    color: ThemeConstants.backgroundWhite,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: ThemeConstants.primaryBlue.withOpacity(0.7)),
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
                    border: Border.all(color: ThemeConstants.primaryBlue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                    color: ThemeConstants.backgroundWhite,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: ThemeConstants.primaryBlue.withOpacity(0.7)),
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
              setState(() {
                _filterJalur = 'Semua';
                _filterLajur = 'Semua';
                _filterDateFrom = null;
                _filterDateTo = null;
              });
              _applyFilters();
              Navigator.of(context).pop();
            },
            child: Text(
              'Reset',
              style: TextStyle(color: ThemeConstants.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.of(context).pop();
            },
            style: ThemeConstants.primaryButtonStyle,
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              activeColor: ThemeConstants.primaryBlue,
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
              activeColor: ThemeConstants.primaryBlue,
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
              activeColor: ThemeConstants.primaryBlue,
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
              activeColor: ThemeConstants.primaryBlue,
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
              activeColor: ThemeConstants.primaryBlue,
            ),
            if (_tabController.index == 1) // Perbaikan tab
              RadioListTile<String>(
                title: const Text('Status', style: ThemeConstants.bodyMedium),
                value: 'status',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
                activeColor: ThemeConstants.primaryBlue,
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
              activeColor: ThemeConstants.primaryBlue,
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
              _applyFilters();
              Navigator.of(context).pop();
            },
            style: ThemeConstants.primaryButtonStyle,
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}
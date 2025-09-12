import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/perbaikan.dart';
import '../database/database_helper.dart';
import '../utils/error_handler.dart';
import '../constants/theme_constants.dart';

class DetailHistoryPage extends StatefulWidget {
  final String type;
  final int id;

  const DetailHistoryPage({
    super.key,
    required this.type,
    required this.id,
  });

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  dynamic _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (widget.type == 'temuan') {
        final temuanList = await DatabaseHelper().getAllTemuan();
        _data = temuanList.firstWhere((temuan) => temuan.id == widget.id);
      } else {
        final perbaikanList = await DatabaseHelper().getAllPerbaikan();
        _data = perbaikanList.firstWhere((perbaikan) => perbaikan.id == widget.id);
      }
    } catch (e) {
      ErrorHandler.handleError(context, e, customMessage: 'Gagal memuat detail data');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteData() async {
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      title: 'Konfirmasi Hapus',
      message: 'Apakah Anda yakin ingin menghapus data ini?',
    );

    if (confirmed == true) {
      try {
        if (widget.type == 'temuan') {
          await DatabaseHelper().deleteTemuan(widget.id);
        } else {
          await DatabaseHelper().deletePerbaikan(widget.id);
        }

        ErrorHandler.showSuccessSnackBar(context, 'Data berhasil dihapus');
        Navigator.pop(context, true); // Return true to indicate deletion
      } catch (e) {
        ErrorHandler.handleError(context, e, customMessage: 'Gagal menghapus data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundWhite,
      appBar: AppBar(
        backgroundColor: widget.type == 'temuan' ? ThemeConstants.primary : ThemeConstants.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading && _data != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteData();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: ThemeConstants.errorRed),
                      SizedBox(width: ThemeConstants.spacingS),
                      Text('Hapus Data', style: TextStyle(color: ThemeConstants.errorRed)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              'Detail ${widget.type == 'temuan' ? 'Temuan' : 'Perbaikan'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        'Memuat data...',
                        style: TextStyle(color: ThemeConstants.textSecondary),
                      ),
                    ],
                  ),
                )
              : _data == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: ThemeConstants.textSecondary,
                          ),
                          const SizedBox(height: ThemeConstants.spacingM),
                          Text(
                            'Data tidak ditemukan',
                            style: ThemeConstants.heading3.copyWith(color: ThemeConstants.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(ThemeConstants.spacingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Card
                            _buildHeaderCard(),
                            
                            const SizedBox(height: ThemeConstants.spacingL),
                            
                            // Info Card
                            _buildInfoCard(),
                            
                            const SizedBox(height: ThemeConstants.spacingL),
                            
                            // Location Card
                            _buildLocationCard(),
                            
                            const SizedBox(height: ThemeConstants.spacingL),
                            
                            // Description Card
                            _buildDescriptionCard(),
                            
                            if (_data.fotoPath != null) ...[
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Photo Card
                              _buildPhotoCard(),
                            ],
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.cardDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingL),
            decoration: BoxDecoration(
              color: widget.type == 'temuan' 
                  ? ThemeConstants.primary.withOpacity(0.1)
                  : ThemeConstants.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
            ),
            child: Icon(
              widget.type == 'temuan' ? Icons.search_outlined : Icons.build_outlined,
              size: 48,
              color: widget.type == 'temuan' ? ThemeConstants.primary : ThemeConstants.secondary,
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          Text(
            widget.type == 'temuan' ? _data.jenisTemuan : _data.jenisPerbaikan,
            style: ThemeConstants.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.spacingXS),
          Text(
            DateFormat('dd MMMM yyyy').format(_data.tanggal),
            style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Detail',
            style: ThemeConstants.heading3,
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          _buildInfoRow('Jalur', _data.jalur, Icons.route),
          _buildInfoRow('Lajur', _data.lajur, Icons.straighten),
          _buildInfoRow('Kilometer', 'KM ${_data.kilometer}', Icons.speed),
          if (widget.type == 'perbaikan')
            _buildInfoRow('Status', (_data as Perbaikan).statusPerbaikan, Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Koordinat GPS',
            style: ThemeConstants.heading3,
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          _buildInfoRow('Latitude', _data.latitude, Icons.my_location),
          _buildInfoRow('Longitude', _data.longitude, Icons.my_location),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: ThemeConstants.heading3,
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            decoration: BoxDecoration(
              color: ThemeConstants.surfaceGrey,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
            child: Text(
              _data.deskripsi,
              style: ThemeConstants.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto ${widget.type == 'temuan' ? 'Temuan' : 'Perbaikan'}',
            style: ThemeConstants.heading3,
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              border: Border.all(
                color: widget.type == 'temuan' 
                    ? ThemeConstants.primary.withOpacity(0.3)
                    : ThemeConstants.secondary.withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              child: Image.file(
                File(_data.fotoPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: ThemeConstants.surfaceGrey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: ThemeConstants.textSecondary,
                        ),
                        const SizedBox(height: ThemeConstants.spacingS),
                        Text(
                          'Gagal memuat gambar',
                          style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingS),
            decoration: BoxDecoration(
              color: widget.type == 'temuan' 
                  ? ThemeConstants.primary.withOpacity(0.1)
                  : ThemeConstants.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
            ),
            child: Icon(
              icon,
              size: 20,
              color: widget.type == 'temuan' ? ThemeConstants.primary : ThemeConstants.secondary,
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ThemeConstants.bodySmall.copyWith(color: ThemeConstants.textSecondary),
                ),
                Text(
                  value,
                  style: ThemeConstants.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
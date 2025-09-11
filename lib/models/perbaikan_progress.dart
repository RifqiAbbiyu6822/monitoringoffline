class PerbaikanProgress {
  final int? id;
  final int perbaikanId; // ID dari perbaikan utama
  final DateTime tanggal;
  final String statusProgress; // 0%, 25%, 50%, 75%, 100%
  final String deskripsiProgress;
  final String? fotoPath;
  final String latitude;
  final String longitude;

  const PerbaikanProgress({
    this.id,
    required this.perbaikanId,
    required this.tanggal,
    required this.statusProgress,
    required this.deskripsiProgress,
    this.fotoPath,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'perbaikan_id': perbaikanId,
      'tanggal': tanggal.millisecondsSinceEpoch,
      'status_progress': statusProgress,
      'deskripsi_progress': deskripsiProgress,
      'foto_path': fotoPath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PerbaikanProgress.fromMap(Map<String, dynamic> map) {
    return PerbaikanProgress(
      id: map['id'],
      perbaikanId: map['perbaikan_id'],
      tanggal: DateTime.fromMillisecondsSinceEpoch(map['tanggal']),
      statusProgress: map['status_progress'],
      deskripsiProgress: map['deskripsi_progress'],
      fotoPath: map['foto_path'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  PerbaikanProgress copyWith({
    int? id,
    int? perbaikanId,
    DateTime? tanggal,
    String? statusProgress,
    String? deskripsiProgress,
    String? fotoPath,
    String? latitude,
    String? longitude,
  }) {
    return PerbaikanProgress(
      id: id ?? this.id,
      perbaikanId: perbaikanId ?? this.perbaikanId,
      tanggal: tanggal ?? this.tanggal,
      statusProgress: statusProgress ?? this.statusProgress,
      deskripsiProgress: deskripsiProgress ?? this.deskripsiProgress,
      fotoPath: fotoPath ?? this.fotoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'PerbaikanProgress(id: $id, perbaikanId: $perbaikanId, tanggal: $tanggal, '
        'statusProgress: $statusProgress, deskripsiProgress: $deskripsiProgress, '
        'fotoPath: $fotoPath, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerbaikanProgress &&
        other.id == id &&
        other.perbaikanId == perbaikanId &&
        other.tanggal == tanggal &&
        other.statusProgress == statusProgress &&
        other.deskripsiProgress == deskripsiProgress &&
        other.fotoPath == fotoPath &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      perbaikanId,
      tanggal,
      statusProgress,
      deskripsiProgress,
      fotoPath,
      latitude,
      longitude,
    );
  }
}

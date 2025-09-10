class Perbaikan {
  final int? id;
  final DateTime tanggal;
  final String jenisPerbaikan;
  final String jalur;
  final String lajur;
  final String kilometer;
  final String latitude;
  final String longitude;
  final String deskripsi;
  final String statusPerbaikan;
  final String? fotoPath;

  Perbaikan({
    this.id,
    required this.tanggal,
    required this.jenisPerbaikan,
    required this.jalur,
    required this.lajur,
    required this.kilometer,
    required this.latitude,
    required this.longitude,
    required this.deskripsi,
    required this.statusPerbaikan,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.millisecondsSinceEpoch,
      'jenis_perbaikan': jenisPerbaikan,
      'jalur': jalur,
      'lajur': lajur,
      'kilometer': kilometer,
      'latitude': latitude,
      'longitude': longitude,
      'deskripsi': deskripsi,
      'status_perbaikan': statusPerbaikan,
      'foto_path': fotoPath,
    };
  }

  factory Perbaikan.fromMap(Map<String, dynamic> map) {
    return Perbaikan(
      id: map['id'],
      tanggal: DateTime.fromMillisecondsSinceEpoch(map['tanggal']),
      jenisPerbaikan: map['jenis_perbaikan'],
      jalur: map['jalur'],
      lajur: map['lajur'],
      kilometer: map['kilometer'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      deskripsi: map['deskripsi'],
      statusPerbaikan: map['status_perbaikan'],
      fotoPath: map['foto_path'],
    );
  }

  Perbaikan copyWith({
    int? id,
    DateTime? tanggal,
    String? jenisPerbaikan,
    String? jalur,
    String? lajur,
    String? kilometer,
    String? latitude,
    String? longitude,
    String? deskripsi,
    String? statusPerbaikan,
    String? fotoPath,
  }) {
    return Perbaikan(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      jenisPerbaikan: jenisPerbaikan ?? this.jenisPerbaikan,
      jalur: jalur ?? this.jalur,
      lajur: lajur ?? this.lajur,
      kilometer: kilometer ?? this.kilometer,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deskripsi: deskripsi ?? this.deskripsi,
      statusPerbaikan: statusPerbaikan ?? this.statusPerbaikan,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }
}

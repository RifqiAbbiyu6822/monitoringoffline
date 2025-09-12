class Perbaikan {
  final int? id;
  final DateTime tanggal;
  final String objectId;
  final String jenisPerbaikan;
  final String jalur;
  final String lajur;
  final String kilometer;
  final String latitude;
  final String longitude;
  final String deskripsi;
  final String statusPerbaikan;
  final String? fotoPath;

  const Perbaikan({
    this.id,
    required this.tanggal,
    required this.objectId,
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
      'object_id': objectId,
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
      objectId: map['object_id'],
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
    String? objectId,
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
      objectId: objectId ?? this.objectId,
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

  @override
  String toString() {
    return 'Perbaikan(id: $id, tanggal: $tanggal, objectId: $objectId, jenisPerbaikan: $jenisPerbaikan, '
        'jalur: $jalur, lajur: $lajur, kilometer: $kilometer, '
        'latitude: $latitude, longitude: $longitude, deskripsi: $deskripsi, '
        'statusPerbaikan: $statusPerbaikan, fotoPath: $fotoPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Perbaikan &&
        other.id == id &&
        other.tanggal == tanggal &&
        other.jenisPerbaikan == jenisPerbaikan &&
        other.jalur == jalur &&
        other.lajur == lajur &&
        other.kilometer == kilometer &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.deskripsi == deskripsi &&
        other.statusPerbaikan == statusPerbaikan &&
        other.fotoPath == fotoPath;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      tanggal,
      jenisPerbaikan,
      jalur,
      lajur,
      kilometer,
      latitude,
      longitude,
      deskripsi,
      statusPerbaikan,
      fotoPath,
    );
  }
}
